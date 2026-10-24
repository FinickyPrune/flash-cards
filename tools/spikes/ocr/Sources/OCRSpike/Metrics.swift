import CoreGraphics
import Foundation

/// Scores for one sample under one engine.
struct Score: Codable {
    var file: String
    var truth: String
    var predicted: String
    var distance: Int
    var truthChars: Int
    var words: Int
    var wordsRight: Int
    var diacriticWords: Int
    var diacriticWordsRight: Int
    /// Diacritic words whose letters are right once diacritics are stripped.
    var diacriticWordsFolded: Int
    var linesMatch: Bool
    var noiseLines: Int
    var seconds: Double
    /// Truth word → closest predicted word, for diacritic words that came back wrong.
    var misses: [String: String]
    /// Missed diacritic words that appear in a lower-ranked candidate of the same line.
    var inAlternatives: Int = 0
}

enum Metrics {
    static let diacritics = Set("čćšžđČĆŠŽĐ")

    static func score(_ sample: Sample, lines: [Line], seconds: Double) -> Score {
        let area = sample.subtitleBox.insetBy(dx: -0.03, dy: -0.03)
        // Live Text has no boxes: treat everything that isn't known noise as subtitle.
        let subtitle = lines
            .filter { $0.box.isNull ? !sample.noise.contains($0.text) : area.contains(CGPoint(
                x: $0.box.midX,
                y: $0.box.midY
            )) }
            .sorted { $0.box.isNull || $1.box.isNull ? false : $0.box.midY > $1.box.midY }
        let truth = normalise(sample.lines.joined(separator: " "))
        let predicted = normalise(subtitle.map(\.text).joined(separator: " "))

        let truthWords = words(truth)
        var pool = words(predicted)
        var right = 0
        var diacriticTotal = 0
        var diacriticRight = 0
        var diacriticFolded = 0
        var misses: [String: String] = [:]
        let foldedPool = Set(pool.map(fold))
        let alternativeWords = Set(subtitle.flatMap(\.alternatives).flatMap(words))
        var inAlternatives = 0
        for word in truthWords {
            let hasDiacritic = word.contains { diacritics.contains($0) }
            if hasDiacritic {
                diacriticTotal += 1
            }
            if let index = pool.firstIndex(of: word) {
                pool.remove(at: index)
                right += 1
                if hasDiacritic {
                    diacriticRight += 1; diacriticFolded += 1
                }
            } else if hasDiacritic {
                if foldedPool.contains(fold(word)) {
                    diacriticFolded += 1
                }
                if alternativeWords.contains(word) {
                    inAlternatives += 1
                }
                misses[word] = pool.min { distance(Array($0), Array(word)) < distance(Array($1), Array(word)) } ?? "∅"
            }
        }
        return Score(
            file: sample.file, truth: truth, predicted: predicted,
            distance: distance(Array(truth), Array(predicted)), truthChars: truth.count,
            words: truthWords.count, wordsRight: right,
            diacriticWords: diacriticTotal, diacriticWordsRight: diacriticRight, diacriticWordsFolded: diacriticFolded,
            linesMatch: subtitle.count == sample.lines.count,
            noiseLines: lines.count - subtitle.count, seconds: seconds, misses: misses,
            inAlternatives: inAlternatives
        )
    }

    static func normalise(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    static func words(_ text: String) -> [String] {
        text.lowercased().split { !$0.isLetter && $0 != "'" && $0 != "’" }.map(String.init)
    }

    static func fold(_ word: String) -> String {
        word.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).replacingOccurrences(
            of: "đ",
            with: "d"
        )
    }

    /// Levenshtein distance.
    static func distance(_ lhs: [Character], _ rhs: [Character]) -> Int {
        if lhs.isEmpty {
            return rhs.count
        }
        if rhs.isEmpty {
            return lhs.count
        }
        var previous = Array(0 ... rhs.count)
        for (i, left) in lhs.enumerated() {
            var current = [i + 1] + Array(repeating: 0, count: rhs.count)
            for (j, right) in rhs.enumerated() {
                current[j + 1] = min(previous[j + 1] + 1, current[j] + 1, previous[j] + (left == right ? 0 : 1))
            }
            previous = current
        }
        return previous[rhs.count]
    }
}
