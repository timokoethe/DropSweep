import Foundation

@MainActor
struct MenuPresenter: MenuPresenting {
    func showAboutPanel() {
        AboutPanel().show()
    }

    func confirmMovingToTrash(itemCount: Int) -> Bool {
        TrashAlerts().confirm(itemCount: itemCount)
    }

    func showTrashError(deletedCount: Int, failures: [(url: URL, error: Error)]) {
        TrashAlerts().showError(deletedCount: deletedCount, failures: failures)
    }

    func showLaunchAtLoginApprovalRequired() {
        LaunchAtLoginAlerts().showApprovalRequired()
    }

    func showLaunchAtLoginError(_ error: Error) {
        LaunchAtLoginAlerts().showError(error)
    }
}
