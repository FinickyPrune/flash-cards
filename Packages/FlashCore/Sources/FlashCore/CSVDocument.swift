import Foundation

/// A user's CSV file read into records (`csv.md` → Import): UTF-8, delimiter detected among
/// tab, `;` and `,`, RFC 4180 quoting, fields trimmed, blank rows dropped.
public struct CSVDocument: Sendable, Equatable {
    /// Whether the first record looks like a header; the import preview lets the user override it.
    public let firstRowLooksLikeHeader: Bool
    let delimiter: Unicode.Scalar
    /// Non-blank records in file order, header included.
    let records: [[String]]

    /// First fields that mark a header row, compared by front key.
    private static let headerNames: Set<String> = Set(
        ["front", "word", "term", "question", "phrase", "лицо", "слово", "термин", "вопрос", "фраза", "reč", "pojam"]
            .map(FrontKey.make)
    )

    /// Ties go to the earlier candidate: commas are common inside text.
    private static let candidates: [Unicode.Scalar] = ["\t", ";", ","]
    private static let detectionSample = 50
    /// Bounds detection on a large file whose wrong candidate never completes 50 records.
    private static let detectionScalars = 65536

    public init(data: Data) throws(CSVError) {
        guard var text = String(validating: data, as: UTF8.self) else {
            throw .notUTF8
        }
        if text.unicodeScalars.first == "\u{FEFF}" {
            text.unicodeScalars.removeFirst()
        }
        let scalars = Array(text.unicodeScalars)
        delimiter = Self.detectDelimiter(in: Array(scalars.prefix(Self.detectionScalars)))
        records = CSVTokenizer.records(in: scalars, delimiter: delimiter).map(\.fields)
        firstRowLooksLikeHeader = records.first.map { Self.headerNames.contains(FrontKey.make(from: $0[0])) } ?? false
    }

    /// The candidate that splits the most sample rows into 2+ fields without a stray quote;
    /// a quote mid-field means a quoted delimiter was split on, as `;` in `pas,"собака; пёс"`.
    /// Rows split with a stray quote only break ties.
    private static func detectDelimiter(in scalars: [Unicode.Scalar]) -> Unicode.Scalar {
        var best = candidates[0]
        var bestScore = (-1, -1)
        for candidate in candidates {
            let split = CSVTokenizer.records(in: scalars, delimiter: candidate, limit: detectionSample)
                .filter { $0.fields.count >= 2 }
            let score = (split.count { !$0.hasStrayQuote }, split.count)
            if score > bestScore {
                best = candidate
                bestScore = score
            }
        }
        return best
    }

    /// Columns 1 → front, 2 → back, 3 → context (empty → nil); further columns are ignored.
    public func rows(firstRowIsHeader: Bool) -> CSVReadResult {
        var rows: [CSVRow] = []
        var skippedCount = 0
        for fields in records.dropFirst(firstRowIsHeader ? 1 : 0) {
            let front = fields[0]
            let back = fields.count > 1 ? fields[1] : ""
            guard !front.isEmpty, !back.isEmpty else {
                skippedCount += 1
                continue
            }
            let context = fields.count > 2 && !fields[2].isEmpty ? fields[2] : nil
            rows.append(CSVRow(front: front, back: back, context: context))
        }
        return CSVReadResult(rows: rows, skippedCount: skippedCount)
    }
}
