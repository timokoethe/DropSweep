//
//  ContentView.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import AppKit
import SwiftUI

struct MenuView: View {
    @Bindable var vm: MenuViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("DropSweep")
                .font(.headline)
            
            Divider()
            
            Text("Downloads: \(vm.itemsCount) items")

            if vm.categories.isEmpty {
                Text("No categories found")
                    .foregroundStyle(.secondary)
            } else {
                VStack {
                    ForEach(vm.categories) { category in
                        Text("\(category.title): \(category.count)")
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive, action: vm.deleteDownloads) {
                Label("Move All to Trash", systemImage: "trash")
            }
            .disabled(!vm.downloadsHasItems || vm.isScanning)
        }
        .frame(width: 240)
        .padding()
        .onAppear {
            vm.scanDownloadsFolder()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSMenu.didBeginTrackingNotification)) { _ in
            vm.scanDownloadsFolder()
        }
    }
}

#Preview {
    MenuView(vm: MenuViewModel())
}
