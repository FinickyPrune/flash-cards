/// One card's text as a CSV row: columns front, back and an optional context (`csv.md`).
public struct CSVRow: Sendable, Equatable {
    public var front: String
    public var back: String
    public var context: String?

    public init(front: String, back: String, context: String? = nil) {
        self.front = front
        self.back = back
        self.context = context
    }
}
