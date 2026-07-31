---
status: implemented
area: app-lifecycle
platforms:
  - macos
---

# Launch at Login

## Purpose

Make DropSweep available automatically after the user signs in to their Mac.

## User Story

As a user, I want DropSweep to launch at login so that it is ready in the menu bar without manual setup each time.

## Acceptance Criteria

- Launch at Login can be enabled or disabled from the DropSweep menu.
- The toggle reflects the current macOS login-item state.
- A failure to change the setting is shown to the user.
