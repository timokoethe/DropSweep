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
    private let sweeper: Sweeper = .init()
    @ObservationIgnored private var scanTask: Task<Void, Never>?
    @ObservationIgnored private var deleteTask: Task<Void, Never>?
    
    var isScanning: Bool = false
    var isDeleting: Bool = false
    var itemsCount: Int = 0
    var totalSizeBytes: Int64 = 0
    var categories: [CategorySummary] = []
    var scanErrorMessage: String?
    var launchAtLoginEnabled: Bool = SMAppService.mainApp.status == .enabled
    @ObservationIgnored private var deletableItems: [URL] = []

    init() {
        scanDownloadsFolder()
    }

    var downloadsHasItems: Bool {
        itemsCount > 0
    }

    var canDeleteDownloads: Bool {
        !isScanning && !isDeleting && downloadsHasItems
    }

    var downloadsSummary: String {
        "Downloads: \(itemsSummary) · \(totalDisplaySize)"
    }

    var itemsSummary: String {
        "\(itemsCount) \(itemsCount == 1 ? "item" : "items")"
    }

    var totalDisplaySize: String {
        Self.sizeFormatter.string(fromByteCount: totalSizeBytes)
    }

    func scanDownloadsFolder() {
        scanTask?.cancel()
        isScanning = true

        scanTask = Task {
            let result = await sweeper.scanDownloadsFolder()

            guard !Task.isCancelled else {
                return
            }

            applyScanResult(result)
            isScanning = false
        }
    }

    private func applyScanResult(_ result: DownloadsScanResult) {
        scanErrorMessage = result.scanErrorMessage
        deletableItems = result.items
        itemsCount = result.totalFiles + result.folderCount
        totalSizeBytes = result.totalSizeBytes
        categories = [
            CategorySummary(singularTitle: "Installer", pluralTitle: "Installers", count: result.installerCount, sizeBytes: result.installerSizeBytes),
            CategorySummary(singularTitle: "Archive", pluralTitle: "Archives", count: result.archiveCount, sizeBytes: result.archiveSizeBytes),
            CategorySummary(singularTitle: "PDF", pluralTitle: "PDFs", count: result.pdfCount, sizeBytes: result.pdfSizeBytes),
            CategorySummary(singularTitle: "Screenshot", pluralTitle: "Screenshots", count: result.screenshotCount, sizeBytes: result.screenshotSizeBytes),
            CategorySummary(singularTitle: "Folder", pluralTitle: "Folders", count: result.folderCount, sizeBytes: result.folderSizeBytes),
            CategorySummary(singularTitle: "Other File", pluralTitle: "Other Files", count: result.otherCount, sizeBytes: result.otherSizeBytes)
        ].filter { $0.count > 0 }
    }

    func refreshLaunchAtLoginStatus() {
        launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
    }

    func deleteDownloads() {
        guard canDeleteDownloads else {
            return
        }

        scanTask?.cancel()
        isScanning = true
        isDeleting = true
        let itemsToDelete = deletableItems

        deleteTask = Task {
            defer {
                isScanning = false
                isDeleting = false
            }

            let deleteResult = await sweeper.deleteItemsInDownloads(itemsToDelete)
            let scanResult = await sweeper.scanDownloadsFolder()

            guard !Task.isCancelled else {
                return
            }

            applyScanResult(scanResult)

            if !deleteResult.failures.isEmpty {
                showDeleteDownloadsError(deletedCount: deleteResult.deleted, failures: deleteResult.failures)
            }
        }
    }

    func setLaunchAtLogin(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
        } catch {
            launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
            showLaunchAtLoginError(error)
        }
    }

    func toggleLaunchAtLogin() {
        setLaunchAtLogin(!launchAtLoginEnabled)
    }

    func showAboutPanel() {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        let currentYear = Calendar.current.component(.year, from: Date())
        let sourceText = "Source on GitHub"
        let copyrightText = "Copyright © \(currentYear) Timo Köthe"
        let credits = NSMutableAttributedString(string: "\(sourceText)\n\(copyrightText)")
        let sourceRange = NSRange(location: 0, length: "Source on GitHub".count)
        let copyrightRange = NSRange(location: sourceText.count + 1, length: copyrightText.count)
        let copyrightParagraphStyle = NSMutableParagraphStyle()

        copyrightParagraphStyle.paragraphSpacingBefore = 8

        credits.addAttribute(.link, value: "https://github.com/timokoethe/DropSweep", range: sourceRange)
        credits.addAttribute(.foregroundColor, value: NSColor.linkColor, range: sourceRange)
        credits.addAttribute(.font, value: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize), range: copyrightRange)
        credits.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: copyrightRange)
        credits.addAttribute(.paragraphStyle, value: copyrightParagraphStyle, range: copyrightRange)

        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            .applicationName: "DropSweep",
            .applicationVersion: version,
            .version: "Build \(build)",
            .credits: credits
        ])
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func showLaunchAtLoginError(_ error: Error) {
        let alert = NSAlert()

        alert.messageText = "Could Not Update Login Setting"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showDeleteDownloadsError(deletedCount: Int, failures: [(url: URL, error: Error)]) {
        let alert = NSAlert()
        let failedItems = failures
            .prefix(3)
            .map { $0.url.lastPathComponent }
            .joined(separator: "\n")
        let remainingItems = failures.count > 3 ? "\n…and \(failures.count - 3) more" : ""
        let failureReason = failures.allSatisfy { failure in
            (failure.error as NSError).code == NSFileNoSuchFileError
        } ? "They may have already been moved or deleted while the confirmation was open." : "Some items may have changed or could not be accessed."

        alert.messageText = "Some Items Could Not Be Moved to the Trash"
        alert.informativeText = "\(deletedCount) item\(deletedCount == 1 ? "" : "s") moved to the Trash. \(failures.count) item\(failures.count == 1 ? "" : "s") could not be moved.\n\(failureReason)\n\n\(failedItems)\(remainingItems)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private static let sizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()
}
