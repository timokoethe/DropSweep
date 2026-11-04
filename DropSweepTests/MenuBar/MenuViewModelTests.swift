import Foundation
import Testing

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MenuViewModelTests {
    @Test func scanUpdatesSummaryAndErrorState() async {
        let service = ControlledSweeper()
        let model = makeModel(service)
        #expect(model.deleteDownloads([]) == nil)
        service.scanResult = result("document.pdf")
        let task = model.scanDownloadsFolder()
        #expect(model.isScanning)
        #expect(!model.canDeleteDownloads)
        #expect(model.itemsForDeletionConfirmation() == nil)
        await task.value
        #expect(!model.isScanning)
        #expect(model.canDeleteDownloads)
        #expect(model.itemsCount == 1)
        #expect(model.totalSizeBytes == 10)
        #expect(model.categories.map(\.displayTitle) == ["PDF"])
        #expect(model.categories.first?.sizeBytes == 10)

        service.scanResult = DownloadsScanResult(scanErrorMessage: "Scan failed")
        await model.scanDownloadsFolder().value
        #expect(model.scanErrorMessage == "Scan failed")
        #expect(!model.isScanning)
        #expect(!model.canDeleteDownloads)
        #expect(model.categories.isEmpty)
        #expect(model.itemsCount == 0)
        #expect(model.totalSizeBytes == 0)

        service.scanResult = result("recovered.pdf")
        await model.scanDownloadsFolder().value
        #expect(model.scanErrorMessage == nil)
        #expect(model.canDeleteDownloads)
    }

    @Test func deletionUsesConfirmedSnapshotAndResetsBusyStateAfterRescan() async throws {
        let service = ControlledSweeper()
        defer { service.finishPendingOperations() }
        let model = makeModel(service)
        service.scanResult = result("confirmed.pdf")
        await model.scanDownloadsFolder().value
        let confirmed = try #require(model.itemsForDeletionConfirmation())
        try #require(confirmed.count == 1)

        service.scanResult = result("new.pdf")
        await model.scanDownloadsFolder().value
        #expect(model.itemsForDeletionConfirmation()?.first?.url.lastPathComponent == "new.pdf")

        service.suspendDeletion = true
        var deletions = service.deletionStarted.makeAsyncIterator()
        let task = try #require(model.deleteDownloads(confirmed))
        _ = await deletions.next()
        #expect(service.deletionRequests.count == 1)
        #expect(service.deletionRequests.first?.map(\.url) == confirmed.map(\.url))
        #expect(service.deletionRequests.first?.map(\.fileResourceIdentifier) == confirmed.map(\.fileResourceIdentifier))
        #expect(model.isDeleting && model.isScanning)
        #expect(!model.canDeleteDownloads)
        #expect(model.itemsForDeletionConfirmation() == nil)
        #expect(model.deleteDownloads(confirmed) == nil)
        #expect(model.deleteDownloads([]) == nil)

        // Busy state must remain set until the post-deletion scan completes.
        service.suspendScans = true
        var scans = service.scanStarted.makeAsyncIterator()
        service.finishDeletion()
        _ = await scans.next()
        #expect(model.isDeleting && model.isScanning)
        service.finishScan(with: DownloadsScanResult())
        await task.value
        #expect(!model.isDeleting && !model.isScanning)
        #expect(model.itemsCount == 0)
        #expect(model.categories.isEmpty)
        #expect(!model.canDeleteDownloads)
        #expect(service.deletionRequests.count == 1)
    }

    @Test(arguments: [true, false])
    func cancelledScanCannotOverwriteNewScanOrClearItsBusyState(oldFinishesFirst: Bool) async {
        let service = ControlledSweeper()
        defer { service.finishPendingOperations() }
        service.suspendScans = true
        var scans = service.scanStarted.makeAsyncIterator()
        let model = makeModel(service)
        let old = model.scanDownloadsFolder()
        _ = await scans.next()
        let current = model.scanDownloadsFolder()
        _ = await scans.next()

        if oldFinishesFirst {
            service.finishScan(with: result("obsolete.pdf"))
            await old.value
            #expect(model.isScanning)
            #expect(model.itemsCount == 0)
        }
        service.finishScan(at: oldFinishesFirst ? 0 : 1, with: result("current.pdf"))
        await current.value
        if !oldFinishesFirst {
            service.finishScan(with: result("obsolete.pdf"))
            await old.value
        }
        #expect(!model.isScanning)
        #expect(model.itemsForDeletionConfirmation()?.first?.url.lastPathComponent == "current.pdf")
    }

    @Test func deletionCancelsPendingScan() async throws {
        let service = ControlledSweeper()
        defer { service.finishPendingOperations() }
        let model = makeModel(service)
        service.scanResult = result("confirmed.pdf")
        await model.scanDownloadsFolder().value
        let confirmed = try #require(model.itemsForDeletionConfirmation())
        try #require(confirmed.count == 1)
        service.suspendScans = true
        var scans = service.scanStarted.makeAsyncIterator()
        let pendingScan = model.scanDownloadsFolder()
        _ = await scans.next()
        service.suspendDeletion = true
        var deletions = service.deletionStarted.makeAsyncIterator()
        let deletion = try #require(model.deleteDownloads(confirmed))
        _ = await deletions.next()

        service.finishScan(with: result("obsolete.pdf"))
        await pendingScan.value
        #expect(model.isScanning && model.isDeleting)
        #expect(model.itemsCount == 1)
        #expect(model.itemsForDeletionConfirmation() == nil)

        service.suspendScans = false
        service.scanResult = DownloadsScanResult()
        service.finishDeletion()
        await deletion.value
        #expect(!model.isScanning && !model.isDeleting)
        #expect(model.itemsCount == 0)
    }

    @Test func categorySelectionOnlyTrashesConfirmedCategories() async throws {
        let fixture = try DownloadsFixture()
        let files: [(name: String, category: DownloadsCategory, bytes: Int)] = [
            ("installer.dmg", .installer, 100), ("archive.zip", .archive, 200),
            ("document.pdf", .pdf, 30), ("second.pdf", .pdf, 70),
            ("Screenshot.png", .screenshot, 40), ("photo.png", .image, 500),
            ("Folder.pdf/nested.txt", .folder, 60), ("notes.txt", .other, 800)
        ]
        for file in files {
            try fixture.file(file.name, bytes: file.bytes)
        }
        let model = MenuViewModel(sweeper: fixture.makeSweeper(), launchAtLoginEnabled: false, scanOnInit: false)
        await model.scanDownloadsFolder().value
        let allItems = try #require(model.itemsForDeletionConfirmation())
        #expect(allItems.count == 8)
        #expect(Set(allItems.map(\.category)) == Set(DownloadsCategory.allCases))

        // Each category must select the right paths, not merely a matching count.
        for category in DownloadsCategory.allCases {
            model.selectedCategories = [category]
            let expected = files.filter { $0.category == category }
            let selected = try #require(model.itemsForDeletionConfirmation())
            let expectedNames = Set(expected.map { String($0.name.split(separator: "/")[0]) })
            #expect(Set(selected.map { $0.url.lastPathComponent }) == expectedNames)
            #expect(model.selectedItemsCount == expected.count)
        }

        model.selectedCategories = [.pdf, .screenshot, .folder]
        #expect(model.selectedItemsCount == 4)
        let selectedSize = ByteCountFormatter.string(fromByteCount: 200, countStyle: .file)
        #expect(model.selectionSummary == "4 items selected · \(selectedSize)")
        #expect(model.itemsCount == 8)
        #expect(model.totalSizeBytes == 1800)
        let confirmed = try #require(model.itemsForDeletionConfirmation())
        #expect(Set(confirmed.map { $0.url.lastPathComponent }) == ["document.pdf", "second.pdf", "Screenshot.png", "Folder.pdf"])
        // Later selection changes must not alter the confirmed snapshot.
        model.selectedCategories = [.image]
        await (try #require(model.deleteDownloads(confirmed))).value
        #expect(model.itemsCount == 4)
        #expect(model.selectedItemsCount == 1)
        let imageSize = ByteCountFormatter.string(fromByteCount: 500, countStyle: .file)
        #expect(model.selectionSummary == "1 item selected · \(imageSize)")
        for file in files {
            let wasSelected = [DownloadsCategory.pdf, .screenshot, .folder].contains(file.category)
            #expect(fixture.exists(fixture.downloads.appendingPathComponent(file.name)) == !wasSelected)
        }
        #expect(fixture.exists(fixture.trash.appendingPathComponent("Folder.pdf/nested.txt")))
    }

    @Test func emptySelectionDisablesCleanupAndSurvivesRescans() async {
        let service = ControlledSweeper()
        let model = makeModel(service)
        service.scanResult = result("document.pdf")
        await model.scanDownloadsFolder().value
        #expect(model.selectedItemsCount == 1)
        #expect(model.selectionSummary == "1 item selected · \(model.totalDisplaySize)")
        model[isSelected: .pdf] = false
        #expect(!model.canDeleteDownloads)
        #expect(model.selectedItemsCount == 0)
        let emptySize = ByteCountFormatter.string(fromByteCount: 0, countStyle: .file)
        #expect(model.selectionSummary == "0 items selected · \(emptySize)")
        #expect(model.itemsForDeletionConfirmation() == nil)

        // Keep the choice even when the category disappears or a scan fails.
        service.scanResult = DownloadsScanResult()
        await model.scanDownloadsFolder().value
        service.scanResult = DownloadsScanResult(scanErrorMessage: "Scan failed")
        await model.scanDownloadsFolder().value
        service.scanResult = result("new.pdf")
        await model.scanDownloadsFolder().value
        #expect(!model[isSelected: .pdf])
        #expect(!model.canDeleteDownloads)
        model[isSelected: .pdf] = true
        #expect(model.canDeleteDownloads)
        #expect(model.itemsForDeletionConfirmation()?.first?.url.lastPathComponent == "new.pdf")
    }

    private func makeModel(_ service: ControlledSweeper) -> MenuViewModel {
        MenuViewModel(sweeper: service, launchAtLoginEnabled: false, scanOnInit: false)
    }

    private func result(_ name: String) -> DownloadsScanResult {
        DownloadsScanResult(
            items: [DownloadsItem(url: URL(fileURLWithPath: "/test-downloads/\(name)"), fileResourceIdentifier: Data(name.utf8), category: .pdf)],
            totalFiles: 1,
            pdfCount: 1,
            totalSizeBytes: 10,
            pdfSizeBytes: 10
        )
    }
}
