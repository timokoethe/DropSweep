//
//  ContentView.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import SwiftUI

struct MenuView: View {
    @Bindable var vm: MenuViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            Text("DropSweep")
                .font(.headline)
            
            Button("Analyze Downloads",
                   systemImage: "sparkle.magnifyingglass",
                   action: vm.scanDownloadsFolder)
            
            Divider()
            
            Text("Downloads: 3,3 GB - 10 items")
        }
        .padding()
        .onAppear {
            vm.scanDownloadsFolder()
        }
    }
}

#Preview {
    MenuView(vm: MenuViewModel())
}
