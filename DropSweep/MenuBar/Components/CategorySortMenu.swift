import SwiftUI

struct CategorySortMenu: View {
    @Binding var selection: CategorySortOrder

    var body: some View {
        Menu {
            Picker("Sort Categories", selection: $selection) {
                ForEach(CategorySortOrder.allCases) { order in
                    Text(order.title).tag(order)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .frame(width: 28, height: 28)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("Sort categories: \(selection.title)")
        .accessibilityLabel("Sort Categories")
        .accessibilityValue(selection.title)
    }
}
