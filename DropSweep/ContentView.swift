//
//  ContentView.swift
//  DropSweep
//
//  Created by Timo Köthe on 24.05.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DropSweep")
                .font(.headline)
        }
        .padding()
        .frame(width: 260)
        .onAppear {
            // summary = sweeper.scan()
        }
    }
}

#Preview {
    ContentView()
}
