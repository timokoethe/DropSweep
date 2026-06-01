//
//  Sweeper.swift
//  DropSweep
//
//  Created by Timo Köthe on 30.05.26.
//

import Foundation

final class Sweeper {
    private let fileManager = FileManager.default

    var totalFiles: Int = 0
    var installerCount: Int = 0
    var archiveCount: Int = 0
    var pdfCount: Int = 0
    var screenshotCount: Int = 0
    var folderCount: Int = 0
    var otherCount: Int = 0

    private var downloadsURL: URL {
        fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }

    func scanDownloadsFolder() {
        resetCounts()

        let items: [URL]
        do {
            items = try fileManager.contentsOfDirectory(
                at: downloadsURL,
                includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            print("Failed to read Downloads folder:", error)
            return
        }

        for item in items {
            let values = try? item.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])

            if values?.isDirectory == true {
                folderCount += 1
                continue
            }

            guard values?.isRegularFile == true else {
                continue
            }

            totalFiles += 1

            if isInstaller(item) {
                installerCount += 1
            } else if isArchive(item) {
                archiveCount += 1
            } else if isPDF(item) {
                pdfCount += 1
            } else if isScreenshot(item) {
                screenshotCount += 1
            } else {
                otherCount += 1
            }
        }
    }

    private func resetCounts() {
        totalFiles = 0
        installerCount = 0
        archiveCount = 0
        pdfCount = 0
        screenshotCount = 0
        folderCount = 0
        otherCount = 0
    }

    private func isInstaller(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "dmg" || ext == "pkg"
    }

    private func isArchive(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "zip" || ext == "rar" || ext == "7z" || ext == "tar" || ext == "gz"
    }

    private func isPDF(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "pdf"
    }

    private func isScreenshot(_ url: URL) -> Bool {
        let filename = url.lastPathComponent.lowercased()
        let ext = url.pathExtension.lowercased()

        guard ext == "png" || ext == "jpg" || ext == "jpeg" else {
            return false
        }

        return filename.contains("screenshot")
            || filename.contains("bildschirmfoto")
            || filename.contains("cleanshot")
    }
    
    @discardableResult
    func deleteAllInDownloads(moveToTrash: Bool = true) -> (deleted: Int, failures: [(url: URL, error: Error)]) {
        let items: [URL]
        do {
            items = try fileManager.contentsOfDirectory(
                at: downloadsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } catch {
            return (0, [(downloadsURL, error)])
        }

        var deleted = 0
        var failures: [(url: URL, error: Error)] = []

        for item in items {
            do {
                if moveToTrash {
                    try fileManager.trashItem(at: item, resultingItemURL: nil)
                } else {
                    try fileManager.removeItem(at: item)
                }
                deleted += 1
            } catch {
                failures.append((item, error))
            }
        }

        return (deleted, failures)
    }
}
