---
status: implemented
area: downloads
platforms:
  - macos
---

# Download Categories

## Purpose

Make common Downloads clutter easy to understand at a glance.

## User Story

As a user, I want my Downloads grouped by type so that I can quickly understand what occupies the folder.

## Acceptance Criteria

- Items are grouped as installers, archives, PDFs, screenshots, images, folders, or other files.
- Empty categories are omitted.
- Each visible category shows its item count and its combined size when greater than zero.
- The menu shows the total item count and the total size when greater than zero.
- Images include PNG, JPG/JPEG, SVG, GIF, WebP, HEIC/HEIF, TIF/TIFF, BMP, AVIF, and ICO files, with case-insensitive extensions.
- PNG and JPG/JPEG files whose names contain “screenshot”, “bildschirmfoto”, or “cleanshot” remain in Screenshots and are not counted again in Images.
- Unrecognized file types, such as ICS calendar files, remain in Other Files.

## Manual Verification

- With empty Downloads, verify that no category rows appear.
- Add ordinary PNG, uppercase JPG, SVG, a named screenshot PNG, PDF, ICS, and a visible folder. Verify that images, screenshots, PDFs, other files, and folders appear separately and their counts and sizes add up to the total.
- With only 13 ordinary PNG files, 4 SVG files, and 1 ICS file, expect Images: 17 items and Other File: 1 item.
- Confirm that hidden root items stay excluded and that moving listed items to the Trash still reports any failures.
