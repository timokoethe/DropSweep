import Foundation

@MainActor
final class RecordingMenuPresenter: MenuPresenting {
    var confirmsMovingToTrash = false
    private(set) var confirmationCounts: [Int] = []
    private(set) var aboutPanelCount = 0
    private(set) var trashErrors: [(deleted: Int, failures: [(url: URL, error: Error)])] = []
    private(set) var loginApprovalCount = 0
    private(set) var loginErrors: [Error] = []

    func showAboutPanel() {
        aboutPanelCount += 1
    }

    func confirmMovingToTrash(itemCount: Int) -> Bool {
        confirmationCounts.append(itemCount)
        return confirmsMovingToTrash
    }

    func showTrashError(deletedCount: Int, failures: [(url: URL, error: Error)]) {
        trashErrors.append((deletedCount, failures))
    }

    func showLaunchAtLoginApprovalRequired() {
        loginApprovalCount += 1
    }

    func showLaunchAtLoginError(_ error: Error) {
        loginErrors.append(error)
    }
}
