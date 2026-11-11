//
//  CategorySummary.swift
//  DropSweep
//
//  Created by Timo Köthe on 21.06.26.
//

import Foundation

struct CategorySummary: Identifiable {
    var id: String { category.rawValue }
    let category: DownloadsCategory
    let count: Int
    let sizeBytes: Int64

    var displayTitle: String {
        let titles: (singular: String, plural: String) = switch category {
        case .installer: ("Installer", "Installers")
        case .archive: ("Archive", "Archives")
        case .pdf: ("PDF", "PDFs")
        case .screenshot: ("Screenshot", "Screenshots")
        case .image: ("Image", "Images")
        case .folder: ("Folder", "Folders")
        case .other: ("Other File", "Other Files")
        }
        return count == 1 ? titles.singular : titles.plural
    }

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }

    var countSummary: String {
        "\(count) \(count == 1 ? "item" : "items")"
    }

    var displaySummary: String {
        guard sizeBytes > 0 else {
            return "\(displayTitle): \(countSummary)"
        }

        return "\(displayTitle): \(countSummary) · \(displaySize)"
    }
}
