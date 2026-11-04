import Foundation

/// Suspends operations until the test explicitly completes them.
@MainActor
final class ControlledSweeper: DownloadsSweeping {
    var scanResult = DownloadsScanResult()
    var suspendScans = false
    var suspendDeletion = false
    private(set) var deletionRequests: [[DownloadsItem]] = []

    let scanStarted: AsyncStream<Void>
    let deletionStarted: AsyncStream<Void>
    private let scanEvents: AsyncStream<Void>.Continuation
    private let deletionEvents: AsyncStream<Void>.Continuation
    private var pendingScans: [CheckedContinuation<DownloadsScanResult, Never>] = []
    private var pendingDeletions: [CheckedContinuation<Void, Never>] = []

    init() {
        (scanStarted, scanEvents) = AsyncStream.makeStream(of: Void.self)
        (deletionStarted, deletionEvents) = AsyncStream.makeStream(of: Void.self)
    }

    @MainActor func scanDownloadsFolder() async -> DownloadsScanResult {
        if suspendScans {
            return await withCheckedContinuation { continuation in
                pendingScans.append(continuation)
                scanEvents.yield(())
            }
        }
        return scanResult
    }

    @MainActor func deleteItemsInDownloads(_ items: [DownloadsItem]) async -> (deleted: Int, failures: [(url: URL, error: Error)]) {
        deletionRequests.append(items)
        if suspendDeletion {
            await withCheckedContinuation { continuation in
                pendingDeletions.append(continuation)
                deletionEvents.yield(())
            }
        } else {
            deletionEvents.yield(())
        }
        return (items.count, [])
    }

    func finishScan(at index: Int = 0, with result: DownloadsScanResult) {
        pendingScans.remove(at: index).resume(returning: result)
    }

    func finishDeletion() {
        if !pendingDeletions.isEmpty {
            pendingDeletions.removeFirst().resume()
        }
    }

    /// Always release suspended tasks, including when a test prerequisite fails.
    func finishPendingOperations() {
        suspendScans = false
        for continuation in pendingScans {
            continuation.resume(returning: DownloadsScanResult())
        }
        pendingScans.removeAll()
        for continuation in pendingDeletions {
            continuation.resume()
        }
        pendingDeletions.removeAll()
    }
}
