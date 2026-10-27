/// Answer grade for one card; raw values match `ReviewLog.rating`.
public enum Rating: Int, Sendable, CaseIterable {
    case again = 0
    case hard = 1
    case good = 2
    case easy = 3
}
