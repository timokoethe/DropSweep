import Foundation
import Testing

@MainActor
struct CategorySummaryTests {
    @Test func singularSummaryOmitsZeroSize() {
        let category = CategorySummary(category: .pdf, count: 1, sizeBytes: 0)
        #expect(category.displayTitle == "PDF")
        #expect(category.countSummary == "1 item")
        #expect(category.displaySummary == "PDF: 1 item")
    }

    @Test func pluralSummaryIncludesFormattedSize() {
        let category = CategorySummary(category: .archive, count: 3, sizeBytes: 4096)
        let expectedSize = ByteCountFormatter.string(fromByteCount: 4096, countStyle: .file)
        #expect(category.displayTitle == "Archives")
        #expect(category.countSummary == "3 items")
        #expect(category.displaySummary == "Archives: 3 items · \(expectedSize)")
    }

    @Test(arguments: [
        (DownloadsCategory.installer, "Installer", "Installers"),
        (.archive, "Archive", "Archives"),
        (.pdf, "PDF", "PDFs"),
        (.screenshot, "Screenshot", "Screenshots"),
        (.image, "Image", "Images"),
        (.folder, "Folder", "Folders"),
        (.other, "Other File", "Other Files")
    ])
    func categoryTitles(category: DownloadsCategory, singular: String, plural: String) {
        #expect(CategorySummary(category: category, count: 1, sizeBytes: 0).displayTitle == singular)
        #expect(CategorySummary(category: category, count: 2, sizeBytes: 0).displayTitle == plural)
    }

    @Test func identityRemainsStableAcrossCountChanges() {
        let single = CategorySummary(category: .image, count: 1, sizeBytes: 1)
        let multiple = CategorySummary(category: .image, count: 2, sizeBytes: 2)
        #expect(single.id == multiple.id)
    }
}
