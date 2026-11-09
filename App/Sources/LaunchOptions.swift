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

    /// `UITEST_CSV` in the environment: its text is written to a file that Import CSV opens
    /// instead of showing the file importer, which UI tests can't drive.
    static let csvFile: URL? = {
        guard isDebug, let text = ProcessInfo.processInfo.environment["UITEST_CSV"] else {
            return nil
        }
        let url = URL.temporaryDirectory.appending(path: "uitest.csv")
        do {
            try Data(text.utf8).write(to: url)
            return url
        } catch {
            return nil
        }
    }()

    private static var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}
