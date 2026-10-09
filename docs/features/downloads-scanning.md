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
- Files and folders directly inside Downloads are included unless excluded by the rules below.
- Hidden items at the Downloads root are skipped.
- Files and folders directly inside Downloads with `.crdownload`, `.download`, `.part`, `.partial`, `.opdownload`, or `.filepart` extensions are skipped, case-insensitively. These entries do not contribute to counts, sizes, categories, or the cleanup list, regardless of whether a download is still active.
- Once an entry is renamed to a visible filename without an excluded extension, it is included on the next scan.
- A scan failure is shown in the menu.

## Manual Verification

- With empty Downloads, verify that no items or categories appear.
- Add a PDF, an image, a ZIP archive, and a normal visible folder. Verify their counts and sizes are included.
- Add files ending in each excluded extension, including an uppercase `.CRDOWNLOAD`, and a visible folder ending in `.download` with contents. Verify none contribute to the summary or categories.
- Rename a temporary download to its completed filename, reopen the menu, and verify it now appears in its normal category.
- Move the listed test items to the Trash and verify entries with the excluded extensions directly inside Downloads remain untouched. Verify hidden root items also remain untouched and hidden contents inside a normal listed folder move with that folder.
- Add a `.crdownload` test file inside a normal visible folder. Verify its size contributes to the folder size and that it moves with the folder when cleanup is confirmed.
- Where practical, make a listed test item inaccessible before confirming cleanup and verify the existing partial-failure alert still appears.

## Limitations

- The filter uses only the six listed filename extensions, not browser process state. Active downloads with other extensions or written directly to a final filename are not excluded. Abandoned temporary downloads with a listed extension remain excluded.
- The filter applies only to entries directly inside Downloads. A normal visible folder is treated as one cleanup item: incomplete downloads inside it still contribute to its size and move to the Trash with the folder. This feature does not guarantee protection of every active download.
