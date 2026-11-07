import Foundation
import Testing

@MainActor
struct CategorySelectionStoreTests {
    private let preferences = PreferencesFixture()

    @Test func firstLaunchSelectsAllCategories() {
        let store = CategorySelectionStore(defaults: preferences.defaults)
        #expect(store.load() == Set(DownloadsCategory.allCases))
    }

    @Test func unknownIdentifiersDoNotSelectAdditionalCategories() {
        preferences.defaults.set([DownloadsCategory.pdf.rawValue, "Unknown Category"], forKey: "selectedDownloadsCategories")
        let store = CategorySelectionStore(defaults: preferences.defaults)
        #expect(store.load() == [.pdf])

        preferences.defaults.set(["Unknown Category"], forKey: "selectedDownloadsCategories")
        #expect(store.load().isEmpty)
    }

    @Test func invalidPreferenceFallsBackToFirstLaunchDefaults() {
        preferences.defaults.set(42, forKey: "selectedDownloadsCategories")
        let store = CategorySelectionStore(defaults: preferences.defaults)
        #expect(store.load() == Set(DownloadsCategory.allCases))
    }
}
