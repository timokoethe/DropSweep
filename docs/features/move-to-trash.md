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
- Only listed items directly inside the Downloads folder are moved to the Trash.
- Hidden contents inside a listed folder move with that folder.
- Contents with temporary download extensions inside a listed folder also move with that folder; the [scan exclusions](downloads-scanning.md#limitations) apply only to entries directly inside Downloads.
- Partial failures report how many items could not be moved and identify up to three of them.
