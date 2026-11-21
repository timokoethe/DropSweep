import AppKit

@MainActor
struct TrashAlerts {
    func confirm(itemCount: Int) -> Bool {
        let itemLabel = itemCount == 1 ? "item" : "items"
        let alert = NSAlert()

        alert.messageText = "Move \(itemCount) \(itemLabel) to the Trash?"
        alert.informativeText = "This moves only the selected items from Downloads to the Trash."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Move to Trash")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else {
            return false
        }

        return true
    }

    func showError(deletedCount: Int, failures: [(url: URL, error: Error)]) {
        let alert = NSAlert()
        let failedItems = failures
            .prefix(3)
            .map { $0.url.lastPathComponent }
            .joined(separator: "\n")
        let remainingItems = failures.count > 3 ? "\n…and \(failures.count - 3) more" : ""
        let failureReason = failures.allSatisfy { failure in
            (failure.error as NSError).code == NSFileNoSuchFileError
        } ? "They may have already been moved or deleted while the confirmation was open." : "Some items may have changed or could not be accessed."

        alert.messageText = "Some Items Could Not Be Moved to the Trash"
        alert.informativeText = "\(deletedCount) item\(deletedCount == 1 ? "" : "s") moved to the Trash. \(failures.count) item\(failures.count == 1 ? "" : "s") could not be moved.\n\(failureReason)\n\n\(failedItems)\(remainingItems)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
