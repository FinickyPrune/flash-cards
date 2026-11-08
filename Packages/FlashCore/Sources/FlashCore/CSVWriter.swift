import Foundation

/// Writes cards as CSV for export (`csv.md` → Export): UTF-8 with a BOM so spreadsheets pick
/// the encoding, comma delimiter, CRLF line endings, a `front,back,context` header.
public enum CSVWriter {
    public static func data(for rows: [CSVRow]) -> Data {
        var text = "\u{FEFF}front,back,context\r\n"
        for row in rows {
            text += [row.front, row.back, row.context ?? ""].map(field).joined(separator: ",") + "\r\n"
        }
        return Data(text.utf8)
    }

    /// Quoted only when needed. Scalars, not characters: `\r\n` is a single `Character`.
    private static func field(_ value: String) -> String {
        guard value.unicodeScalars.contains(where: { [",", "\"", "\r", "\n"].contains($0) }) else {
            return value
        }
        return "\"" + value.replacing("\"", with: "\"\"") + "\""
    }
}
