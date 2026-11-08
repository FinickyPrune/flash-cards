/// Splits CSV text into records of trimmed fields. Quoting per RFC 4180, a little lenient: a
/// quote opens a quoted field after leading spaces, and text after a closing quote is kept.
struct CSVTokenizer {
    private let scalars: [Unicode.Scalar]
    private let delimiter: Unicode.Scalar
    private var index = 0
    private var records: [[String]] = []
    private var fields: [String] = []
    private var field = String.UnicodeScalarView()
    private var isQuoted = false

    /// Blank records (every field empty) are dropped and don't count towards `limit`.
    static func records(in scalars: [Unicode.Scalar], delimiter: Unicode.Scalar, limit: Int = .max) -> [[String]] {
        var tokenizer = CSVTokenizer(scalars: scalars, delimiter: delimiter)
        while tokenizer.index < scalars.count, tokenizer.records.count < limit {
            tokenizer.read(scalars[tokenizer.index])
        }
        if !tokenizer.field.isEmpty || !tokenizer.fields.isEmpty || tokenizer.isQuoted {
            tokenizer.endRecord()
        }
        return Array(tokenizer.records.prefix(limit))
    }

    private mutating func read(_ scalar: Unicode.Scalar) {
        index += 1
        if isQuoted {
            if scalar != "\"" || skip("\"") {
                field.append(scalar)
            } else {
                isQuoted = false
            }
            return
        }
        switch scalar {
        case delimiter:
            endField()
        case "\"" where field.allSatisfy { $0 == " " || $0 == "\t" }:
            field = String.UnicodeScalarView()
            isQuoted = true
        case "\r":
            endRecord()
            _ = skip("\n")
        case "\n":
            endRecord()
        default:
            field.append(scalar)
        }
    }

    /// Consumes the next scalar if it is `scalar`.
    private mutating func skip(_ scalar: Unicode.Scalar) -> Bool {
        guard index < scalars.count, scalars[index] == scalar else {
            return false
        }
        index += 1
        return true
    }

    private mutating func endField() {
        fields.append(String(field).trimmingCharacters(in: .whitespacesAndNewlines))
        field = String.UnicodeScalarView()
    }

    private mutating func endRecord() {
        endField()
        if fields.contains(where: { !$0.isEmpty }) {
            records.append(fields)
        }
        fields = []
    }
}
