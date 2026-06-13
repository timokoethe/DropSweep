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
