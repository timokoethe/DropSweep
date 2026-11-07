import Foundation

/// Each test owns a unique directory; cleanup never touches the user's Downloads or Trash.
nonisolated final class DownloadsFixture: Sendable {
    let root: URL
    let downloads: URL
    let trash: URL

    init() throws {
        root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().appendingPathComponent("DropSweepTests-\(UUID())", isDirectory: true)
        downloads = root.appendingPathComponent("Downloads", isDirectory: true)
        trash = root.appendingPathComponent("Trash", isDirectory: true)
        try FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    @discardableResult
    func file(_ name: String, bytes: Int = 10) throws -> URL {
        let url = downloads.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(repeating: 0x61, count: bytes).write(to: url)
        return url
    }

    @discardableResult
    func folder(_ name: String) throws -> URL {
        let url = downloads.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @discardableResult
    func symlink(_ name: String, to destination: URL) throws -> URL {
        let url = downloads.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: url, withDestinationURL: destination)
        return url
    }

    func makeSweeper(failingNames: Set<String> = []) -> Sweeper {
        let trash = trash
        return Sweeper(downloadsURL: downloads) { url in
            if failingNames.contains(url.lastPathComponent) {
                throw CocoaError(.fileWriteNoPermission)
            }
            try FileManager.default.moveItem(at: url, to: trash.appendingPathComponent(url.lastPathComponent))
        }
    }

    func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}
