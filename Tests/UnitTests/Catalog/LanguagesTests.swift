import Foundation
import Testing
@testable import FlashCards

@Suite("Languages")
struct LanguagesTests {
    // Catches: keeping the region (`en-GB` wouldn't match any option, so nothing is preselected)
    // or dropping the script (Serbian Latin would collapse into Cyrillic `sr`).
    @Test(
        "The system language maps to a stored tag",
        arguments: [("en_GB", "en"), ("ru_RU", "ru"), ("sr_Latn_RS", "sr-Latn"), ("sr_RS", "sr")]
    )
    func identifierForLocale(locale: String, expected: String) {
        #expect(Languages.identifier(for: Locale(identifier: locale)) == expected)
    }

    // Catches: one option per locale instead of per language (English listed once per region).
    @Test("Options are one per language and include the MVP languages")
    func options() {
        let ids = Languages.all().map(\.id)
        #expect(ids.count == Set(ids).count)
        #expect(Set(["en", "ru", "sr", "sr-Latn"]).isSubset(of: ids))
        #expect(!ids.contains("en-GB"))
    }
}
