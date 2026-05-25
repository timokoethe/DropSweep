//
//  DropSweepApp.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import SwiftUI

@main
struct DropSweepApp: App {
    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image("MenuBarIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
        .menuBarExtraStyle(.window)
    }
}
