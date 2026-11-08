import Foundation

/// Writes cards as CSV for export (`csv.md` → Export): UTF-8 with a BOM so spreadsheets pick
/// the encoding, comma delimiter, CRLF line endings, a `front,back,context` header.
/// Fields are expected trimmed, as cards are: the reader trims, so surrounding spaces don't round-trip.
public enum CSVWriter {
    public static func data(for rows: [CSVRow]) -> Data {
        var text = "\u{FEFF}front,back,context\r\n"
        for row in rows {
            text += [row.front, row.back, row.context ?? ""].map(field).joined(separator: ",") + "\r\n"
        }
        return Data(text.utf8)
    }

    /// Quoted only when needed. Scalars, not characters: `\r\n` is one `Character`, and so is a
    /// quote followed by a combining mark.
    private static func field(_ value: String) -> String {
        guard value.unicodeScalars.contains(where: needsQuotes) else {
            return value
        }
        var quoted = String.UnicodeScalarView(["\""])
        for scalar in value.unicodeScalars {
            quoted.append(scalar)
            if scalar == "\"" {
                quoted.append(scalar)
            }
        }
        quoted.append("\"")
        return String(quoted)
    }

    private static func needsQuotes(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar {
        case ",", "\"", "\r", "\n": true
        default: false
        }
    }
}
