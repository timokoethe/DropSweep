---
status: implemented
area: menu-bar
platforms:
  - macos
---

# Category Sorting

## Purpose

Help users find the categories using the most Downloads space.

## User Story

As a user, I want to sort categories by their total size so that I can prioritize cleanup.

## Acceptance Criteria

- A sort menu next to the Downloads summary offers Category Order, Largest First, and Smallest First, with the current choice marked.
- Category Order is the initial default and preserves the existing category sequence.
- Size sorting compares each category's total byte size. Equal sizes retain the original category sequence.
- Changes apply immediately and persist across panel openings, rescans, and app restarts.
- Sorting changes presentation only. Selected categories, totals, and the confirmed files to move to Trash remain unchanged.
- The sort control has an accessibility label and announces its current choice.

## Manual Verification

- With disposable Downloads files in several categories, choose Largest First and Smallest First and check the total sizes are in the expected order.
- Select some categories and switch sorting; verify the same categories remain selected and the selected count and size do not change.
- Refresh, close and reopen the panel, and restart the app; verify the saved order remains selected.
- Choose Category Order and verify the original sequence returns. Check empty Downloads and a single category.
- Check the sort menu with keyboard navigation and VoiceOver, and verify the last row has no trailing separator in each order.
