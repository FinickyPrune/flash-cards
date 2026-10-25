import Foundation

/// Launch arguments UI tests and screenshots use to start from a known state; Debug builds only.
enum LaunchOptions {
    /// `-uitest-reset`: an empty in-memory store instead of the one on disk.
    static var inMemoryStore: Bool {
        isDebug && ProcessInfo.processInfo.arguments.contains("-uitest-reset")
    }

    /// `-uitest-seed`: add `SampleData` at launch (use with `-uitest-reset`).
    static var seed: Bool {
        isDebug && ProcessInfo.processInfo.arguments.contains("-uitest-seed")
    }

    private static var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}
