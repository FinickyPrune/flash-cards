import Foundation
import SwiftUI

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

    /// `-uitest-light` / `-uitest-dark`: the app's appearance whatever the simulator's setting,
    /// for the screenshot tour; `XCUIDevice.appearance` no longer reaches the app (#51).
    static let colorScheme: ColorScheme? = {
        guard isDebug else {
            return nil
        }
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uitest-dark") {
            return .dark
        }
        return arguments.contains("-uitest-light") ? .light : nil
    }()

    private static var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}
