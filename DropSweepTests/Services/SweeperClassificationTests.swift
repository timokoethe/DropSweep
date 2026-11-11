import Testing

nonisolated struct SweeperClassificationTests {
    @Test(arguments: ["dmg", "pkg", "DMG", "PKG"])
    func installers(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("file.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.installer].count == 1)
        #expect(result[.other].count == 0)
    }

    @Test(arguments: ["zip", "xip", "rar", "7z", "tar", "gz", "ZIP"])
    func archives(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("file.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.archive].count == 1)
    }

    @Test(arguments: ["png", "jpg", "jpeg", "svg", "gif", "webp", "heic", "heif", "tif", "tiff", "bmp", "avif", "ico", "PNG"])
    func images(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("photo.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.image].count == 1)
        #expect(result[.screenshot].count == 0)
    }

    @Test(arguments: ["Screenshot.png", "BILDSCHIRMFOTO.JPG", "CleanShot.jpeg"])
    func screenshotsTakePrecedenceOverImages(name: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file(name)
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.screenshot].count == 1)
        #expect(result[.image].count == 0)
    }

    @Test func screenshotNameRequiresSupportedExtension() async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("Screenshot.gif")
        try fixture.file("Screenshot.txt")
        try fixture.file("DOCUMENT.PDF")
        try fixture.file("no-extension")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.screenshot].count == 0)
        #expect(result[.image].count == 1)
        #expect(result[.pdf].count == 1)
        #expect(result[.other].count == 2)
    }

    @Test func directoryWithFileExtensionRemainsAFolder() async throws {
        let fixture = try DownloadsFixture()
        try fixture.folder("Installer.pkg")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result[.folder].count == 1)
        #expect(result[.installer].count == 0)
        #expect(result.items.filter { $0.category != .folder }.count == 0)
    }
}
