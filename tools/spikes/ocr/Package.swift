// swift-tools-version: 6.2
// OCR spike harness (issue #3). Not part of the app; run with `swift run -c release ocr-spike`.
import PackageDescription

let package = Package(
    name: "OCRSpike",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(name: "ocr-spike", path: "Sources/OCRSpike"),
    ]
)
