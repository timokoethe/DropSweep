import Testing

@MainActor
struct CategorySortOrderTests {
    @Test func sortsByTotalBytesInsteadOfCountOrTitle() {
        let categories = [
            summary(.pdf, count: 100, bytes: 10),
            summary(.archive, count: 1, bytes: .max),
            summary(.installer, count: 3, bytes: 500),
            summary(.image, count: 2, bytes: 0)
        ]

        #expect(CategorySortOrder.category.sorted(categories).map(\.category) == [.pdf, .archive, .installer, .image])
        #expect(CategorySortOrder.largestFirst.sorted(categories).map(\.category) == [.archive, .installer, .pdf, .image])
        #expect(CategorySortOrder.smallestFirst.sorted(categories).map(\.category) == [.image, .pdf, .installer, .archive])
        #expect(categories.map(\.category) == [.pdf, .archive, .installer, .image])
    }

    @Test(arguments: [CategorySortOrder.largestFirst, .smallestFirst])
    func equalSizesPreserveCategoryOrder(order: CategorySortOrder) {
        let categories = [summary(.pdf, bytes: 20), summary(.archive, bytes: 10), summary(.installer, bytes: 20)]
        let sorted = order.sorted(categories)
        #expect(sorted.filter { $0.sizeBytes == 20 }.map(\.category) == [.pdf, .installer])
        #expect(sorted.first { $0.category == .pdf }?.count == categories[0].count)
    }

    @Test(arguments: CategorySortOrder.allCases)
    func handlesEmptyAndSingleCategory(order: CategorySortOrder) {
        #expect(order.sorted([]).isEmpty)
        let categories = [summary(.folder, bytes: 42)]
        #expect(order.sorted(categories).map(\.id) == categories.map(\.id))
    }

    private func summary(_ category: DownloadsCategory, count: Int = 1, bytes: Int64) -> CategorySummary {
        CategorySummary(category: category, count: count, sizeBytes: bytes)
    }
}
