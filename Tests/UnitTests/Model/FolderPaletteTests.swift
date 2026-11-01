import Foundation
import Testing
@testable import FlashCards

@Suite("FolderPalette")
struct FolderPaletteTests {
    // Catches: picking the last unused instead of the first, or wrapping by index instead of by count.
    @Test(
        "A new root folder gets the first unused palette, then they repeat in order",
        arguments: [
            ([], FolderPalette.lagoon),
            ([.lagoon, .indigo], .mint),
            ([.indigo], .lagoon),
            (FolderPalette.allCases, .lagoon),
            (FolderPalette.allCases + [.lagoon], .indigo),
        ] as [([FolderPalette], FolderPalette)]
    )
    func forNewRoot(used: [FolderPalette], expected: FolderPalette) {
        #expect(FolderPalette.forNewRoot(used: used) == expected)
    }

    /// Characterization, checked against an independent FNV-1a implementation: these must never
    /// change, or folders from before palettes change colour. Catches: switching to `hashValue`
    /// (seeded per launch) or hashing a different string.
    @Test("An old root folder's palette is fixed by its id")
    func derived() throws {
        let ids = try ["00000000-0000-0000-0000-000000000001", "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"]
            .map { try #require(UUID(uuidString: $0)) }
        #expect(ids.map(FolderPalette.derived(from:)) == [.lilac, .aurora])
    }

    /// WCAG 2 contrast for normal text, against the grouped background (#F2F2F7, darker than
    /// white) and the lightest dark grouped surface (#2C2C2E). Catches: a new or edited accent too
    /// light (or too dark) to read as text.
    @Test("Every accent is readable on its background", arguments: FolderPalette.allCases)
    func accentContrast(palette: FolderPalette) {
        #expect(Self.contrast(palette.light.accent, 0xF2F2F7) >= 4.5)
        #expect(Self.contrast(palette.dark.accent, 0x2C2C2E) >= 4.5)
    }

    private static func contrast(_ first: UInt32, _ second: UInt32) -> Double {
        let (lighter, darker) = (max(luminance(first), luminance(second)), min(luminance(first), luminance(second)))
        return (lighter + 0.05) / (darker + 0.05)
    }

    private static func luminance(_ rgb: UInt32) -> Double {
        func channel(_ shift: UInt32) -> Double {
            let value = Double((rgb >> shift) & 0xFF) / 255
            return value <= 0.039_28 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(16) + 0.7152 * channel(8) + 0.0722 * channel(0)
    }
}
