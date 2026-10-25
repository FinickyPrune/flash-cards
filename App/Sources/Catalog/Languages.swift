import Foundation

/// Languages offered for a root folder's pair: every language the system has a locale for.
///
/// A language is stored as a BCP-47 tag without region, with the script only where it isn't the
/// language's usual one: `en`, `ru`, `sr` (Cyrillic), `sr-Latn`.
enum Languages {
    struct Option: Identifiable, Hashable {
        let id: String
        let name: String
    }

    static func all(displayedIn displayLocale: Locale = .current) -> [Option] {
        let ids = Set(Locale.availableIdentifiers.map { identifier(for: Locale(identifier: $0)) })
        return ids
            .map { Option(id: $0, name: name(of: $0, displayedIn: displayLocale)) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// The language of `locale` as a stored tag; with `.current` it is the default for both sides of a pair.
    static func identifier(for locale: Locale) -> String {
        Locale.Language(
            languageCode: locale.language.languageCode,
            script: locale.language.script,
            region: nil
        ).minimalIdentifier
    }

    static func name(of identifier: String, displayedIn displayLocale: Locale = .current) -> String {
        displayLocale.localizedString(forIdentifier: identifier) ?? identifier
    }
}
