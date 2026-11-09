import Testing
@testable import FlashCore

@Suite("CSVImportPlan")
struct CSVImportPlanTests {
    // Catches: comparing raw fronts instead of front keys, ignoring repeats within the file, or
    // dropping the first occurrence of a repeat instead of the later ones.
    @Test("Duplicates are fronts already in the root folder or on an earlier row")
    func duplicates() {
        let rows = [
            CSVRow(front: "Kuca", back: "дом"),
            CSVRow(front: "pas", back: "собака"),
            CSVRow(front: "Pas ", back: "пёс"),
            CSVRow(front: "mačka", back: "кошка"),
        ]
        let plan = CSVImportPlan(rows: rows, existingKeys: [FrontKey.make(from: "kuća")])

        #expect(plan.duplicateCount == 2)
        #expect(plan.rows(skippingDuplicates: true) == [rows[1], rows[3]])
        #expect(plan.rows(skippingDuplicates: false) == rows)
    }
}
