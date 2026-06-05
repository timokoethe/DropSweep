# DropSweep Agent Instructions

DropSweep is a small macOS menu-bar app that scans the user's Downloads folder, groups common clutter, and moves selected items to the Trash. The native app lives in `DropSweep/` and uses Swift 6, SwiftUI, AppKit, and the Observation framework.

## Project Shape

- `DropSweep/DropSweepApp.swift`: app entry point and `MenuBarExtra`.
- `DropSweep/MenuView.swift`: menu UI.
- `DropSweep/MenuViewModel.swift`: observable UI state and app actions.
- `DropSweep/Sweeper.swift`: Downloads scanning, classification, and trashing logic.
- `website/`: separate Next.js site; follow `website/AGENTS.md` before editing it.

## Development Guidelines

- Keep changes small and aligned with the existing Swift style.
- Prefer SwiftUI for menu UI and AppKit only for macOS-specific APIs such as `NSApplication`, `NSMenu`, `NSColor`, or file trashing behavior.
- Treat filesystem operations carefully. DropSweep targets the user's Downloads folder, so prefer `FileManager.trashItem` over permanent deletion and preserve failure reporting paths where possible.
- Do not broaden cleanup scope beyond Downloads unless the user explicitly asks for it.
- Hidden files are intentionally skipped during scans and cleanup; keep that behavior unless changing product requirements.
- Avoid introducing an Xcode-project dependency or build-system change unless it is needed for the requested work.

## Verification

Use Xcode for normal development:

```sh
open DropSweep.xcodeproj
```

Useful command-line checks when available:

```sh
xcodebuild -project DropSweep.xcodeproj -scheme DropSweep build
```

There is no dedicated test target at the moment. For changes that affect scanning or deletion behavior, include clear manual test steps and cover empty Downloads, mixed file categories, folders, and trash failures where practical.
