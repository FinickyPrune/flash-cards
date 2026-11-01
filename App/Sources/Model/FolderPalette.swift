import Foundation

/// A folder's colours: two gradient hues and an accent, for light and dark mode (`catalog.md`).
/// Stored on `Folder.palette` by raw value, so cases may be added but never renamed.
enum FolderPalette: String, CaseIterable, Sendable {
    case lagoon, indigo, mint, arctic, glacier, aurora, lilac, rose

    /// sRGB colours as `0xRRGGBB`.
    struct Colors: Equatable, Sendable {
        let first: UInt32
        let second: UInt32
        let accent: UInt32
    }

    var light: Colors {
        switch self {
        case .lagoon: Colors(first: 0x45C4E6, second: 0x7EDFB8, accent: 0x0B7285)
        case .indigo: Colors(first: 0x7C7CF4, second: 0x7FCBF7, accent: 0x4F46E5)
        case .mint: Colors(first: 0x5CD6B3, second: 0x79B8F3, accent: 0x0E7C6B)
        case .arctic: Colors(first: 0x93AEFF, second: 0xA9EDEC, accent: 0x3B5BDB)
        case .glacier: Colors(first: 0x8FD3F4, second: 0xB8C6FF, accent: 0x1D6FA3)
        case .aurora: Colors(first: 0x7DE3C3, second: 0xB59CF6, accent: 0x6D28D9)
        case .lilac: Colors(first: 0xB59CF6, second: 0xF2A7D4, accent: 0x7E22CE)
        case .rose: Colors(first: 0xF4A2B8, second: 0xC4B3FA, accent: 0xBE185D)
        }
    }

    /// Deeper hues for the near-black background and lighter accents that stay readable on it.
    var dark: Colors {
        switch self {
        case .lagoon: Colors(first: 0x2BA9CC, second: 0x3FBF8F, accent: 0x5FD0E6)
        case .indigo: Colors(first: 0x5B5BE8, second: 0x4FA6E0, accent: 0xA5A3FF)
        case .mint: Colors(first: 0x2FB892, second: 0x4A93D9, accent: 0x5EDBB8)
        case .arctic: Colors(first: 0x6C8BFF, second: 0x62CFCB, accent: 0x9FB4FF)
        case .glacier: Colors(first: 0x4FAEDB, second: 0x7F95F0, accent: 0x8CCBF0)
        case .aurora: Colors(first: 0x3FC79F, second: 0x8E6DEB, accent: 0xC4B0FF)
        case .lilac: Colors(first: 0x8E6DEB, second: 0xD873B0, accent: 0xCDB5FF)
        case .rose: Colors(first: 0xE06C8E, second: 0x9A82F0, accent: 0xFF9EC2)
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .lagoon: "Lagoon"
        case .indigo: "Indigo"
        case .mint: "Mint"
        case .arctic: "Arctic"
        case .glacier: "Glacier"
        case .aurora: "Aurora"
        case .lilac: "Lilac"
        case .rose: "Rose"
        }
    }

    /// The palette a new root folder starts with: the first one no root folder uses yet; once all
    /// are taken, they repeat in order.
    static func forNewRoot(used: [FolderPalette]) -> FolderPalette {
        allCases.first { !used.contains($0) } ?? allCases[used.count % allCases.count]
    }

    /// The palette of a root folder stored before palettes existed. FNV-1a over the id's string,
    /// not `hashValue`, which is seeded per launch.
    static func derived(from id: UUID) -> FolderPalette {
        let hash = id.uuidString.utf8.reduce(UInt32(2_166_136_261)) { ($0 ^ UInt32($1)) &* 16_777_619 }
        return allCases[Int(hash % UInt32(allCases.count))]
    }
}
