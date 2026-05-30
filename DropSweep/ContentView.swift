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
            let sweeper = Sweeper()
            sweeper.scanDownloadsFolder()
            print(sweeper.totalFiles)
            print(sweeper.installerCount)
            print(sweeper.archiveCount)
            print(sweeper.pdfCount)
            print(sweeper.screenshotCount)
            print(sweeper.folderCount)
            print(sweeper.otherCount)
            // summary = sweeper.scan()
        }
    }
}

#Preview {
    ContentView()
}
