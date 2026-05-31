//
//  MenuViewModel.swift
//  DropSweep
//
//  Created by Timo Köthe on 31.05.26.
//

import Observation
import AppKit

@Observable
class MenuViewModel {
    private let sweeper: Sweeper = .init()
    
    var isScanning: Bool = false
    var itemsCount: Int = 0
    
    func scanDownloadsFolder() {
        isScanning = true
        sweeper.scanDownloadsFolder()
        isScanning = false
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
