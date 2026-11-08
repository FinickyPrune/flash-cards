/// Splits CSV text into records of trimmed fields. Quoting per RFC 4180, a little lenient: a
/// quote opens a quoted field after leading spaces, text after a closing quote is kept, and a
/// quote that never closes is read as text instead of swallowing the rest of the file.
struct CSVTokenizer {
    struct Record: Equatable {
        var fields: [String]
        /// A quote inside an unquoted field: the file is malformed, or split on the wrong delimiter.
        var hasStrayQuote: Bool
    }

    private let scalars: [Unicode.Scalar]
    private let delimiter: Unicode.Scalar
    private var index = 0
    private var records: [Record] = []
    private var fields: [String] = []
    private var field = String.UnicodeScalarView()
    private var isQuoted = false
    private var fieldWasQuoted = false
    private var hasStrayQuote = false
    private var quoteStart = 0

    /// Blank records (every field empty) are dropped and don't count towards `limit`.
    static func records(in scalars: [Unicode.Scalar], delimiter: Unicode.Scalar, limit: Int = .max) -> [Record] {
        var tokenizer = CSVTokenizer(scalars: scalars, delimiter: delimiter)
        while tokenizer.records.count < limit {
            if tokenizer.index < scalars.count {
                tokenizer.read(scalars[tokenizer.index])
            } else if tokenizer.isQuoted {
                tokenizer.readUnclosedQuoteAsText()
            } else {
                break
            }
        }
        if !tokenizer.field.isEmpty || !tokenizer.fields.isEmpty {
            tokenizer.endRecord()
        }
        return tokenizer.records
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
        case "\"" where !fieldWasQuoted && field.allSatisfy { $0 == " " || $0 == "\t" }:
            field = String.UnicodeScalarView()
            isQuoted = true
            fieldWasQuoted = true
            quoteStart = index - 1
        case "\"":
            field.append(scalar)
            hasStrayQuote = true
        case "\r":
            endRecord()
            _ = skip("\n")
        case "\n":
            endRecord()
        default:
            field.append(scalar)
        }
    }

    /// The text ended inside quotes: go back to the opening quote and read it as a plain character.
    private mutating func readUnclosedQuoteAsText() {
        index = quoteStart + 1
        field = String.UnicodeScalarView(["\""])
        isQuoted = false
        fieldWasQuoted = false
        hasStrayQuote = true
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
        fieldWasQuoted = false
    }

    private mutating func endRecord() {
        endField()
        if fields.contains(where: { !$0.isEmpty }) {
            records.append(Record(fields: fields, hasStrayQuote: hasStrayQuote))
        }
        fields = []
        hasStrayQuote = false
    }
}
