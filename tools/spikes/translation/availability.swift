// Spike #4: which pairs the on-device Translation framework supports and has installed.
//   swift tools/spikes/translation/availability.swift
import Foundation
import Translation

let availability = LanguageAvailability()
let supported = await availability.supportedLanguages
print("Supported (\(supported.count)):", supported.map(\.minimalIdentifier).sorted().joined(separator: " "))

let pairs = [
    ("en", "ru"),
    ("ru", "en"),
    ("es", "ru"),
    ("es", "en"),
    ("en", "es"),
    ("sr", "ru"),
    ("hr", "ru"),
    ("bs", "ru"),
    ("sr", "en"),
]
for (source, target) in pairs {
    let status = await availability.status(
        from: Locale.Language(identifier: source),
        to: Locale.Language(identifier: target)
    )
    print("\(source) → \(target): \(status)")
}
