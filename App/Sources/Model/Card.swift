import FlashCore
import Foundation
import SwiftData

/// One item to learn: a front and the back picked in the card editor (`card-editor.md`).
@Model
final class Card {
    var id = UUID()
    var folder: Folder?
    /// Change through `setFront(_:)`, which keeps `frontKey` in sync.
    private(set) var front = ""
    /// Normalised front for duplicate detection, see `FrontKey`.
    private(set) var frontKey = ""
    var context: String?
    /// Compressed JPEG copy of the source screenshot (decision 0003).
    @Attribute(.externalStorage) var screenshot: Data?
    var back = ""
    /// `definition`, `synonyms`, `translation` or `custom`.
    var backSource = "custom"
    var createdAt = Date.now
    var updatedAt = Date.now
    @Relationship(deleteRule: .cascade, inverse: \ReviewState.card)
    var reviewStates: [ReviewState]?
    @Relationship(deleteRule: .cascade, inverse: \ReviewLog.card)
    var reviewLogs: [ReviewLog]?

    init(
        front: String,
        back: String,
        backSource: String,
        folder: Folder?,
        context: String? = nil,
        screenshot: Data? = nil,
        createdAt: Date = .now
    ) {
        self.folder = folder
        self.context = context
        self.screenshot = screenshot
        self.back = back
        self.backSource = backSource
        self.createdAt = createdAt
        updatedAt = createdAt
        setFront(front)
    }

    func setFront(_ front: String) {
        self.front = front
        frontKey = FrontKey.make(from: front)
    }
}
