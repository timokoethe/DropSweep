import AppKit
import ServiceManagement

@MainActor
struct LaunchAtLoginAlerts {
    func showApprovalRequired() {
        let alert = NSAlert()

        alert.messageText = "Launch at Login Needs Approval"
        alert.informativeText = "Allow DropSweep in Login Items in System Settings to launch it automatically when you sign in. Launch at Login will remain off until you approve it."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Not Now")

        if alert.runModal() == .alertFirstButtonReturn {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    func showError(_ error: Error) {
        let alert = NSAlert()

        alert.messageText = "Could Not Update Login Setting"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
