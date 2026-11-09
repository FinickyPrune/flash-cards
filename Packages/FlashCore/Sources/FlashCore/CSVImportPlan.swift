/// Which read rows an import creates (`csv.md` → Import). A duplicate repeats a front key that is
/// already in the destination's root folder, or on an earlier row of the file; the first
/// occurrence in the file is the one kept.
public struct CSVImportPlan: Sendable, Equatable {
    public let rows: [CSVRow]
    /// Parallel to `rows`.
    private let isDuplicate: [Bool]

    /// `existingKeys`: the front keys of the cards in the destination's root folder.
    public init(rows: [CSVRow], existingKeys: Set<String>) {
        var seen = existingKeys
        self.rows = rows
        isDuplicate = rows.map { !seen.insert(FrontKey.make(from: $0.front)).inserted }
    }

    public var duplicateCount: Int {
        isDuplicate.count { $0 }
    }

    public func rows(skippingDuplicates: Bool) -> [CSVRow] {
        guard skippingDuplicates else {
            return rows
        }
        return zip(rows, isDuplicate).filter { !$0.1 }.map(\.0)
    }
}
