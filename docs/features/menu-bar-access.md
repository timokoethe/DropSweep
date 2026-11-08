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
- Category rows show a colored icon, title, item count, and right-aligned size; long category lists scroll above the fixed footer.
- A sort menu beside the Downloads summary switches between the original category order and either size direction; see [Category Sorting](category-sorting.md).
- The footer contains only the existing all-listed-items Trash action; totals appear once below Downloads. Confirmation still appears after clicking the button; no explanatory sentences appear below the Downloads summary or Trash button. Category rows are summaries, not selection controls.
- Refresh (Command-R) rescans Downloads; opening the panel also refreshes the scan unless a Trash operation is running.
- A gear menu exposes Launch at Login, Check for Updates, About, and Quit.
- Scanning, moving, empty-folder, and scan-error states have dedicated presentations.
- Compact spacing uses 16-point horizontal insets, 46-point category rows including separators, and a 22-point Downloads heading. The header has a 5-point bottom inset; category separators align with row text and stop 16 points before the right edge.

## Manual Verification

- Open and reopen the panel with empty Downloads and with mixed categories, including visible folders; check counts and sizes against Finder.
- Check light and dark appearance, keyboard navigation, Refresh, Open in Finder, and every gear-menu action.
- Cancel the Trash confirmation and verify nothing moves. With disposable test files, confirm and verify the same listed items move to Trash and the panel refreshes.
- Remove a test item while confirmation is open to exercise existing failure reporting. Verify hidden root items remain excluded.
