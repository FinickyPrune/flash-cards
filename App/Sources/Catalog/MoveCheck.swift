/// Whether a folder can move to a destination (`catalog.md` → States and edge cases).
enum MoveCheck: Equatable {
    case allowed
    /// The destination's root has another language pair; the user confirms first.
    case allowedAfterWarning
    /// Under the folder itself or a descendant, or where the folder already is.
    case notAllowed
}
