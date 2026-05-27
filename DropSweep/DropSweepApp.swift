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
    var body: some Scene {
        MenuBarExtra {
            ContentView()

            Divider()

            Button("Quit DropSweep") {
                quitApp()
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
                    quitApp()
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
