//
//  DropSweepApp.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import AppKit
import Sparkle
import SwiftUI

@main
struct DropSweepApp: App {
    @State private var vm: MenuViewModel = .init()
    private let updaterController: SPUStandardUpdaterController
    @StateObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel

    init() {
        let updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        self.updaterController = updaterController
        _checkForUpdatesViewModel = StateObject(
            wrappedValue: CheckForUpdatesViewModel(updater: updaterController.updater)
        )
    }

    var body: some Scene {
        MenuBarExtra {
            MenuView(vm: vm)

            Divider()

            Button("About DropSweep") {
                vm.showAboutPanel()
            }

            Button("Check for Updates…") {
                updaterController.checkForUpdates(nil)
            }
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)

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
                Button("Quit DropSweep") {
                    vm.quitApp()
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
