import Foundation
import SwiftData
import UIKit

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
        // A card with a context and a screenshot, as screenshot import will make them.
        let contexts = ["cook": "He says he can cook it better than anyone in town."]
        // Forward intervals of reviewed cards; 21 days and up counts as learned.
        let intervals: [String: Double] = ["reckon": 30, "chemistry": 25, "cook": 6]
        var createdAt = Date(timeIntervalSince1970: 1_790_000_000)
        for (folder, words) in cards {
            for (front, back) in words {
                let card = Card(
                    front: front,
                    back: back,
                    backSource: "translation",
                    folder: folder,
                    context: contexts[front],
                    screenshot: contexts[front].flatMap(screenshot(subtitle:)),
                    createdAt: createdAt
                )
                context.insert(card)
                if let interval = intervals[front] {
                    let state = ReviewState(card: card)
                    state.intervalDays = interval
                    state.repetitions = 3
                    state.dueDate = createdAt.addingTimeInterval(interval * 86400)
                    context.insert(state)
                }
                createdAt += 60
            }
        }
    }

    /// A drawn stand-in for a subtitled video frame, as a compressed JPEG like a stored copy.
    private static func screenshot(subtitle: String) -> Data? {
        let size = CGSize(width: 1280, height: 720)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let colors = [UIColor.systemTeal.cgColor, UIColor.systemIndigo.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let text = NSAttributedString(string: subtitle, attributes: [
                .font: UIFont.systemFont(ofSize: 44, weight: .semibold),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2,
                .paragraphStyle: style,
            ])
            text.draw(in: CGRect(x: 80, y: size.height - 160, width: size.width - 160, height: 120))
        }
        return image.jpegData(compressionQuality: 0.7)
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
