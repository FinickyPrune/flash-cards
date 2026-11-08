import SwiftUI

/// Colours of the redesigned catalog screens that don't come from a folder's palette.
enum CatalogStyle {
    /// Under the wash.
    static let background = Color(light: 0xF5F6FA, dark: 0x0C0D12)
    /// Under the rows of the redesigned sheets (card editor, folder sheets).
    static let sheetBackground = Color(light: 0xF7F8FB, dark: 0x0C0D12)
    /// Lists and cards over the wash.
    static let surface = Color(light: Color.white.opacity(0.86), dark: Color(rgb: 0x1A1C24))
    /// Text and glyphs on an accent fill: dark accents are deep, light ones are pale.
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x0C0D12)
    /// Home's wash, not tied to a folder.
    static let homeHues: (first: UInt32, second: UInt32) = (0x8A8AF5, 0x8FD3F7)
    static let homeHuesDark: (first: UInt32, second: UInt32) = (0x5B5BE8, 0x4FAEDB)
}
