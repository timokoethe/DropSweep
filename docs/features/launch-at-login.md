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
- If enabling Launch at Login requires approval in System Settings, the app explains the pending approval and offers to open the Login Items settings.
- The toggle stays off until macOS reports the login item as enabled. Its state refreshes when the menu opens.
- Enabling an item that is already awaiting approval shows the same guidance without registering it again.
- Dismissing the approval guidance leaves the registration pending and does not open System Settings.
- A failure to change the setting is shown to the user.

## Manual Verification

- Enable Launch at Login when no additional approval is required and verify the toggle turns on; disable it and verify it turns off.
- With macOS reporting that DropSweep requires approval (for example, after revoking its permission in Login Items), enable Launch at Login and verify the explanation appears while the toggle stays off.
- Choose Not Now and verify System Settings does not open. Enable Launch at Login again and verify the guidance reappears without a registration error.
- Choose Open System Settings and verify the Login Items settings open. Approve DropSweep, reopen its menu, and verify the toggle turns on.
- Where practical, cause registration or unregistration to fail and verify the existing error alert appears and the toggle reflects the actual macOS status.
