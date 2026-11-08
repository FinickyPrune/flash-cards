import Foundation
import Testing
@testable import FlashCore

@Suite("CSVWriter")
struct CSVWriterTests {
    // Catches: a missing BOM or header, unquoted commas or line breaks, quotes not doubled, or
    // quoting every field.
    @Test("Writes a BOM, a header, and quotes only fields that need it")
    func format() {
        let data = CSVWriter.data(for: [
            CSVRow(front: "kuća", back: "дом"),
            CSVRow(front: "dog, cat", back: "say \"hi\"", context: "one\ntwo"),
        ])
        // Bytes, not a decoded string: decoding drops the BOM.
        let expected = "\u{FEFF}front,back,context\r\nkuća,дом,\r\n\"dog, cat\",\"say \"\"hi\"\"\",\"one\ntwo\"\r\n"
        #expect(data == Data(expected.utf8))
    }

    // Catches: any mismatch between what export writes and what import reads.
    @Test("Reading back what was written gives the same rows")
    func roundTrip() throws {
        let rows = [
            CSVRow(front: "đak", back: "ученик, школьник", context: "Svaki \"đak\" zna."),
            CSVRow(front: "kuća", back: "дом", context: "Line one\r\nline two"),
            CSVRow(front: "ice cream", back: "мороженое"),
        ]
        let document = try CSVDocument(data: CSVWriter.data(for: rows))
        #expect(document.firstRowLooksLikeHeader)
        #expect(document.rows(firstRowIsHeader: true) == CSVReadResult(rows: rows, skippedCount: 0))
    }
}
