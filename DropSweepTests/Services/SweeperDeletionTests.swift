import Foundation
import Testing

nonisolated struct SweeperDeletionTests {
    @Test func onlyConfirmedSnapshotMovesIncludingFolderContents() async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("confirmed.pdf")
        try fixture.file("Folder/.hidden")
        try fixture.file("Folder/active.part")
        let hidden = try fixture.file(".hidden")
        let incomplete = try fixture.file("active.download")
        let sweeper = fixture.makeSweeper()
        let snapshot = await sweeper.scanDownloadsFolder()
        let newFile = try fixture.file("new.txt")
        // A later scan must not change the previously confirmed snapshot.
        _ = await sweeper.scanDownloadsFolder()
        let result = await sweeper.deleteItemsInDownloads(snapshot.items)
        #expect(result.deleted == 2)
        #expect(result.failures.isEmpty)
        #expect(fixture.exists(fixture.trash.appendingPathComponent("confirmed.pdf")))
        #expect(fixture.exists(fixture.trash.appendingPathComponent("Folder/.hidden")))
        #expect(fixture.exists(fixture.trash.appendingPathComponent("Folder/active.part")))
        #expect(fixture.exists(newFile))
        #expect(fixture.exists(hidden))
        #expect(fixture.exists(incomplete))
        let remaining = await sweeper.scanDownloadsFolder()
        #expect(remaining.items.map { $0.url.lastPathComponent } == ["new.txt"])
        #expect(remaining.totalSizeBytes == 10)
    }

    @Test func partialTrashFailurePreservesFailedItemAndContinues() async throws {
        let fixture = try DownloadsFixture()
        let failed = try fixture.file("blocked.txt", bytes: 13)
        try fixture.file("before.txt", bytes: 3)
        try fixture.file("after.txt", bytes: 7)
        let sweeper = fixture.makeSweeper(failingNames: ["blocked.txt"])
        let snapshot = await sweeper.scanDownloadsFolder()
        #expect(snapshot.items.count == 3)
        let orderedItems = try ["before.txt", "blocked.txt", "after.txt"].map { name in
            try #require(snapshot.items.first { $0.url.lastPathComponent == name })
        }
        let result = await sweeper.deleteItemsInDownloads(orderedItems)
        #expect(result.deleted == 2)
        #expect(result.failures.map { $0.url.lastPathComponent } == ["blocked.txt"])
        #expect((result.failures.first?.error as? CocoaError)?.code == .fileWriteNoPermission)
        #expect(fixture.exists(failed))
        #expect(fixture.exists(fixture.trash.appendingPathComponent("before.txt")))
        #expect(fixture.exists(fixture.trash.appendingPathComponent("after.txt")))
        let remaining = await sweeper.scanDownloadsFolder()
        #expect(remaining.totalFiles == 1)
        #expect(remaining.totalSizeBytes == 13)
    }

    @Test func replacedFileIsRejected() async throws {
        let fixture = try DownloadsFixture()
        let url = try fixture.file("original.txt")
        let sweeper = fixture.makeSweeper()
        let snapshot = await sweeper.scanDownloadsFolder()
        // Keep the old inode alive so the replacement cannot reuse its identity.
        try FileManager.default.moveItem(at: url, to: fixture.root.appendingPathComponent("moved-original.txt"))
        try fixture.file("original.txt", bytes: 20)
        let result = await sweeper.deleteItemsInDownloads(snapshot.items)
        #expect(result.deleted == 0)
        #expect(result.failures.count == 1)
        #expect(fixture.exists(url))
        #expect(!fixture.exists(fixture.trash.appendingPathComponent("original.txt")))
    }

    @Test func missingFileIsReported() async throws {
        let fixture = try DownloadsFixture()
        let url = try fixture.file("missing.txt")
        let sweeper = fixture.makeSweeper()
        let snapshot = await sweeper.scanDownloadsFolder()
        try #require(snapshot.items.count == 1)
        let scannedItem = try #require(snapshot.items.first)
        try #require(scannedItem.fileResourceIdentifier != nil)
        try FileManager.default.removeItem(at: url)
        let result = await sweeper.deleteItemsInDownloads(snapshot.items)
        #expect(result.deleted == 0)
        #expect(result.failures.count == 1)
        #expect(result.failures.first?.url == scannedItem.url.standardizedFileURL)
    }

    @Test func itemsWithoutScannedIdentityAreRejected() async throws {
        let fixture = try DownloadsFixture()
        let url = try fixture.file("unverified.txt")
        let result = await fixture.makeSweeper().deleteItemsInDownloads([
            DownloadsItem(url: url, fileResourceIdentifier: nil, category: .other)
        ])
        #expect(result.deleted == 0)
        #expect(result.failures.count == 1)
        #expect(fixture.exists(url))
    }

    @Test func pathsOutsideDownloadsAndNestedItemsAreRejected() async throws {
        let fixture = try DownloadsFixture()
        let nested = try fixture.file("Folder/nested.txt")
        let outside = fixture.root.appendingPathComponent("outside.txt")
        try Data("outside".utf8).write(to: outside)
        let traversal = fixture.downloads.appendingPathComponent("../outside.txt")
        let items = try [nested, outside, traversal].map { url in
            DownloadsItem(
                url: url,
                fileResourceIdentifier: try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier as? Data,
                category: .other
            )
        }
        let result = await fixture.makeSweeper().deleteItemsInDownloads(items)
        #expect(result.deleted == 0)
        #expect(result.failures.count == 3)
        #expect(fixture.exists(nested))
        #expect(fixture.exists(outside))
    }

    @Test func emptyConfirmationDoesNothing() async throws {
        let fixture = try DownloadsFixture()
        let url = try fixture.file("untouched.txt")
        let result = await fixture.makeSweeper().deleteItemsInDownloads([])
        #expect(result.deleted == 0)
        #expect(result.failures.isEmpty)
        #expect(fixture.exists(url))
    }
}
