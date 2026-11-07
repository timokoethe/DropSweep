import Foundation
import Testing

nonisolated struct SweeperScanTests {
    @Test func emptyDownloads() async throws {
        let fixture = try DownloadsFixture()
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.items.isEmpty)
        #expect(result.totalFiles == 0)
        #expect(result.folderCount == 0)
        #expect(result.totalSizeBytes == 0)
        #expect(result.scanErrorMessage == nil)
    }

    @Test func missingDirectoryReportsScanFailure() async throws {
        let fixture = try DownloadsFixture()
        try FileManager.default.removeItem(at: fixture.downloads)
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.scanErrorMessage == "Could not read Downloads folder.")
        #expect(result.items.isEmpty)
        #expect(result.totalSizeBytes == 0)
    }

    @Test(arguments: ["Unreadable", "Visible/Unreadable"])
    func unreadableFolderRejectsPartialScanAndRecovers(folderPath: String) async throws {
        let fixture = try DownloadsFixture()
        let folder = try fixture.folder(folderPath)
        try fixture.file("\(folderPath)/contents.txt", bytes: 42)
        try fixture.file("readable.pdf", bytes: 10)
        let sweeper = fixture.makeSweeper()
        let initial = await sweeper.scanDownloadsFolder()
        #expect(initial.totalSizeBytes == 52)
        #expect(initial.scanErrorMessage == nil)

        // Restore access before fixture cleanup, including when an assertion fails.
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: folder.path)
        }
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: folder.path)
        let failed = await sweeper.scanDownloadsFolder()
        #expect(failed.scanErrorMessage != nil)
        #expect(failed.items.isEmpty)
        #expect(failed.totalFiles == 0)
        #expect(failed.folderCount == 0)
        #expect(failed.totalSizeBytes == 0)

        try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: folder.path)
        let recovered = await sweeper.scanDownloadsFolder()
        #expect(recovered.scanErrorMessage == nil)
        #expect(recovered.items.count == 2)
        #expect(recovered.totalSizeBytes == 52)
    }

    @Test func mixedCategoriesHaveIndependentCountsAndSizes() async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("Installer.dmg", bytes: 11)
        try fixture.file("Archive.zip", bytes: 12)
        try fixture.file("Document.pdf", bytes: 13)
        try fixture.file("Screenshot.png", bytes: 14)
        try fixture.file("Photo.heic", bytes: 15)
        try fixture.file("Notes.txt", bytes: 16)
        try fixture.file("Folder/nested.txt", bytes: 17)
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.totalFiles == 6)
        #expect(result.folderCount == 1)
        #expect(result.items.count == 7)
        #expect(result.installerCount == 1 && result.installerSizeBytes == 11)
        #expect(result.archiveCount == 1 && result.archiveSizeBytes == 12)
        #expect(result.pdfCount == 1 && result.pdfSizeBytes == 13)
        #expect(result.screenshotCount == 1 && result.screenshotSizeBytes == 14)
        #expect(result.imageCount == 1 && result.imageSizeBytes == 15)
        #expect(result.otherCount == 1 && result.otherSizeBytes == 16)
        #expect(result.folderSizeBytes == 17)
        #expect(result.totalSizeBytes == 98)
        #expect(result.items.allSatisfy { $0.fileResourceIdentifier != nil })
    }

    @Test func hiddenRootEntriesAreExcludedButFolderContentsCount() async throws {
        let fixture = try DownloadsFixture()
        try fixture.file(".hidden", bytes: 100)
        try fixture.file(".hiddenFolder/file.txt", bytes: 100)
        try fixture.file("Visible/.hidden", bytes: 7)
        try fixture.file("Visible/Nested/file.part", bytes: 9)
        try fixture.folder("Empty")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(Set(result.items.map { $0.url.lastPathComponent }) == ["Visible", "Empty"])
        #expect(result.totalFiles == 0)
        #expect(result.folderCount == 2)
        #expect(result.folderSizeBytes == 16)
        #expect(result.totalSizeBytes == 16)
    }

    @Test(arguments: ["crdownload", "download", "part", "partial", "opdownload", "filepart", "CRDOWNLOAD"])
    func incompleteFilesAndBundlesAreExcluded(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("file.\(ext)", bytes: 20)
        try fixture.file("bundle.\(ext)/contents", bytes: 30)
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.items.isEmpty)
        #expect(result.totalFiles == 0)
        #expect(result.folderCount == 0)
        #expect(result.totalSizeBytes == 0)
    }

    @Test(arguments: ["", "Visible/"])
    func symlinksAreSkippedWithoutFollowingExternalTargets(prefix: String) async throws {
        let fixture = try DownloadsFixture()
        // Targets are outside simulated Downloads, but remain inside the fixture.
        let externalFile = fixture.root.appendingPathComponent("external.txt")
        let externalFolder = fixture.root.appendingPathComponent("External", isDirectory: true)
        try Data(repeating: 0x62, count: 100).write(to: externalFile)
        try FileManager.default.createDirectory(at: externalFolder, withIntermediateDirectories: true)
        try Data(repeating: 0x63, count: 200).write(to: externalFolder.appendingPathComponent("nested.txt"))
        try fixture.symlink("\(prefix)file-link.txt", to: externalFile)
        try fixture.symlink("\(prefix)folder-link", to: externalFolder)
        let broken = try fixture.symlink("\(prefix)broken-link", to: fixture.root.appendingPathComponent("missing"))
        try fixture.file("\(prefix)local.txt", bytes: 7)

        let result = await fixture.makeSweeper().scanDownloadsFolder()

        #expect(result.scanErrorMessage == nil)
        #expect(result.items.map { $0.url.lastPathComponent } == [prefix.isEmpty ? "local.txt" : "Visible"])
        #expect(result.totalFiles == (prefix.isEmpty ? 1 : 0))
        #expect(result.folderCount == (prefix.isEmpty ? 0 : 1))
        #expect(result.folderSizeBytes == (prefix.isEmpty ? 0 : 7))
        #expect(result.totalSizeBytes == 7)
        // fileExists follows links, so inspect the link itself for a dangling target.
        #expect(try FileManager.default.destinationOfSymbolicLink(atPath: broken.path) == fixture.root.appendingPathComponent("missing").path)
    }

    @Test func completedDownloadAppearsOnNextScan() async throws {
        let fixture = try DownloadsFixture()
        let incomplete = try fixture.file("archive.zip.download", bytes: 21)
        let sweeper = fixture.makeSweeper()
        let first = await sweeper.scanDownloadsFolder()
        #expect(first.items.isEmpty)
        try FileManager.default.moveItem(at: incomplete, to: fixture.downloads.appendingPathComponent("archive.zip"))
        let second = await sweeper.scanDownloadsFolder()
        #expect(second.archiveCount == 1)
        #expect(second.archiveSizeBytes == 21)
    }

    @Test func repeatedScansReflectChangedRemovedAndRecreatedFiles() async throws {
        let fixture = try DownloadsFixture()
        let url = try fixture.file("file.txt", bytes: 4)
        let sweeper = fixture.makeSweeper()
        let first = await sweeper.scanDownloadsFolder()
        #expect(first.totalSizeBytes == 4)
        try fixture.file("file.txt", bytes: 40)
        let changed = await sweeper.scanDownloadsFolder()
        #expect(changed.totalSizeBytes == 40)
        try FileManager.default.removeItem(at: url)
        let removed = await sweeper.scanDownloadsFolder()
        #expect(removed.items.isEmpty)
        #expect(removed.totalSizeBytes == 0)
        try fixture.file("file.txt", bytes: 8)
        let recreated = await sweeper.scanDownloadsFolder()
        #expect(recreated.totalSizeBytes == 8)
    }
}
