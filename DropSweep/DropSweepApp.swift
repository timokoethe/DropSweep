//
//  DropSweepApp.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import AppKit
import SwiftUI

@main
struct DropSweepApp: App {
    @State private var vm: MenuViewModel = .init()
    var body: some Scene {
        MenuBarExtra {
            MenuView(vm: vm)

            Divider()

            Button("Quit DropSweep") {
                vm.quitApp()
            }
            .keyboardShortcut("q", modifiers: .command)
        } label: {
            Image("MenuBarIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .menuBarExtraStyle(.menu)
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("DropSweep beenden") {
                    vm.quitApp()
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
