//
//  MenuViewModel.swift
//  DropSweep
//
//  Created by Timo Köthe on 31.05.26.
//

import Observation
import AppKit

@Observable
class MenuViewModel {
    private let sweeper: Sweeper = .init()
    
    var isScanning: Bool = false
    var itemsCount: Int = 0
    var categories: [CategorySummary] = []

    var downloadsHasItems: Bool {
        itemsCount > 0
    }
    
    func scanDownloadsFolder() {
        isScanning = true

        sweeper.scanDownloadsFolder()
        itemsCount = sweeper.totalFiles + sweeper.folderCount
        categories = [
            CategorySummary(title: "Installer", count: sweeper.installerCount),
            CategorySummary(title: "Archive", count: sweeper.archiveCount),
            CategorySummary(title: "PDFs", count: sweeper.pdfCount),
            CategorySummary(title: "Screenshots", count: sweeper.screenshotCount),
            CategorySummary(title: "Folders", count: sweeper.folderCount),
            CategorySummary(title: "Other Files", count: sweeper.otherCount)
        ].filter { $0.count > 0 }
        isScanning = false
    }

    func deleteDownloads() {
        // TODO: Surface delete failures in the UI after the MVP flow is stable.
        sweeper.deleteAllInDownloads()
        scanDownloadsFolder()
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
}


struct CategorySummary: Identifiable {
    let id: String
    let title: String
    let count: Int

    init(title: String, count: Int) {
        self.id = title
        self.title = title
        self.count = count
    }
}
