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
- All categories are selected when the app starts. Changes remain in effect during the app session, including refreshes, reopening the menu, scan failures, and categories disappearing and returning.
- The footer shows the selected item count and combined size. The Downloads overview continues to show the totals for all listed items.
- The cleanup action is disabled when no listed items are selected, during scans, and during cleanup.
- Confirmation shows the selected item count and captures only selected items, including their scanned identities. Later scans or selection changes do not alter the confirmed snapshot.
- Unselected categories remain in Downloads. Selected folders move with all their contents, regardless of the categories of nested files.
- After cleanup, the list and selection summary refresh.

## Manual Verification

- Put files from several categories and a visible folder in Downloads. Verify all categories initially have checked boxes.
- Uncheck a category and verify the selected count and size decrease while the overview totals remain unchanged.
- Uncheck every visible category and verify cleanup is disabled. Check one category and verify it becomes available.
- Refresh and close/reopen the menu. Verify unchecked categories remain unchecked. Check keyboard navigation and that VoiceOver announces each checkbox label and state.
- Select only PDFs and screenshots, open confirmation, and verify its count. Cancel and verify nothing moves.
- Confirm the same selection and verify only those categories move to the macOS Trash. Verify the remaining list and selected totals refresh.
- Select a folder containing files from unselected categories and verify the whole folder moves to the Trash.
- Restart the app and verify all categories are selected again.
