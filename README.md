# DropSweep for macOS

[![License: MIT](https://img.shields.io/badge/license-MIT-orange)](https://opensource.org/license/mit)
![Framework](https://img.shields.io/badge/SwiftUI-orange)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![Platform](https://img.shields.io/badge/Platforms-macOS-orange)
![Xcode](https://img.shields.io/badge/Xcode-26-orange)
![macOS](https://img.shields.io/badge/macOS-26-orange)
![Apple](https://img.shields.io/badge/Apple-000000?style=flat&logo=apple)

DropSweep is a small macOS menu bar app for keeping your Downloads folder tidy.

It scans common download clutter such as installers, archives, PDFs, screenshots, folders, and other files, then lets you move everything to the Trash from a compact menu bar interface.

## Features

- Scan the macOS Downloads folder
- Group downloads by common file type
- Review the current item count from the menu bar
- Move Downloads items to the Trash
- Skip hidden items in the Downloads root; hidden contents inside visible folders move with their folder

## Requirements

- macOS 26
- Xcode 26
- Swift 6

## Development

### macOS app

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
