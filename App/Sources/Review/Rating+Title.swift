import FlashCore
import SwiftUI

extension Rating {
    /// The rating button's label (glossary → Rating).
    var title: LocalizedStringKey {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }

    /// The rating button's colour: deep in light mode, pale on the near-black of dark mode.
    var tint: Color {
        switch self {
        case .again: Color(light: 0xC81E1E, dark: 0xFF8A80)
        case .hard: Color(light: 0xB45309, dark: 0xFDBA74)
        case .good: Color(light: 0x15803D, dark: 0x6EE7A0)
        case .easy: Color(light: 0x1D4ED8, dark: 0x93B4FF)
        }
    }
}
