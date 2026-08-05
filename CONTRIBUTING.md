# Contributing to DropSweep

Thanks for helping improve DropSweep.

## Getting Started

Open the project in Xcode and run the `DropSweep` scheme:

```sh
open DropSweep.xcodeproj
```

## Guidelines

- Keep pull requests small and focused.
- Follow the existing Swift and SwiftUI style.
- Be careful with file system changes. DropSweep works with the user's Downloads folder.
- Prefer moving files to the Trash over permanent deletion.
- Add or update the corresponding file in [`docs/features/`](docs/features/) when changing a native app feature; use [`_template.md`](docs/features/_template.md) for new features.
- Include clear manual test steps in your pull request.

## Issues

Use GitHub Issues for bugs and feature requests. Please include your DropSweep version, macOS version, and steps to reproduce.

For security issues, follow [SECURITY.md](SECURITY.md).

## Releases

Maintainers should follow the documented [release process](docs/release.md) when publishing a new version of DropSweep.
