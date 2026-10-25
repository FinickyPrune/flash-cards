import Observation

/// Which folder of one list is being renamed, moved or deleted.
@MainActor
@Observable
final class FolderActions {
    var renaming: Folder?
    var moving: Folder?
    var deleting: Folder?
}
