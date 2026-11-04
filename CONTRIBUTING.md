# Contributing to DropSweep

Thanks for helping improve DropSweep.

## Getting Started

For signed builds, copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig`
and set your team ID and bundle identifier. The local file is ignored by Git.

Open the project in Xcode and run the `DropSweep` scheme:

```sh
open DropSweep.xcodeproj
```

Alternatively, build without signing:

```sh
xcodebuild -project DropSweep.xcodeproj -scheme DropSweep CODE_SIGNING_ALLOWED=NO build
```

Run native tests with **Product → Test** (`⌘U`); see the [testing guide](docs/testing.md).
For website changes, follow the [website setup](website/README.md) and run `npm run lint` and `npm run build` from `website/`.

## Guidelines

- Keep pull requests small and focused.
- Follow the existing Swift and SwiftUI style.
- Be careful with file system changes. DropSweep works with the user's Downloads folder.
- Prefer moving files to the Trash over permanent deletion.
- Add or update the corresponding file in [`docs/features/`](docs/features/) when changing a native app feature; use [`_template.md`](docs/features/_template.md) for new features.
- Include clear manual test steps in your pull request.
- Label website-only pull requests `website` to exclude them from app release notes.

## Issues

Use GitHub Issues for bugs and feature requests. Please include your DropSweep version, macOS version, and steps to reproduce.

For security issues, follow [SECURITY.md](SECURITY.md).

## Releases

Maintainers should follow the documented [release process](docs/release.md) when publishing a new version of DropSweep.
