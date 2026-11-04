import SwiftUI

struct DownloadCategoryRow: View {
    let category: CategorySummary
    @Binding var isSelected: Bool

    private var appearance: (symbol: String, color: Color) {
        switch category.category {
        case .installer: ("shippingbox", .secondary)
        case .archive: ("doc.zipper", .secondary)
        case .pdf: ("doc.richtext", .red)
        case .screenshot: ("photo", .green)
        case .image: ("photo.on.rectangle", .purple)
        case .folder: ("folder", .blue)
        case .other: ("doc", .secondary)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Toggle(category.displaySummary, isOn: $isSelected)
                .toggleStyle(.checkbox)
                .labelsHidden()
                .frame(width: 14)

            categoryLabel
                .frame(maxWidth: .infinity, minHeight: 45)
                .contentShape(Rectangle())
                .onTapGesture { isSelected.toggle() }
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .frame(height: 45)
    }

    private var categoryLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: appearance.symbol)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(appearance.color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayTitle)
                    .font(.system(size: 13, weight: .semibold))
                Text(category.countSummary)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(category.displaySize)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
