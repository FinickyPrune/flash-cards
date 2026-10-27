import Foundation
import SwiftData

/// One rating ever given, kept to recompute schedules later (decision 0002).
@Model
final class ReviewLog {
    var card: Card?
    /// `forward` or `reverse`.
    var direction = "forward"
    /// 0 again, 1 hard, 2 good, 3 easy.
    var rating = 0
    var reviewedAt = Date.now
    /// Raw value of `ReviewKind`; rows from before schema V2 read as `review`.
    var kind = ReviewKind.review.rawValue

    init(
        card: Card,
        direction: String = "forward",
        rating: Int,
        reviewedAt: Date = .now,
        kind: ReviewKind = .review
    ) {
        self.card = card
        self.direction = direction
        self.rating = rating
        self.reviewedAt = reviewedAt
        self.kind = kind.rawValue
    }
}
