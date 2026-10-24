// OCR spike harness for issue #3.
//   swift run -c release ocr-spike generate            # synthetic set → out/synthetic
//   swift run -c release ocr-spike run [set] [filter]  # set: out/synthetic (default) or real
import CoreGraphics
import Foundation
import ImageIO

let arguments = CommandLine.arguments.dropFirst()
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func engines() -> [Engine] {
    let languageSets: [[String]] = [
        ["en-US"], ["cs-CZ"], ["pl-PL"], ["vi-VT"], ["cs-CZ", "pl-PL"], ["cs-CZ", "pl-PL", "vi-VT"], [],
    ]
    var list: [Engine] = []
    for languages in languageSets {
        for correction in [false, true] {
            list.append(Engine(api: .legacy, languages: languages, correction: correction))
        }
    }
    for api in [Engine.API.swift, .documents] {
        for languages in [["en-US"], ["cs-CZ"], ["cs-CZ", "pl-PL"]] {
            list.append(Engine(api: api, languages: languages, correction: false))
        }
    }
    for languages in [["en-US"], ["cs-CZ"], []] {
        list.append(Engine(api: .liveText, languages: languages, correction: true))
    }
    return list
}

func load(_ url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { throw SpikeError.load(url.path) }
    return image
}

func percent(_ part: Int, _ whole: Int) -> String {
    whole == 0 ? "–" : String(format: "%.1f%%", Double(part) * 100 / Double(whole))
}

func report(_ scores: [Score], engine: String, group: String) -> String {
    let chars = scores.reduce(0) { $0 + $1.truthChars }
    let distance = scores.reduce(0) { $0 + $1.distance }
    let words = scores.reduce(0) { $0 + $1.words }
    let right = scores.reduce(0) { $0 + $1.wordsRight }
    let diacritic = scores.reduce(0) { $0 + $1.diacriticWords }
    let diacriticRight = scores.reduce(0) { $0 + $1.diacriticWordsRight }
    let folded = scores.reduce(0) { $0 + $1.diacriticWordsFolded }
    let lines = scores.count(where: \.linesMatch)
    let noise = scores.reduce(0) { $0 + $1.noiseLines }
    let milliseconds = scores.reduce(0) { $0 + $1.seconds } * 1000 / Double(max(scores.count, 1))
    return "| \(group) | \(engine) | \(percent(distance, chars)) | \(percent(right, words)) | "
        + "\(percent(diacriticRight, diacritic)) | \(percent(folded, diacritic)) | "
        + "\(percent(lines, scores.count)) | \(noise) | \(Int(milliseconds)) |"
}

func run(setDir: URL, filter: String?) async throws {
    let samples = try JSONDecoder().decode(
        [Sample].self,
        from: Data(contentsOf: setDir.appendingPathComponent("truth.json"))
    )
    let images = try samples.map { try load(setDir.appendingPathComponent($0.file)) }
    let resultsDir = root.appendingPathComponent("out/results/\(setDir.lastPathComponent)")
    try FileManager.default.createDirectory(at: resultsDir, withIntermediateDirectories: true)

    var rows: [String] = []
    for engine in engines() where filter.map({ engine.name.contains($0) }) ?? true {
        var scores: [Score] = []
        for (sample, image) in zip(samples, images) {
            // English is only scored with settings a user would pick for English.
            if sample.language == "en", !(engine.languages == ["en-US"] || engine.languages.isEmpty) {
                continue
            }
            let start = Date()
            let lines = try await engine.recognize(image)
            scores.append(Metrics.score(sample, lines: lines, seconds: Date().timeIntervalSince(start)))
        }
        let groups = Dictionary(grouping: zip(scores, samples.filter { sample in
            scores.contains { $0.file == sample.file }
        })) { "\($0.1.language) \($0.1.layout)" }
        for (group, pairs) in groups.sorted(by: { $0.key < $1.key }) {
            rows.append(report(pairs.map(\.0), engine: engine.name, group: group))
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let fileName = engine.name.replacingOccurrences(of: "[^A-Za-z0-9+-]+", with: "_", options: .regularExpression)
        try encoder.encode(scores).write(to: resultsDir.appendingPathComponent("\(fileName).json"))
        FileHandle.standardError.write(Data("done \(engine.name)\n".utf8))
    }
    print(
        "| Set | Engine | CER | Words | Diacritic words | …ignoring diacritics | Line count ok | Noise lines | ms/img |"
    )
    print("|---|---|---|---|---|---|---|---|---|")
    rows.sorted().forEach { print($0) }
}

switch arguments.first {
case "generate":
    try Generator.run(outDir: root.appendingPathComponent("out/synthetic"), seed: 20_261_024)
case "run":
    let set = arguments.dropFirst().first ?? "out/synthetic"
    try await run(setDir: root.appendingPathComponent(set), filter: arguments.dropFirst(2).first)
default:
    print("usage: ocr-spike generate | run [set] [engine-filter]")
}
