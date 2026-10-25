import Foundation

/// The folder name rule: surrounding whitespace is dropped, and an empty name isn't allowed.
enum FolderName {
    /// The name to store, or nil when it isn't allowed.
    static func normalized(_ name: String) -> String? {
        name.trimmed.isEmpty ? nil : name.trimmed
    }
}
