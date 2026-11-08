import SwiftUI

struct CategorySelectionControls: View {
    let summary: String
    let allSelected: Bool
    let isEnabled: Bool
    let toggleSelection: () -> Void

    var body: some View {
        HStack {
            Text(summary)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Spacer(minLength: 8)
            Button(action: toggleSelection) {
                Text(allSelected ? "Deselect All" : "Select All")
            }
            .buttonStyle(.borderless)
            .disabled(!isEnabled)
        }
        .font(.caption)
    }
}
