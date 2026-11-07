import Foundation

// Each test owns a separate preferences domain and removes it when finished.
nonisolated final class PreferencesFixture {
    let suiteName = "com.dropsweep.tests.\(UUID().uuidString)"

    var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName)!
    }

    deinit {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }
}
