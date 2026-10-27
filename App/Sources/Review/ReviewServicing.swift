import FlashCore
import Foundation
import Mockable

/// Picks a folder's cards for review and records ratings; `ReviewService` saves them with
/// SwiftData. The review screen depends on this and resolves the returned card ids through
/// `Folder.subtreeCards`.
@Mockable
@MainActor
protocol ReviewServicing {
    /// The next session for the folder's whole subtree, forward direction.
    func build(for folder: Folder) -> SessionBuilder.Outcome
    /// Random cards of the subtree, for when nothing is due or new.
    func practice(for folder: Folder) -> [UUID]
    /// Logs the rating, and on a card's first rating outside practice updates its schedule.
    func record(_ rating: Rating, for card: Card, isFirstRating: Bool, isPractice: Bool) throws
}
