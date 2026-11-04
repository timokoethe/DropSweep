# DropSweep Agent Instructions

DropSweep is a small macOS menu-bar app that scans the user's Downloads folder, groups common clutter, and moves selected items to the Trash. The native app lives in `DropSweep/` and uses Swift 6, SwiftUI, AppKit, and the Observation framework.

## Public Repository Safety

This repository is public and DropSweep is a released product. Treat every committed file and all Git history as publicly accessible. Never add secrets, API keys, access tokens, credentials, signing material, private URLs, personal information, user data, or other sensitive values. Use documented placeholders and environment variables where configuration is required, and verify staged changes for accidental disclosures before committing.

## Project Shape

- `DropSweep/App/DropSweepApp.swift`: app entry point and `MenuBarExtra`.
- `DropSweep/MenuBar/`: menu UI, menu state, and menu-specific presentation models/components.
- `DropSweep/Services/Sweeper.swift`: Downloads scanning, classification, and trashing logic.
- `DropSweep/Updates/CheckForUpdatesViewModel.swift`: Sparkle update state.
- `DropSweep/Info.plist`: app bundle configuration.
- `docs/features/`: native macOS app feature documentation and its `_template.md`.
- `website/`: separate Next.js site; follow `website/AGENTS.md` before editing it.

## Development Guidelines

- Keep changes small and aligned with the existing Swift style.
- Prefer SwiftUI for menu UI and AppKit only for macOS-specific APIs such as `NSApplication`, `NSMenu`, `NSColor`, or file trashing behavior.
- Treat filesystem operations carefully. DropSweep targets the user's Downloads folder, so prefer `FileManager.trashItem` over permanent deletion and preserve failure reporting paths where possible.
- Do not broaden cleanup scope beyond Downloads unless the user explicitly asks for it.
- Hidden items directly in the Downloads root are intentionally skipped during scans and cleanup. Hidden contents inside a visible subfolder are moved to the Trash together with that folder; keep this behavior unless changing product requirements.
- Document each native macOS app feature in its own `docs/features/` Markdown file using `_template.md`. Do not document website features there.
- Avoid introducing an Xcode-project dependency or build-system change unless it is needed for the requested work.
- Releases are operated strictly one at a time. Before pushing another release tag or rerunning a release workflow, ensure the previous release has fully completed, including appcast publication and website deployment. Resolve partial failures first. This is a maintainer-enforced rule; the tag-scoped concurrency group does not serialize different tags. See `docs/release.md`.

## Verification

Use Xcode for normal development:

```sh
open DropSweep.xcodeproj
```

Useful command-line checks when available:

```sh
xcodebuild -project DropSweep.xcodeproj -scheme DropSweep build
```

The `DropSweepTests` target uses Swift Testing and runs without launching the app. Run it with `xcodebuild -project DropSweep.xcodeproj -scheme DropSweep -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test`. See `docs/testing.md` for the test structure and fixture conventions. For changes that affect scanning or deletion behavior, extend the relevant tests and include clear manual test steps for macOS integration where practical.
