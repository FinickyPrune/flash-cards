import FlashCore
import Foundation
import SwiftData

/// Review with SwiftData (`review.md`). Every rating is saved right away, so closing review
/// mid-session keeps the ratings given so far; a failed save rolls the context back.
@MainActor
struct ReviewService: ReviewServicing {
    let context: ModelContext
    var scheduler: any Scheduler = SM2Scheduler()
    var clock: () -> Date = { .now }

    func build(for folder: Folder) -> SessionBuilder.Outcome {
        SessionBuilder.build(from: sessionCards(in: folder), at: clock())
    }

    func practice(for folder: Folder) -> [UUID] {
        var generator = SystemRandomNumberGenerator()
        return SessionBuilder.practice(from: sessionCards(in: folder), using: &generator)
    }

    func record(_ rating: Rating, for card: Card, isFirstRating: Bool, isPractice: Bool) throws {
        let now = clock()
        context.insert(ReviewLog(
            card: card,
            rating: rating.rawValue,
            reviewedAt: now,
            kind: isPractice ? .practice : .review
        ))
        if isFirstRating, !isPractice {
            let state = card.forwardReviewState ?? {
                let state = ReviewState(card: card)
                context.insert(state)
                return state
            }()
            state.apply(scheduler.schedule(state.schedulingState, rating: rating, at: now))
        }
        try context.saveOrRollback()
    }

    private func sessionCards(in folder: Folder) -> [SessionCard] {
        folder.subtreeCards.map {
            SessionCard(
                id: $0.id,
                createdAt: $0.createdAt,
                state: $0.forwardReviewState?.schedulingState ?? SchedulingState()
            )
        }
    }
}
