import Foundation

struct CategorySelectionStore {
    private let defaults: UserDefaults
    private let key = "selectedDownloadsCategories"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Set<DownloadsCategory> {
        guard let identifiers = defaults.stringArray(forKey: key) else {
            return Set(DownloadsCategory.allCases)
        }

        // An empty saved array means the user deliberately deselected everything.
        // Ignore identifiers that this version of the app does not recognize.
        return Set(identifiers.compactMap(DownloadsCategory.init(rawValue:)))
    }

    func save(_ categories: Set<DownloadsCategory>) {
        defaults.set(categories.map(\.rawValue).sorted(), forKey: key)
    }
}
