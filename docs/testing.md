# Native macOS tests

The `DropSweepTests` target uses Swift Testing. In Xcode, select the shared
`DropSweep` scheme and choose **Product → Test** (`⌘U`). From the repository root:

```sh
xcodebuild -project DropSweep.xcodeproj -scheme DropSweep \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

To run one suite, append e.g. `-only-testing:DropSweepTests/SweeperDeletionTests`.
The app is built alongside the tests to check integration, but is not launched.

## Structure

- `DropSweepTests/Services/SweeperScanTests.swift`: empty/missing directories,
  counts and sizes, root exclusions, nested contents, completed downloads and rescans.
- `DropSweepTests/Services/SweeperClassificationTests.swift`: parameterized file
  extensions, screenshot precedence and directories with file-like names.
- `DropSweepTests/Services/SweeperDeletionTests.swift`: confirmed snapshots,
  file identity, scope restrictions and partial failures.
- `DropSweepTests/MenuBar/CategorySummaryTests.swift`: singular/plural titles,
  size summaries and stable identity. Formatting expectations use the current locale.
- `DropSweepTests/MenuBar/MenuViewModelTests.swift`: confirmed snapshots after
  rescans, category selection, selected-only cleanup, busy states, error recovery
  and cancellation of outdated scans. A partial-deletion integration test uses
  the fixture-backed Sweeper and captures error reporting through an injected
  handler, verifying the remaining selection and reset busy states without a modal alert.
- `DropSweepTests/Support/DownloadsFixture.swift`: unique temporary directories
  and a simulated Trash shared by the service suites.
- `DropSweepTests/Support/ControlledSweeper.swift`: a controllable implementation
  of `DownloadsSweeping` for ViewModel tests. Suspended operations are signaled via
  streams and explicitly completed by tests, without sleeps or polling.

## Isolation and extension

This is a hostless unit-test bundle. The target compiles the actual `Sweeper.swift`,
`CategorySummary.swift` and `MenuViewModel.swift` files directly, with the same Swift concurrency settings
as the app. Xcode lists those source references under **Tested Sources**; they are
references, not copies. This keeps tests independent of the menu-bar app lifecycle,
Sparkle startup and login-item registration without adding a framework or package.
New test files under `DropSweepTests/` are automatically included by Xcode.
For another production type, add its original source to the test target's Sources
phase, including any required dependencies.

Each service test creates its own `DownloadsFixture`. Its injected `Sweeper` uses
only that fixture's directory, and its trash operation moves files into another
fixture directory. Tests never call the real macOS Trash operation or scan the
user's Downloads. Fixtures remove their temporary root after use and can run in
parallel. Failure tests inject a throwing trash operation rather than relying on
filesystem permissions or system dialogs.

ViewModel tests inject `ControlledSweeper`, an explicit login status, and
`scanOnInit: false` to avoid reading system state or starting an uncontrolled scan.
Scan and deletion methods return discardable task handles so tests can await their
completion. Tests release pending continuations in `defer`, including on failures.

Keep assertions on observable behavior. Use real temporary files for scanning and
file-identity checks; inject external effects for deterministic failures. Preserve
an old file by moving it aside when testing replacement so inode reuse cannot make
the test ambiguous. Avoid sleeps and assumptions about directory enumeration order.

The suite covers filesystem logic and presentation summaries. The real macOS Trash,
confirmation UI, permissions, login items and Sparkle still need manual verification
as described in `docs/features/`.
