/// The rows that become cards, and how many rows were left out for an empty front or back.
public struct CSVReadResult: Sendable, Equatable {
    public var rows: [CSVRow]
    public var skippedCount: Int

    public init(rows: [CSVRow], skippedCount: Int) {
        self.rows = rows
        self.skippedCount = skippedCount
    }
}
