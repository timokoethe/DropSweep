import SwiftUI

struct DownloadCategoryRow: View {
    let category: CategorySummary

    private var appearance: (symbol: String, color: Color) {
        switch category.id {
        case "Installer": ("shippingbox", .secondary)
        case "Archive": ("doc.zipper", .secondary)
        case "PDF": ("doc.richtext", .red)
        case "Screenshot": ("photo", .green)
        case "Image": ("photo.on.rectangle", .purple)
        case "Folder": ("folder", .blue)
        default: ("doc", .secondary)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: appearance.symbol)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(appearance.color)
                .frame(width: 24)
                .accessibilityHidden(true)
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
        .padding(.horizontal, 16)
        .frame(height: 45)
        .accessibilityElement(children: .combine)
    }
}
