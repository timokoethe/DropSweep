---
status: implemented
area: downloads
platforms:
  - macos
---

# Downloads Scanning

## Purpose

Identify the items currently stored in the user's Downloads folder.

## User Story

As a user, I want DropSweep to scan my Downloads folder so that I can see what can be cleaned up.

## Acceptance Criteria

- The Downloads folder is scanned when DropSweep starts and whenever its menu opens.
- Files and folders directly inside Downloads are included.
- Hidden items at the Downloads root are skipped.
- A scan failure is shown in the menu.
