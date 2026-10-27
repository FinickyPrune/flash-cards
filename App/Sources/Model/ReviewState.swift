import FlashCore
import Foundation
import SwiftData

/// Scheduling state of one card in one direction (decision 0002).
@Model
final class ReviewState {
    var card: Card?
    /// `forward` or `reverse`; the MVP uses only `forward`.
    var direction = "forward"
    var dueDate: Date?
    var intervalDays = 0.0
    var ease = 2.5
    var repetitions = 0
    var lapses = 0

    init(card: Card, direction: String = "forward") {
        self.card = card
        self.direction = direction
    }

    /// The stored fields as the scheduler sees them; the scheduler works in whole days.
    var schedulingState: SchedulingState {
        SchedulingState(
            repetitions: repetitions,
            intervalDays: Int(intervalDays.rounded()),
            ease: ease,
            lapses: lapses,
            dueDate: dueDate
        )
    }
}
