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

    private func makeModel(_ service: ControlledSweeper) -> MenuViewModel {
        MenuViewModel(sweeper: service, launchAtLoginEnabled: false, scanOnInit: false)
    }

    private func result(_ name: String) -> DownloadsScanResult {
        DownloadsScanResult(
            items: [DownloadsItem(url: URL(fileURLWithPath: "/test-downloads/\(name)"), fileResourceIdentifier: Data(name.utf8))],
            totalFiles: 1,
            pdfCount: 1,
            totalSizeBytes: 10,
            pdfSizeBytes: 10
        )
    }
}
