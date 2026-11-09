import Foundation
import Testing
@testable import FlashCore

@Suite("CSVDocument")
struct CSVDocumentTests {
    private func read(_ text: String, firstRowIsHeader: Bool = false) throws -> CSVReadResult {
        try CSVDocument(data: Data(text.utf8)).rows(firstRowIsHeader: firstRowIsHeader)
    }

    // Catches: a fixed delimiter, counting delimiters inside quotes, or ties going to the comma.
    @Test(
        "Picks the delimiter that splits the most rows",
        arguments: [
            ("kuća\tдом\nreč\tслово", "\t"),
            ("kuća;дом\nreč;слово", ";"),
            ("kuća,дом\nreč,слово", ","),
            // The commas are inside quotes, so only `;` splits these rows.
            ("\"a, b\";дом\n\"c, d\";слово", ";"),
            // `;` splits these rows too, but leaves a quote mid-field: it's inside a quoted field.
            ("pas,\"собака; пёс\"\nmačka,\"мачка; кот\"", ","),
            // Each candidate splits one row: ties go tab, then `;`.
            ("a;b\nc,d", ";"),
            ("a;b\nc,d\ne\tf", "\t"),
            // Only the first 50 non-blank rows vote; blank rows don't count towards them.
            (String(repeating: "a;b\n\n", count: 50) + String(repeating: "c,d\n", count: 60), ";"),
        ] as [(String, Unicode.Scalar)]
    )
    func delimiter(text: String, expected: Unicode.Scalar) throws {
        #expect(try CSVDocument(data: Data(text.utf8)).delimiter == expected)
    }

    // Catches: splitting on a quoted delimiter or line break, or keeping both quotes of `""`.
    @Test("A quoted field keeps its delimiter, line break and escaped quote")
    func quotedField() throws {
        let result = try read("pas;\"dog; a \"\"good\"\"\nboy\";ctx\nmačka;cat")
        #expect(result.rows == [
            CSVRow(front: "pas", back: "dog; a \"good\"\nboy", context: "ctx"),
            CSVRow(front: "mačka", back: "cat"),
        ])
    }

    // Catches: an unclosed quote reading the rest of the file as one field, losing every row after it.
    @Test("A quote that never closes is read as text")
    func unclosedQuote() throws {
        let result = try read("\"Hello;привет\nb;c\nd;e")
        #expect(result.rows == [
            CSVRow(front: "\"Hello", back: "привет"),
            CSVRow(front: "b", back: "c"),
            CSVRow(front: "d", back: "e"),
        ])
    }

    // Catches: a lone `\r` not ending a row, or a line break splitting a field in the wrong place.
    @Test("All line endings read the same rows", arguments: ["\n", "\r\n", "\r"])
    func lineEndings(newline: String) throws {
        let result = try read(["a;1", "b;2", ""].joined(separator: newline))
        #expect(result == CSVReadResult(
            rows: [CSVRow(front: "a", back: "1"), CSVRow(front: "b", back: "2")],
            skippedCount: 0
        ))
    }

    // Catches: the BOM ending up in the first front, so it never matches a duplicate.
    @Test("A UTF-8 BOM is stripped")
    func byteOrderMark() throws {
        let result = try read("\u{FEFF}kuća;дом")
        #expect(result.rows == [CSVRow(front: "kuća", back: "дом")])
    }

    // Catches: lossy decoding that turns a Windows-1251 file into replacement characters.
    @Test("Bytes that aren't UTF-8 throw")
    func notUTF8() {
        // "дом" in Windows-1251.
        let data = Data([0xE4, 0xEE, 0xEC, 0x3B, 0x61])
        #expect(throws: CSVError.notUTF8) { try CSVDocument(data: data) }
    }

    // Catches: case- or diacritic-sensitive matching, or matching any column instead of the first.
    @Test(
        "Guesses a header from the first field",
        arguments: [
            ("Front;Back\na;b", true),
            ("Слово,Перевод\na,b", true),
            ("reč\tprevod\na\tb", true),
            ("kuća;дом\na;b", false),
            ("kuća;word\na;b", false),
        ]
    )
    func headerGuess(text: String, expected: Bool) throws {
        #expect(try CSVDocument(data: Data(text.utf8)).firstRowLooksLikeHeader == expected)
    }

    // Catches: a header row dropped when the user said it isn't one, or kept when they said it is.
    @Test("The header row is dropped only when the caller says so")
    func headerToggle() throws {
        let document = try CSVDocument(data: Data("front;back\nkuća;дом".utf8))
        #expect(document.rows(firstRowIsHeader: true).rows == [CSVRow(front: "kuća", back: "дом")])
        #expect(document.rows(firstRowIsHeader: false).rows.first == CSVRow(front: "front", back: "back"))
    }

    // Catches: crashing on a one-column row, counting blank rows as skipped, an empty context
    // stored as "", untrimmed fields, or extra columns shifting into the context.
    @Test("Rows without a front or back are skipped; blank rows don't count")
    func rowRules() throws {
        let text = """
        only front
        ;back only
        front only;
        ;;

          kuća  ;  дом  ;
        pas;dog;Good dog.;extra;more
        """
        #expect(try read(text) == CSVReadResult(
            rows: [
                CSVRow(front: "kuća", back: "дом"),
                CSVRow(front: "pas", back: "dog", context: "Good dog."),
            ],
            skippedCount: 3
        ))
    }

    @Test("A file without cards reads as empty")
    func empty() throws {
        #expect(try read("\n\n") == CSVReadResult(rows: [], skippedCount: 0))
    }
}
