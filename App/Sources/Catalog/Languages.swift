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

    /// The device's first preferred language. `Locale.current` would follow the app's own
    /// localization instead, which isn't the user's language when the app lacks theirs.
    static var systemLanguage: String {
        identifier(for: Locale(identifier: Locale.preferredLanguages.first ?? "en"))
    }

    /// `all()` off the main actor: it builds several hundred locales (~20 ms).
    @concurrent
    static func loadAll() async -> [Option] {
        all()
    }

    static func all(displayedIn displayLocale: Locale = .current) -> [Option] {
        let ids = Set(Locale.availableIdentifiers.map { identifier(for: Locale(identifier: $0)) })
        return ids
            .map { Option(id: $0, name: name(of: $0, displayedIn: displayLocale)) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// The language of `locale` as a stored tag. Not `minimalIdentifier`: for a non-default script
    /// it puts a region back (`zh-Hant` → `zh-TW`).
    static func identifier(for locale: Locale) -> String {
        guard let code = locale.language.languageCode else { return "und" }
        guard let script = locale.language.script else { return code.identifier }
        let likely = Locale.Language(identifier: Locale.Language(languageCode: code).maximalIdentifier)
        return script == likely.script ? code.identifier : "\(code.identifier)-\(script.identifier)"
    }

    static func name(of identifier: String, displayedIn displayLocale: Locale = .current) -> String {
        displayLocale.localizedString(forIdentifier: identifier) ?? identifier
    }
}
