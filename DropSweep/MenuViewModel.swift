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
    
    var isScanning: Bool = false
    var itemsCount: Int = 0
    var categories: [CategorySummary] = []
    var launchAtLoginEnabled: Bool = SMAppService.mainApp.status == .enabled

    var downloadsHasItems: Bool {
        itemsCount > 0
    }

    var downloadsSummary: String {
        "Downloads: \(itemsCount) \(itemsCount == 1 ? "item" : "items")"
    }

    func scanDownloadsFolder() {
        isScanning = true

        sweeper.scanDownloadsFolder()
        itemsCount = sweeper.totalFiles + sweeper.folderCount
        categories = [
            CategorySummary(singularTitle: "Installer", pluralTitle: "Installers", count: sweeper.installerCount),
            CategorySummary(singularTitle: "Archive", pluralTitle: "Archives", count: sweeper.archiveCount),
            CategorySummary(singularTitle: "PDF", pluralTitle: "PDFs", count: sweeper.pdfCount),
            CategorySummary(singularTitle: "Screenshot", pluralTitle: "Screenshots", count: sweeper.screenshotCount),
            CategorySummary(singularTitle: "Folder", pluralTitle: "Folders", count: sweeper.folderCount),
            CategorySummary(singularTitle: "Other File", pluralTitle: "Other Files", count: sweeper.otherCount)
        ].filter { $0.count > 0 }
        isScanning = false
    }

    func refreshLaunchAtLoginStatus() {
        launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
    }

    func deleteDownloads() {
        let result = sweeper.deleteAllInDownloads()
        scanDownloadsFolder()

        if !result.failures.isEmpty {
            showDeleteDownloadsError(deletedCount: result.deleted, failures: result.failures)
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
        let copyrightText = "Copyright (c) \(currentYear) Timo Köthe"
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
            .prefix(5)
            .map { "\($0.url.lastPathComponent): \($0.error.localizedDescription)" }
            .joined(separator: "\n")
        let remainingItems = failures.count > 5 ? "\n…and \(failures.count - 5) more" : ""

        alert.messageText = "Could Not Move All Items to the Trash"
        alert.informativeText = "\(deletedCount) item\(deletedCount == 1 ? "" : "s") moved to the Trash. \(failures.count) item\(failures.count == 1 ? "" : "s") could not be moved.\n\n\(failedItems)\(remainingItems)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


struct CategorySummary: Identifiable {
    let id: String
    let singularTitle: String
    let pluralTitle: String
    let count: Int

    var displayTitle: String {
        count == 1 ? singularTitle : pluralTitle
    }

    init(singularTitle: String, pluralTitle: String, count: Int) {
        self.id = singularTitle
        self.singularTitle = singularTitle
        self.pluralTitle = pluralTitle
        self.count = count
    }
}
