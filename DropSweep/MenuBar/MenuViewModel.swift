//
//  MenuViewModel.swift
//  DropSweep
//
//  Created by Timo Köthe on 31.05.26.
//

import Observation
import AppKit
import ServiceManagement

@Observable
class MenuViewModel {
    private let sweeper: any DownloadsSweeping
    @ObservationIgnored private let selectionStore: CategorySelectionStore
    @ObservationIgnored private let presenter: any MenuPresenting
    @ObservationIgnored private var scanTask: Task<Void, Never>?
    
    var isScanning: Bool = false
    var isDeleting: Bool = false
    var itemsCount: Int = 0
    var totalSizeBytes: Int64 = 0
    var categories: [CategorySummary] = []
    var selectedCategories: Set<DownloadsCategory> {
        didSet {
            if selectedCategories != oldValue {
                selectionStore.save(selectedCategories)
            }
        }
    }
    var scanErrorMessage: String?
    var launchAtLoginEnabled: Bool
    @ObservationIgnored private var deletableItems: [DownloadsItem] = []

    init(
        sweeper: any DownloadsSweeping = Sweeper(),
        launchAtLoginEnabled: Bool = SMAppService.mainApp.status == .enabled,
        selectionStore: CategorySelectionStore = CategorySelectionStore(),
        presenter: any MenuPresenting = MenuPresenter()
    ) {
        self.sweeper = sweeper
        self.selectionStore = selectionStore
        self.selectedCategories = selectionStore.load()
        self.presenter = presenter
        self.launchAtLoginEnabled = launchAtLoginEnabled
    }

    var canDeleteDownloads: Bool {
        !isScanning && !isDeleting && scanErrorMessage == nil && selectedItemsCount > 0
    }

    var canChangeCategorySelection: Bool {
        !isScanning && !isDeleting && scanErrorMessage == nil && !categories.isEmpty
    }

    var areAllCategoriesSelected: Bool {
        !categories.isEmpty && categories.allSatisfy { selectedCategories.contains($0.category) }
    }

    func toggleAllCategories() {
        guard canChangeCategorySelection else { return }
        selectedCategories = areAllCategoriesSelected ? [] : Set(DownloadsCategory.allCases)
    }

    subscript(isSelected category: DownloadsCategory) -> Bool {
        get { selectedCategories.contains(category) }
        set {
            if newValue {
                selectedCategories.insert(category)
            } else {
                selectedCategories.remove(category)
            }
        }
    }

    var selectedItemsCount: Int {
        categories.filter { selectedCategories.contains($0.category) }.reduce(0) { $0 + $1.count }
    }

    var selectionSummary: String {
        let bytes = categories.filter { selectedCategories.contains($0.category) }.reduce(Int64(0)) { $0 + $1.sizeBytes }
        let size = Self.sizeFormatter.string(fromByteCount: bytes)
        return "\(selectedItemsCount) \(selectedItemsCount == 1 ? "item" : "items") selected · \(size)"
    }

    var itemsSummary: String {
        "\(itemsCount) \(itemsCount == 1 ? "item" : "items")"
    }

    var totalDisplaySize: String {
        Self.sizeFormatter.string(fromByteCount: totalSizeBytes)
    }

    @discardableResult
    func scanDownloadsFolder() -> Task<Void, Never> {
        scanTask?.cancel()
        isScanning = true

        let task = Task {
            let result = await sweeper.scanDownloadsFolder()

            guard !Task.isCancelled else {
                return
            }

            applyScanResult(result)
            isScanning = false
        }
        scanTask = task
        return task
    }

    private func applyScanResult(_ result: DownloadsScanResult) {
        scanErrorMessage = result.scanErrorMessage
        deletableItems = result.items
        itemsCount = result.items.count
        totalSizeBytes = result.totalSizeBytes
        categories = DownloadsCategory.allCases.compactMap { category in
            let statistics = result[category]
            guard statistics.count > 0 else { return nil }
            return CategorySummary(category: category, count: statistics.count, sizeBytes: statistics.sizeBytes)
        }
    }

    func refreshLaunchAtLoginStatus() {
        launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
    }

    func itemsForDeletionConfirmation() -> [DownloadsItem]? {
        guard canDeleteDownloads else {
            return nil
        }

        return deletableItems.filter { selectedCategories.contains($0.category) }
    }

    @discardableResult
    func deleteDownloads(_ confirmedItems: [DownloadsItem]) -> Task<Void, Never>? {
        guard !isDeleting && !confirmedItems.isEmpty else {
            return nil
        }

        scanTask?.cancel()
        isScanning = true
        isDeleting = true

        let task = Task {
            defer {
                isScanning = false
                isDeleting = false
            }

            let deleteResult = await sweeper.deleteItemsInDownloads(confirmedItems)
            let scanResult = await sweeper.scanDownloadsFolder()

            guard !Task.isCancelled else {
                return
            }

            applyScanResult(scanResult)

            if !deleteResult.failures.isEmpty {
                presenter.showTrashError(deletedCount: deleteResult.deleted, failures: deleteResult.failures)
            }
        }
        return task
    }

    func setLaunchAtLogin(_ isEnabled: Bool) {
        do {
            if isEnabled {
                // An existing registration may only be waiting for user approval.
                if SMAppService.mainApp.status != .requiresApproval {
                    try SMAppService.mainApp.register()
                }
            } else {
                try SMAppService.mainApp.unregister()
            }
            refreshLaunchAtLoginStatus()

            if isEnabled && SMAppService.mainApp.status == .requiresApproval {
                presenter.showLaunchAtLoginApprovalRequired()
            }
        } catch {
            refreshLaunchAtLoginStatus()
            if isEnabled && SMAppService.mainApp.status == .requiresApproval {
                presenter.showLaunchAtLoginApprovalRequired()
            } else {
                presenter.showLaunchAtLoginError(error)
            }
        }
    }

    func showAboutPanel() {
        presenter.showAboutPanel()
    }

    func confirmMovingToTrash(itemCount: Int) -> Bool {
        presenter.confirmMovingToTrash(itemCount: itemCount)
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private static let sizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()
}
