---
status: implemented
area: cleanup
platforms:
  - macos
---

# Category Selection

## Purpose

Let users choose which Downloads categories to move to the Trash.

## User Story

As a user, I want to select categories with checkboxes so that I can remove clutter while keeping other downloads.

## Acceptance Criteria

- Each nonempty category has a checkbox that selects all listed top-level items in that category.
- All categories are selected on first launch. Changes are saved automatically and restored on subsequent app launches, including an empty selection. Choices remain in effect during refreshes, reopening the menu, scan failures, and categories disappearing and returning. Newly introduced categories remain unselected when restoring an existing selection.
- The footer shows the selected item count and combined size. The Downloads overview continues to show the totals for all listed items.
- A footer button shows **Deselect All** when every visible category is selected, otherwise **Select All**. It clears the entire saved selection or selects every category, including categories currently absent from Downloads. Bulk changes are saved like individual checkbox changes.
- Bulk selection is disabled during scans and cleanup, after scan errors, and when Downloads is empty.
- The cleanup action is disabled when no listed items are selected, during scans, and during cleanup.
- Confirmation shows the selected item count and captures only selected items, including their scanned identities. Later scans or selection changes do not alter the confirmed snapshot.
- Unselected categories remain in Downloads. Selected folders move with all their contents, regardless of the categories of nested files.
- After cleanup, the list and selection summary refresh.

## Manual Verification

- Put files from several categories and a visible folder in Downloads. On a fresh preferences domain, verify all categories initially have checked boxes.
- Uncheck a category and verify the selected count and size decrease while the overview totals remain unchanged.
- Click **Select All** from a partial or empty selection and verify every checkbox is checked and the selected totals match the overview. Click **Deselect All** and verify every checkbox is cleared and cleanup is disabled. Repeat when only one category is visible; quit and relaunch after each bulk action to verify persistence.
- Verify the bulk selection button is disabled while scanning or moving items, with empty Downloads, and after a scan error. Check keyboard navigation and VoiceOver for both button labels.
- Uncheck every visible category and verify cleanup is disabled. Check one category and verify it becomes available.
- Refresh and close/reopen the menu. Verify unchecked categories remain unchecked. Check keyboard navigation and that VoiceOver announces each checkbox label and state.
- Select only PDFs and screenshots, open confirmation, and verify its count. Cancel and verify nothing moves.
- Confirm the same selection and verify only those categories move to the macOS Trash. Verify the remaining list and selected totals refresh.
- Select a folder containing files from unselected categories and verify the whole folder moves to the Trash.
- Uncheck some categories, quit with Quit DropSweep, and relaunch. Verify the same categories remain unchecked, including any that disappeared and returned in Downloads.
- Uncheck every category, quit, and relaunch. Verify no categories are selected and cleanup remains disabled. Recheck a category, restart again, and verify that change is also restored.
