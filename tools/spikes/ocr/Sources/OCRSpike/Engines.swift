import CoreGraphics
import Foundation
import Vision
import VisionKit

/// One recognised line, box normalised with origin bottom-left.
struct Line: Codable {
    var text: String
    var box: CGRect
    /// Lower-ranked candidates for the same line (legacy API only).
    var alternatives: [String] = []
}

/// One API + settings combination under test.
struct Engine: Sendable {
    enum API: String, Sendable {
        case legacy = "VNRecognizeText"
        case swift = "RecognizeText"
        case documents = "RecognizeDocuments"
        case liveText = "ImageAnalyzer"
    }

    var api: API
    var languages: [String]
    var correction: Bool

    var name: String {
        let langs = languages.isEmpty ? "auto" : languages.joined(separator: "+")
        return "\(api.rawValue) [\(langs)]" + (api == .liveText ? "" : correction ? " corr" : " raw")
    }

    func recognize(_ image: CGImage) async throws -> [Line] {
        switch api {
        case .legacy: try legacy(image)
        case .swift: try await swiftRequest(image)
        case .documents: try await documents(image)
        case .liveText: try await liveText(image)
        }
    }

    private func legacy(_ image: CGImage) throws -> [Line] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = correction
        if languages.isEmpty {
            request.automaticallyDetectsLanguage = true
        } else {
            request.recognitionLanguages = languages
        }
        try VNImageRequestHandler(cgImage: image).perform([request])
        return (request.results ?? []).compactMap { observation in
            let candidates = observation.topCandidates(10).map(\.string)
            return candidates.first.map {
                Line(text: $0, box: observation.boundingBox, alternatives: Array(candidates.dropFirst()))
            }
        }
    }

    private func swiftRequest(_ image: CGImage) async throws -> [Line] {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = correction
        if languages.isEmpty {
            request.automaticallyDetectsLanguage = true
        } else {
            request.recognitionLanguages = languages.map { Locale.Language(identifier: $0) }
        }
        return try await request.perform(on: image).compactMap { observation in
            observation.topCandidates(1).first.map { Line(text: $0.string, box: observation.boundingBox.cgRect) }
        }
    }

    private func documents(_ image: CGImage) async throws -> [Line] {
        var request = RecognizeDocumentsRequest()
        request.textRecognitionOptions.useLanguageCorrection = correction
        if !languages.isEmpty {
            request.textRecognitionOptions.recognitionLanguages = languages.map { Locale.Language(identifier: $0) }
        }
        return try await request.perform(on: image).flatMap { observation in
            observation.document.text.lines.compactMap { line in
                line.topCandidates(1).first.map { Line(text: $0.string, box: line.boundingBox.cgRect) }
            }
        }
    }

    /// Live Text returns one transcript without per-line boxes; lines come back with an empty box.
    @MainActor
    private func liveText(_ image: CGImage) async throws -> [Line] {
        var configuration = ImageAnalyzer.Configuration([.text])
        if !languages.isEmpty {
            configuration.locales = languages
        }
        let analysis = try await ImageAnalyzer().analyze(image, orientation: .up, configuration: configuration)
        return analysis.transcript.split(separator: "\n").map { Line(text: String($0), box: .null) }
    }
}
