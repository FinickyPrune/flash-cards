import FlashCore
import Foundation
import Observation

/// One review run of a folder's subtree (`review.md` → Flow): the card flow, practice and the
/// summary. Built when Play is tapped; `start()` builds the session.
@MainActor
@Observable
final class ReviewViewModel: Identifiable {
    enum Phase: Equatable {
        /// Before `start()`.
        case loading
        /// The subtree has no cards.
        case empty
        case allCaughtUp(nextDue: Date)
        case card
        case summary(ReviewSession.Summary)
    }

    let folder: Folder
    private(set) var phase = Phase.loading
    private(set) var session = ReviewSession(cards: [])
    /// The back and the rating buttons show only after the flip.
    private(set) var isFlipped = false
    /// The session More starts; `nil` when building again gives none.
    private(set) var nextSession: [UUID]?
    var saveError: String?
    private var cards: [UUID: Card] = [:]
    private let service: any ReviewServicing

    init(folder: Folder, service: any ReviewServicing) {
        self.folder = folder
        self.service = service
    }

    var currentCard: Card? {
        session.current.flatMap { cards[$0] }
    }

    func start() {
        guard phase == .loading else {
            return
        }
        switch service.build(for: folder) {
        case let .session(ids):
            begin(ids, isPractice: false)
        case let .allCaughtUp(nextDue):
            phase = .allCaughtUp(nextDue: nextDue)
        case .empty:
            phase = .empty
        }
    }

    func startPractice() {
        begin(service.practice(for: folder), isPractice: true)
    }

    /// More on the summary: the next session, in place.
    func continueReviewing() {
        guard let nextSession else {
            return
        }
        begin(nextSession, isPractice: false)
    }

    func flip() {
        isFlipped = true
    }

    /// Records the rating and shows the next card, or the summary after the last one. A failed
    /// save keeps the card on screen, so the rating can be given again.
    func rate(_ rating: Rating) {
        guard isFlipped, let card = currentCard else {
            return
        }
        var next = session
        guard let rated = next.rate(rating) else {
            return
        }
        do {
            try service.record(rating, for: card, isFirstRating: rated.isFirstRating, isPractice: next.isPractice)
        } catch {
            saveError = error.localizedDescription
            return
        }
        session = next
        isFlipped = false
        if session.isFinished {
            finish()
        }
    }

    private func begin(_ ids: [UUID], isPractice: Bool) {
        cards = Dictionary(folder.subtreeCards.map { ($0.id, $0) }) { first, _ in first }
        session = ReviewSession(cards: ids.filter { cards[$0] != nil }, isPractice: isPractice)
        isFlipped = false
        nextSession = nil
        if session.isFinished {
            finish()
        } else {
            phase = .card
        }
    }

    private func finish() {
        if case let .session(ids) = service.build(for: folder) {
            nextSession = ids
        } else {
            nextSession = nil
        }
        phase = .summary(session.summary)
    }
}
