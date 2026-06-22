//
//  MenuView.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import AppKit
import SwiftUI

struct MenuView: View {
    @Bindable var vm: MenuViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.downloadsSummary)
                .fontWeight(.semibold)

            if vm.categories.isEmpty {
                Text("No items found")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(vm.categories) { category in
                        Text(category.displaySummary)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive) {
                confirmDeleteDownloads()
            } label: {
                MenuItemLabel("Move All Items to Trash", systemImage: "trash")
            }
            .disabled(!vm.canDeleteDownloads)
        }
        .frame(width: 240)
        .padding()
        .onAppear {
            vm.refreshLaunchAtLoginStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSMenu.didBeginTrackingNotification)) { _ in
            vm.scanDownloadsFolder()
            vm.refreshLaunchAtLoginStatus()
        }
    }

    private func confirmDeleteDownloads() {
        let itemLabel = vm.itemsCount == 1 ? "item" : "items"
        let alert = NSAlert()

        alert.messageText = "Move \(vm.itemsCount) \(itemLabel) to the Trash?"
        alert.informativeText = "This moves every visible item in Downloads to the Trash."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Move to Trash")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else {
            return
        }

        vm.deleteDownloads()
    }
}

#Preview {
    MenuView(vm: MenuViewModel())
}
