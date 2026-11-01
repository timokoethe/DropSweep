---
status: implemented
area: cleanup
platforms:
  - macos
---

# Move Downloads to Trash

## Purpose

Clean the Downloads folder while keeping removed items recoverable through the macOS Trash.

## User Story

As a user, I want to move the listed Downloads items to the Trash so that I can clear clutter safely.

## Acceptance Criteria

- The cleanup action is available only when listed items can be removed.
- Confirmation is required before any items are moved.
- The confirmation captures the current list of items, including their file identities, before opening. Both its item count and the subsequent cleanup use that same snapshot, even if a scan refreshes the menu while confirmation is open.
- New top-level items found after confirmation opens are not added to that cleanup. Missing or replaced items from the snapshot are reported as failures; replacements are not moved.
- Only listed items directly inside the Downloads folder are moved to the Trash.
- Hidden contents inside a listed folder move with that folder.
- Contents with temporary download extensions inside a listed folder also move with that folder; the [scan exclusions](downloads-scanning.md#limitations) apply only to entries directly inside Downloads.
- Partial failures report how many items could not be moved and identify up to three of them.

## Manual Verification

- With empty Downloads, verify cleanup is disabled and no confirmation appears.
- With a mix of files and a visible folder, open confirmation and verify its count matches the listed top-level items. Cancel and verify nothing moves.
- Open confirmation, then add a new top-level file in Finder. Confirm cleanup and verify only the original items move; the new file remains after the rescan. Also cover a menu rescan during confirmation when practical.
- Open confirmation, then move an original item elsewhere and create a replacement at the same path. Confirm and verify the replacement remains and a partial-failure alert appears.
- Verify hidden root items remain and a visible folder moves together with its hidden contents.
- Where practical, make an original item inaccessible before confirming and verify other original items still move and the failure is reported.
