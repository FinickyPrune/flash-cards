/// Whether a rating came from a regular review or from practice (`review.md`). Stored as its raw
/// value in `ReviewLog.kind`, so a later recompute (FSRS) can leave practice out.
enum ReviewKind: String, CaseIterable {
    case review
    case practice
}
