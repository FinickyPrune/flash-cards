import Foundation

/// Launch arguments UI tests and screenshots use to start from a known state; Debug builds only.
enum LaunchOptions {
    /// `-uitest-reset`: an empty in-memory store instead of the one on disk.
    static var inMemoryStore: Bool {
        seed || isDebug && ProcessInfo.processInfo.arguments.contains("-uitest-reset")
    }

    /// `-uitest-seed`: an in-memory store with `SampleData`, so samples never reach the disk.
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
