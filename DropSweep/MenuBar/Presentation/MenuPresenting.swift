import Foundation

/// The menu's modal presentation boundary. Tests can supply a presenter without
/// opening AppKit panels or System Settings.
@MainActor
protocol MenuPresenting {
    func showAboutPanel()
    func confirmMovingToTrash(itemCount: Int) -> Bool
    func showTrashError(deletedCount: Int, failures: [(url: URL, error: Error)])
    func showLaunchAtLoginApprovalRequired()
    func showLaunchAtLoginError(_ error: Error)
}
