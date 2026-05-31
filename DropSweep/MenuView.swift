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
            Text("DropSweep")
                .font(.headline)
        }
        .padding()
        .frame(width: 260)
        .onAppear {
            vm.scanDownloadsFolder()
        }
    }
}

#Preview {
    MenuView(vm: MenuViewModel())
}
