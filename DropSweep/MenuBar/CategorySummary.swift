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
    let singularTitle: String
    let pluralTitle: String
    let count: Int
    let sizeBytes: Int64

    var displayTitle: String {
        count == 1 ? singularTitle : pluralTitle
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
