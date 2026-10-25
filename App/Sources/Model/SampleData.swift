import Foundation
import SwiftData

/// A small catalog for previews, UI tests and screenshots (`-uitest-seed`).
@MainActor
enum SampleData {
    static func insert(into context: ModelContext) {
        let english = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        let show = Folder(name: "Breaking Bad", parent: english)
        let season = Folder(name: "Season 1", parent: show)
        let serbian = Folder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        for folder in [english, show, season, Folder(name: "Season 2", parent: show), serbian] {
            context.insert(folder)
        }
        let cards: [(folder: Folder, words: [(front: String, back: String)])] = [
            (english, [("reckon", "считать, полагать")]),
            (season, [("chemistry", "химия"), ("cook", "варить, готовить"), ("ice cream", "мороженое")]),
            (serbian, [("kuća", "дом"), ("hvala", "спасибо")]),
        ]
        var createdAt = Date(timeIntervalSince1970: 1_790_000_000)
        for (folder, words) in cards {
            for (front, back) in words {
                context.insert(Card(
                    front: front,
                    back: back,
                    backSource: "translation",
                    folder: folder,
                    createdAt: createdAt
                ))
                createdAt += 60
            }
        }
    }
}

@MainActor
extension ModelContainer {
    /// In-memory container with `SampleData`, for previews.
    static var preview: ModelContainer {
        do {
            let container = try AppModelContainer.make(inMemory: true)
            SampleData.insert(into: container.mainContext)
            return container
        } catch {
            fatalError("Cannot build the preview container: \(error)")
        }
    }
}
