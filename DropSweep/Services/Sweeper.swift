//
//  Sweeper.swift
//  DropSweep
//
//  Created by Timo Köthe on 30.05.26.
//

import Foundation

actor Sweeper {
    private let fileManager = FileManager.default
    private var sizeCache: [URL: CachedSize] = [:]

    private var downloadsURL: URL {
        fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }

    func scanDownloadsFolder() -> DownloadsScanResult {
        var result = DownloadsScanResult()
        var visitedCacheURLs = Set<URL>()

        let items: [URL]
        do {
            items = try fileManager.contentsOfDirectory(
                at: downloadsURL,
                includingPropertiesForKeys: Self.resourceKeys,
                // Only hidden items at the Downloads root are excluded. Hidden
                // contents of a visible folder move to the Trash with that folder.
                options: [.skipsHiddenFiles]
            )
        } catch {
            print("Failed to read Downloads folder:", error)
            result.scanErrorMessage = "Could not read Downloads folder."
            return result
        }

        for item in items {
            guard !Task.isCancelled else {
                return result
            }

            let values = try? item.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])

            if values?.isDirectory == true {
                result.items.append(item)
                result.folderCount += 1
                let sizeBytes = sizeOfDirectory(item, visitedCacheURLs: &visitedCacheURLs)
                result.folderSizeBytes += sizeBytes
                result.totalSizeBytes += sizeBytes
                continue
            }

            guard values?.isRegularFile == true else {
                continue
            }

            let sizeBytes = sizeOfFile(item, visitedCacheURLs: &visitedCacheURLs)
            result.items.append(item)
            result.totalFiles += 1
            result.totalSizeBytes += sizeBytes

            if isInstaller(item) {
                result.installerCount += 1
                result.installerSizeBytes += sizeBytes
            } else if isArchive(item) {
                result.archiveCount += 1
                result.archiveSizeBytes += sizeBytes
            } else if isPDF(item) {
                result.pdfCount += 1
                result.pdfSizeBytes += sizeBytes
            } else if isScreenshot(item) {
                result.screenshotCount += 1
                result.screenshotSizeBytes += sizeBytes
            } else {
                result.otherCount += 1
                result.otherSizeBytes += sizeBytes
            }
        }

        sizeCache = sizeCache.filter { visitedCacheURLs.contains($0.key) }
        return result
    }

    private func sizeOfFile(_ url: URL, visitedCacheURLs: inout Set<URL>) -> Int64 {
        visitedCacheURLs.insert(url)

        guard let values = try? url.resourceValues(forKeys: Set(Self.cacheKeys)) else {
            return 0
        }

        if let cachedSize = sizeCache[url], cachedSize.matches(values: values) {
            return cachedSize.sizeBytes
        }

        let sizeBytes = Int64(
            values.totalFileSize
                ?? values.fileSize
                ?? values.totalFileAllocatedSize
                ?? values.fileAllocatedSize
                ?? 0
        )

        sizeCache[url] = CachedSize(values: values, sizeBytes: sizeBytes)
        return sizeBytes
    }

    private func sizeOfDirectory(_ url: URL, visitedCacheURLs: inout Set<URL>) -> Int64 {
        visitedCacheURLs.insert(url)

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Self.cacheKeys,
            options: []
        ) else {
            return 0
        }

        var sizeBytes: Int64 = 0

        for case let item as URL in enumerator {
            guard !Task.isCancelled else {
                return sizeBytes
            }

            let values = try? item.resourceValues(forKeys: [.isRegularFileKey])

            guard values?.isRegularFile == true else {
                continue
            }

            sizeBytes += sizeOfFile(item, visitedCacheURLs: &visitedCacheURLs)
        }

        return sizeBytes
    }

    private func isInstaller(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "dmg" || ext == "pkg"
    }

    private func isArchive(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "zip" || ext == "xip" || ext == "rar" || ext == "7z" || ext == "tar" || ext == "gz"
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

    private static let resourceKeys: [URLResourceKey] = [
        .isDirectoryKey,
        .isRegularFileKey,
        .fileSizeKey,
        .fileAllocatedSizeKey,
        .totalFileSizeKey,
        .totalFileAllocatedSizeKey
    ]

    private static let cacheKeys: [URLResourceKey] = resourceKeys + [
        .contentModificationDateKey
    ]
    
    @discardableResult
    func deleteItemsInDownloads(_ items: [URL], moveToTrash: Bool = true) -> (deleted: Int, failures: [(url: URL, error: Error)]) {
        let downloadsURL = downloadsURL.standardizedFileURL
        var deleted = 0
        var failures: [(url: URL, error: Error)] = []

        for item in items {
            let item = item.standardizedFileURL

            guard item.deletingLastPathComponent() == downloadsURL else {
                failures.append((item, CocoaError(.fileNoSuchFile)))
                continue
            }

            do {
                if moveToTrash {
                    try fileManager.trashItem(at: item, resultingItemURL: nil)
                } else {
                    try fileManager.removeItem(at: item)
                }
                sizeCache[item] = nil
                deleted += 1
            } catch {
                failures.append((item, error))
            }
        }

        if failures.isEmpty {
            sizeCache.removeAll()
        }

        return (deleted, failures)
    }
}

nonisolated struct DownloadsScanResult {
    var items: [URL] = []
    var scanErrorMessage: String?
    var totalFiles: Int = 0
    var installerCount: Int = 0
    var archiveCount: Int = 0
    var pdfCount: Int = 0
    var screenshotCount: Int = 0
    var folderCount: Int = 0
    var otherCount: Int = 0
    var totalSizeBytes: Int64 = 0
    var installerSizeBytes: Int64 = 0
    var archiveSizeBytes: Int64 = 0
    var pdfSizeBytes: Int64 = 0
    var screenshotSizeBytes: Int64 = 0
    var folderSizeBytes: Int64 = 0
    var otherSizeBytes: Int64 = 0
}

nonisolated private struct CachedSize {
    let modificationDate: Date?
    let fileSize: Int?
    let fileAllocatedSize: Int?
    let totalFileSize: Int?
    let totalFileAllocatedSize: Int?
    let sizeBytes: Int64

    init(values: URLResourceValues, sizeBytes: Int64) {
        self.modificationDate = values.contentModificationDate
        self.fileSize = values.fileSize
        self.fileAllocatedSize = values.fileAllocatedSize
        self.totalFileSize = values.totalFileSize
        self.totalFileAllocatedSize = values.totalFileAllocatedSize
        self.sizeBytes = sizeBytes
    }

    func matches(values: URLResourceValues) -> Bool {
        modificationDate == values.contentModificationDate
            && fileSize == values.fileSize
            && fileAllocatedSize == values.fileAllocatedSize
            && totalFileSize == values.totalFileSize
            && totalFileAllocatedSize == values.totalFileAllocatedSize
    }
}
