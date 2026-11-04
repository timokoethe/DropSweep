import Foundation
import Testing

@MainActor
struct CategorySummaryTests {
    @Test func singularSummaryOmitsZeroSize() {
        let category = CategorySummary(singularTitle: "PDF", pluralTitle: "PDFs", count: 1, sizeBytes: 0)
        #expect(category.displayTitle == "PDF")
        #expect(category.countSummary == "1 item")
        #expect(category.displaySummary == "PDF: 1 item")
    }

    @Test func pluralSummaryIncludesFormattedSize() {
        let category = CategorySummary(singularTitle: "Archive", pluralTitle: "Archives", count: 3, sizeBytes: 4096)
        let expectedSize = ByteCountFormatter.string(fromByteCount: 4096, countStyle: .file)
        #expect(category.displayTitle == "Archives")
        #expect(category.countSummary == "3 items")
        #expect(category.displaySummary == "Archives: 3 items · \(expectedSize)")
    }

    @Test func identityRemainsStableAcrossCountChanges() {
        let single = CategorySummary(singularTitle: "Image", pluralTitle: "Images", count: 1, sizeBytes: 1)
        let multiple = CategorySummary(singularTitle: "Image", pluralTitle: "Images", count: 2, sizeBytes: 2)
        #expect(single.id == multiple.id)
    }
}
