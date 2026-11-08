---
status: implemented
area: menu-bar
platforms:
  - macos
---

# Menu Bar Access

## Purpose

Keep Downloads cleanup available without opening a regular app window.

## User Story

As a user, I want to access DropSweep from the menu bar so that I can quickly review and clean my Downloads folder.

## Acceptance Criteria

- DropSweep is accessible from its macOS menu bar icon.
- The menu shows the current Downloads summary and available app actions.
- The app can be quit from the menu or with Command-Q.
- The menu bar opens a 340-point-wide thick-material panel that follows system appearance; the app remains menu-bar-only without a Dock window.
- A Downloads heading shows the item count and total size, with an Open in Finder action.
- Category rows show a selection checkbox, colored icon, title, item count, and right-aligned size; long category lists scroll above the fixed footer.
- A sort menu beside the Downloads summary switches between the original category order and either size direction; see [Category Sorting](category-sorting.md).
- The footer shows the selected item count and combined size, a Select All or Deselect All button, and the Move Selection to Trash action. The Downloads overview shows totals for all listed items. Category choices are saved across app restarts; see [Category Selection](category-selection.md).
- Move Selection to Trash requires confirmation and moves only the confirmed selection. The action is disabled when no listed items are selected, during scans and cleanup, and after a scan error.
- Refresh (Command-R) rescans Downloads; opening the panel also refreshes the scan unless a Trash operation is running.
- A gear menu exposes Launch at Login, Check for Updates, About, and Quit.
- Scanning, moving, empty-folder, and scan-error states have dedicated presentations.
- Compact spacing uses 16-point horizontal insets, 46-point category rows including separators, and a 22-point Downloads heading. The header has a 5-point bottom inset; category separators align with row text and stop 16 points before the right edge.

## Manual Verification

- Open and reopen the panel with empty Downloads and with mixed categories, including visible folders; check counts and sizes against Finder.
- Check light and dark appearance, keyboard navigation, Refresh, Open in Finder, and every gear-menu action.
- Change category checkboxes and verify the selected count and size update while the Downloads totals stay unchanged. Check Select All and Deselect All, then restart the app and verify the selection is restored.
- Cancel the Trash confirmation and verify nothing moves. With disposable test files, confirm and verify only the selected items move to Trash and the panel refreshes.
- Remove a test item while confirmation is open to exercise existing failure reporting. Verify hidden root items remain excluded.
