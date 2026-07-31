# DropSweep for macOS

[![GitHub Release](https://img.shields.io/github/v/release/timokoethe/dropsweep?label=release)](https://github.com/timokoethe/dropsweep/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-orange)](https://opensource.org/license/mit)
![Framework](https://img.shields.io/badge/SwiftUI-orange)
![Platform](https://img.shields.io/badge/Platforms-macOS-orange)
![Xcode](https://img.shields.io/badge/Xcode-26-orange)
![macOS](https://img.shields.io/badge/macOS-26-orange)
![Apple](https://img.shields.io/badge/Apple-000000?style=flat&logo=apple)

DropSweep is a small macOS menu bar app for keeping your Downloads folder tidy.

[Product website](https://dropsweep.itstimo.me) ·
[Implementation reference](https://itstimo.me/projects/dropsweep)

It scans common download clutter such as installers, archives, PDFs, screenshots, folders, and other files, then lets you move everything to the Trash from a compact menu bar interface.

## Installation

1. Download the latest version from [GitHub Releases](https://github.com/timokoethe/DropSweep/releases/latest).
2. Unzip the downloaded archive.
3. Move `DropSweep.app` to your Applications folder and open it.

## Features

- [Access DropSweep from the menu bar](docs/features/menu-bar-access.md)
- [Scan the macOS Downloads folder](docs/features/downloads-scanning.md)
- [Group downloads by common file type and size](docs/features/download-categories.md)
- [Move listed Downloads items to the Trash](docs/features/move-to-trash.md)
- [Launch DropSweep at login](docs/features/launch-at-login.md)
- [Check for app updates](docs/features/app-updates.md)

Detailed behavior and acceptance criteria for each native app feature are documented in [`docs/features/`](docs/features/).

## System Requirements

- macOS 26 or later

## Privacy

DropSweep scans your Downloads folder locally and does not upload file names or contents. Network access is only used to check for and download app updates through Sparkle.

## Development

### macOS app

Development requires Xcode 26.

Open the project in Xcode and run the `DropSweep` scheme:

```sh
open DropSweep.xcodeproj
```

The native SwiftUI app is located in [`DropSweep/`](DropSweep/).

### Website

The DropSweep website is developed separately in [`website/`](website/). Its
Next.js application code is located in [`website/app/`](website/app/), with the
landing page in [`website/app/page.tsx`](website/app/page.tsx).

To run the website locally:

```sh
cd website
npm install
npm run dev
```

The development server is available at
[http://localhost:3000](http://localhost:3000). See the
[website README](website/README.md) for the available scripts and deployment
details.

## Contributing

Contributions are welcome. Please keep changes focused and see [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

Report security issues privately as described in [SECURITY.md](SECURITY.md).

## License

DropSweep is released under the MIT License. See [LICENSE](LICENSE).
