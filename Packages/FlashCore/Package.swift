// swift-tools-version: 6.2
import PackageDescription

/// Pure logic without UI or SwiftData (docs/architecture.md → Targets).
let package = Package(
    name: "FlashCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "FlashCore", targets: ["FlashCore"]),
    ],
    targets: [
        .target(
            name: "FlashCore",
            swiftSettings: [.treatAllWarnings(as: .error)]
        ),
        .testTarget(
            name: "FlashCoreTests",
            dependencies: ["FlashCore"],
            swiftSettings: [.treatAllWarnings(as: .error)]
        ),
    ]
)
