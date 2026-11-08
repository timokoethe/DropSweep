enum CategorySortOrder: String, CaseIterable, Identifiable {
    case category
    case largestFirst
    case smallestFirst

    var id: Self { self }

    var title: String {
        switch self {
        case .category: "Category Order"
        case .largestFirst: "Largest First"
        case .smallestFirst: "Smallest First"
        }
    }

    func sorted(_ categories: [CategorySummary]) -> [CategorySummary] {
        guard self != .category else { return categories }

        return categories.enumerated().sorted { lhs, rhs in
            // Preserve the scan's category order when sizes are equal.
            if lhs.element.sizeBytes == rhs.element.sizeBytes {
                return lhs.offset < rhs.offset
            }
            return self == .largestFirst
                ? lhs.element.sizeBytes > rhs.element.sizeBytes
                : lhs.element.sizeBytes < rhs.element.sizeBytes
        }.map(\.element)
    }
}
