import Testing

nonisolated struct SweeperClassificationTests {
    @Test(arguments: ["dmg", "pkg", "DMG", "PKG"])
    func installers(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("file.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.installerCount == 1)
        #expect(result.otherCount == 0)
    }

    @Test(arguments: ["zip", "xip", "rar", "7z", "tar", "gz", "ZIP"])
    func archives(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("file.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.archiveCount == 1)
    }

    @Test(arguments: ["png", "jpg", "jpeg", "svg", "gif", "webp", "heic", "heif", "tif", "tiff", "bmp", "avif", "ico", "PNG"])
    func images(extension ext: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("photo.\(ext)")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.imageCount == 1)
        #expect(result.screenshotCount == 0)
    }

    @Test(arguments: ["Screenshot.png", "BILDSCHIRMFOTO.JPG", "CleanShot.jpeg"])
    func screenshotsTakePrecedenceOverImages(name: String) async throws {
        let fixture = try DownloadsFixture()
        try fixture.file(name)
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.screenshotCount == 1)
        #expect(result.imageCount == 0)
    }

    @Test func screenshotNameRequiresSupportedExtension() async throws {
        let fixture = try DownloadsFixture()
        try fixture.file("Screenshot.gif")
        try fixture.file("Screenshot.txt")
        try fixture.file("DOCUMENT.PDF")
        try fixture.file("no-extension")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.screenshotCount == 0)
        #expect(result.imageCount == 1)
        #expect(result.pdfCount == 1)
        #expect(result.otherCount == 2)
    }

    @Test func directoryWithFileExtensionRemainsAFolder() async throws {
        let fixture = try DownloadsFixture()
        try fixture.folder("Installer.pkg")
        let result = await fixture.makeSweeper().scanDownloadsFolder()
        #expect(result.folderCount == 1)
        #expect(result.installerCount == 0)
        #expect(result.totalFiles == 0)
    }
}
