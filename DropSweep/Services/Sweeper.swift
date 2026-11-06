//
//  Sweeper.swift
//  DropSweep
//
//  Created by Timo Köthe on 30.05.26.
//

import Foundation

nonisolated protocol DownloadsSweeping: Sendable {
    func scanDownloadsFolder() async -> DownloadsScanResult
    func deleteItemsInDownloads(_ items: [DownloadsItem]) async -> (deleted: Int, failures: [(url: URL, error: Error)])
}

actor Sweeper: DownloadsSweeping {
    private let fileManager: FileManager
    private let downloadsURL: URL
    private let trashItem: @Sendable (URL) throws -> Void
    private var sizeCache: [URL: CachedSize] = [:]

    init() {
        self.fileManager = .default
        self.downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        self.trashItem = { url in
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        }
    }

    // Require an explicit trash operation when supplying a directory so tests
    // cannot accidentally use the real macOS Trash.
    init(downloadsURL: URL, trashItem: @escaping @Sendable (URL) throws -> Void) {
        self.fileManager = .default
        self.downloadsURL = downloadsURL
        self.trashItem = trashItem
    }

    func scanDownloadsFolder() -> DownloadsScanResult {
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
            return DownloadsScanResult(scanErrorMessage: "Could not read Downloads folder.")
        }

        do {
            return try scanItems(items)
        } catch {
            // Never present partial counts or sizes as a complete cleanup snapshot.
            sizeCache.removeAll()
            return DownloadsScanResult(
                scanErrorMessage: "Could not read all Downloads items. Check access permissions and try again."
            )
        }
    }

    private func scanItems(_ items: [URL]) throws -> DownloadsScanResult {
        var result = DownloadsScanResult()
        var visitedCacheURLs = Set<URL>()

        for item in items {
            guard !Task.isCancelled else {
                return result
            }

            // Check before classifying directories: Safari downloads can be bundles.
            guard !Self.incompleteDownloadExtensions.contains(item.pathExtension.lowercased()) else {
                continue
            }

            let values = try item.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey, .fileResourceIdentifierKey])
            let downloadsItem = DownloadsItem(
                url: item,
                fileResourceIdentifier: values.fileResourceIdentifier as? Data,
                category: values.isDirectory == true ? .folder : category(for: item)
            )

            if values.isDirectory == true {
                result.items.append(downloadsItem)
                result.folderCount += 1
                let sizeBytes = try sizeOfDirectory(item, visitedCacheURLs: &visitedCacheURLs)
                result.folderSizeBytes += sizeBytes
                result.totalSizeBytes += sizeBytes
                continue
            }

            guard values.isRegularFile == true else {
                continue
            }

            let sizeBytes = try sizeOfFile(item, visitedCacheURLs: &visitedCacheURLs)
            result.items.append(downloadsItem)
            result.totalFiles += 1
            result.totalSizeBytes += sizeBytes

            switch downloadsItem.category {
            case .installer:
                result.installerCount += 1
                result.installerSizeBytes += sizeBytes
            case .archive:
                result.archiveCount += 1
                result.archiveSizeBytes += sizeBytes
            case .pdf:
                result.pdfCount += 1
                result.pdfSizeBytes += sizeBytes
            case .screenshot:
                result.screenshotCount += 1
                result.screenshotSizeBytes += sizeBytes
            case .image:
                result.imageCount += 1
                result.imageSizeBytes += sizeBytes
            case .other:
                result.otherCount += 1
                result.otherSizeBytes += sizeBytes
            case .folder:
                break
            }
        }

        sizeCache = sizeCache.filter { visitedCacheURLs.contains($0.key) }
        return result
    }

    private func sizeOfFile(_ url: URL, visitedCacheURLs: inout Set<URL>) throws -> Int64 {
        visitedCacheURLs.insert(url)

        let values = try url.resourceValues(forKeys: Set(Self.cacheKeys))

        if let cachedSize = sizeCache[url], cachedSize.matches(values: values) {
            return cachedSize.sizeBytes
        }

        guard let size = values.totalFileSize
                ?? values.fileSize
                ?? values.totalFileAllocatedSize
                ?? values.fileAllocatedSize else {
            throw CocoaError(.fileReadUnknown)
        }
        let sizeBytes = Int64(size)

        sizeCache[url] = CachedSize(values: values, sizeBytes: sizeBytes)
        return sizeBytes
    }

    private func sizeOfDirectory(_ url: URL, visitedCacheURLs: inout Set<URL>) throws -> Int64 {
        visitedCacheURLs.insert(url)

        var enumerationError: Error?
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: Self.cacheKeys,
            options: [],
            errorHandler: { _, error in
                enumerationError = error
                return false
            }
        ) else {
            throw CocoaError(.fileReadUnknown)
        }

        var sizeBytes: Int64 = 0

        for case let item as URL in enumerator {
            guard !Task.isCancelled else {
                return sizeBytes
            }

            let values = try item.resourceValues(forKeys: [.isRegularFileKey])

            guard values.isRegularFile == true else {
                continue
            }

            sizeBytes += try sizeOfFile(item, visitedCacheURLs: &visitedCacheURLs)
        }

        if let enumerationError {
            throw enumerationError
        }

        return sizeBytes
    }

    private func category(for url: URL) -> DownloadsCategory {
        if isInstaller(url) { return .installer }
        if isArchive(url) { return .archive }
        if isPDF(url) { return .pdf }
        if isScreenshot(url) { return .screenshot }
        if isImage(url) { return .image }
        return .other
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

    private func isImage(_ url: URL) -> Bool {
        Self.imageExtensions.contains(url.pathExtension.lowercased())
    }

    private static let incompleteDownloadExtensions: Set<String> = [
        "crdownload", "download", "part", "partial", "opdownload", "filepart"
    ]

    private static let imageExtensions: Set<String> = [
        "png", "jpg", "jpeg", "svg", "gif", "webp", "heic", "heif",
        "tif", "tiff", "bmp", "avif", "ico"
    ]

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
    func deleteItemsInDownloads(_ items: [DownloadsItem]) -> (deleted: Int, failures: [(url: URL, error: Error)]) {
        let downloadsURL = downloadsURL.standardizedFileURL
        var deleted = 0
        var failures: [(url: URL, error: Error)] = []

        for item in items {
            let url = item.url.standardizedFileURL

            guard url.deletingLastPathComponent() == downloadsURL else {
                failures.append((url, CocoaError(.fileNoSuchFile)))
                continue
            }

            do {
                let currentIdentifier = try url.resourceValues(forKeys: [.fileResourceIdentifierKey])
                    .fileResourceIdentifier as? Data

                guard let scannedIdentifier = item.fileResourceIdentifier,
                      currentIdentifier == scannedIdentifier else {
                    throw CocoaError(.fileReadUnknown)
                }

                try trashItem(url)
                sizeCache[url] = nil
                deleted += 1
            } catch {
                failures.append((url, error))
            }
        }

        if failures.isEmpty {
            sizeCache.removeAll()
        }

        return (deleted, failures)
    }
}

nonisolated struct DownloadsScanResult {
    var items: [DownloadsItem] = []
    var scanErrorMessage: String?
    var totalFiles: Int = 0
    var installerCount: Int = 0
    var archiveCount: Int = 0
    var pdfCount: Int = 0
    var screenshotCount: Int = 0
    var imageCount: Int = 0
    var folderCount: Int = 0
    var otherCount: Int = 0
    var totalSizeBytes: Int64 = 0
    var installerSizeBytes: Int64 = 0
    var archiveSizeBytes: Int64 = 0
    var pdfSizeBytes: Int64 = 0
    var screenshotSizeBytes: Int64 = 0
    var imageSizeBytes: Int64 = 0
    var folderSizeBytes: Int64 = 0
    var otherSizeBytes: Int64 = 0
}

nonisolated struct DownloadsItem: Sendable {
    let url: URL
    let fileResourceIdentifier: Data?
    let category: DownloadsCategory
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

nonisolated enum DownloadsCategory: String, CaseIterable, Sendable {
    case installer = "Installer"
    case archive = "Archive"
    case pdf = "PDF"
    case screenshot = "Screenshot"
    case image = "Image"
    case folder = "Folder"
    case other = "Other File"
}
