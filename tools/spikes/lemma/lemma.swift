// Spike #5: NLTagger lemmas and NLTokenizer words on subtitle-like English lines.
//   swiftc -O -o lemma tools/spikes/lemma/lemma.swift && ./lemma [--words]
// --words also prints every token's lemma, for spotting failures outside the gold set.
import Foundation
import NaturalLanguage

/// A subtitle line and the lemmas expected for some of its tokens (token text → lemma).
struct Case {
    let line: String
    let gold: [String: String]
}

let cases: [Case] = [
    Case(line: "I'm running late, don't wait for me.", gold: ["running": "run", "wait": "wait"]),
    Case(line: "She ran away before they caught her.", gold: ["ran": "run", "caught": "catch"]),
    Case(line: "We've been looking everywhere for you!", gold: ["been": "be", "looking": "look"]),
    Case(line: "The children were hiding under the stairs.", gold: [
        "children": "child", "were": "be", "hiding": "hide", "stairs": "stair",
    ]),
    Case(line: "He's the best liar I've ever met.", gold: ["best": "good", "met": "meet"]),
    Case(line: "That was better than I expected.", gold: ["better": "good", "expected": "expect"]),
    Case(line: "I saw him leave with two women.", gold: ["saw": "see", "leave": "leave", "women": "woman"]),
    Case(line: "They left the keys on the table.", gold: ["left": "leave", "keys": "key"]),
    Case(line: "Turn left at the lights.", gold: ["left": "left", "lights": "light"]),
    Case(line: "Those mice chewed through the wires.", gold: ["mice": "mouse", "chewed": "chew", "wires": "wire"]),
    Case(line: "She has studied the problem for years.", gold: ["studied": "study", "years": "year"]),
    Case(line: "He's lying, he always lies.", gold: ["lying": "lie", "lies": "lie"]),
    Case(line: "You've gotten taller since last summer.", gold: ["gotten": "get", "taller": "tall"]),
    Case(line: "The bigger they are, the harder they fall.", gold: ["bigger": "big", "harder": "hard"]),
    Case(line: "Stop being so stubborn.", gold: ["being": "be", "stubborn": "stubborn"]),
    Case(line: "I've never felt so humiliated.", gold: ["felt": "feel", "humiliated": "humiliate"]),
    Case(line: "Who's knocking at this hour?", gold: ["knocking": "knock", "hour": "hour"]),
    Case(line: "They're digging up the garden.", gold: ["digging": "dig", "garden": "garden"]),
    Case(line: "We were sitting in the car for hours.", gold: ["sitting": "sit", "hours": "hour"]),
    Case(line: "Nobody believes a word she says.", gold: ["believes": "believe", "says": "say"]),
    Case(line: "Those were the happiest days of my life.", gold: ["happiest": "happy", "days": "day"]),
    Case(line: "He fled the country with stolen money.", gold: ["fled": "flee", "stolen": "steal"]),
    Case(line: "The wolves howled all night.", gold: ["wolves": "wolf", "howled": "howl"]),
    Case(line: "My feet are killing me.", gold: ["feet": "foot", "killing": "kill"]),
    Case(line: "She's been bullied at school.", gold: ["bullied": "bully"]),
    Case(line: "I bet you've forgotten my birthday.", gold: ["bet": "bet", "forgotten": "forget"]),
    Case(line: "The analyses were wrong.", gold: ["analyses": "analysis"]),
    Case(line: "He quit his job and moved to Lisbon.", gold: ["quit": "quit", "moved": "move"]),
    Case(line: "You're overthinking it.", gold: ["overthinking": "overthink"]),
    Case(line: "They texted me twice.", gold: ["texted": "text"]),
    Case(line: "She ghosted him after the second date.", gold: ["ghosted": "ghost"]),
    Case(line: "We're freaking out here!", gold: ["freaking": "freak"]),
    Case(line: "I've been binge-watching all weekend.", gold: ["binge-watching": "binge-watch"]),
    Case(line: "It's a well-known fact.", gold: ["well-known": "well-known"]),
    Case(line: "He's a self-made man.", gold: ["self-made": "self-made"]),
    Case(line: "Gonna grab some coffee, wanna come?", gold: ["grab": "grab"]),
    Case(line: "Y'all need to calm down.", gold: ["calm": "calm"]),
    Case(line: "She's got her mother's eyes.", gold: ["got": "get", "eyes": "eye"]),
    Case(
        line: "Their cries echoed down the hallways.",
        gold: ["cries": "cry", "echoed": "echo", "hallways": "hallway"]
    ),
    Case(line: "The ships sank within minutes.", gold: ["ships": "ship", "sank": "sink", "minutes": "minute"]),
    Case(line: "I wish I'd known sooner.", gold: ["known": "know", "sooner": "soon"]),
    Case(line: "Everything's falling apart.", gold: ["falling": "fall"]),
    Case(line: "He was sentenced to life.", gold: ["sentenced": "sentence"]),
    Case(line: "The leaves are turning red.", gold: ["leaves": "leaf", "turning": "turn"]),
    Case(line: "She leaves tomorrow morning.", gold: ["leaves": "leave"]),
    Case(line: "THEY'RE COMING FOR US.", gold: ["COMING": "come"]),
    Case(line: "Wait... What did you just say?", gold: ["did": "do", "say": "say"]),
    Case(line: "- Where are you going? - Home.", gold: ["going": "go"]),
    Case(line: "♪ We're dancing in the moonlight ♪", gold: ["dancing": "dance"]),
    Case(line: "Rock 'n' roll never dies.", gold: ["dies": "die"]),
]

let printWords = CommandLine.arguments.contains("--words")

/// Word tokens of a line, as the word picker would show them.
func tokens(of line: String) -> [(String, Range<String.Index>)] {
    let tokenizer = NLTokenizer(unit: .word)
    tokenizer.string = line
    return tokenizer.tokens(for: line.startIndex ..< line.endIndex).map { (String(line[$0]), $0) }
}

/// Lemma of each token range, tagging the whole line (context) or the token alone.
func lemmas(of line: String, inContext: Bool) -> [String: String?] {
    var result: [String: String?] = [:]
    for (token, range) in tokens(of: line) {
        let text = inContext ? line : token
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        tagger.setLanguage(.english, range: text.startIndex ..< text.endIndex)
        let index = inContext ? range.lowerBound : text.startIndex
        let (tag, _) = tagger.tag(at: index, unit: .word, scheme: .lemma)
        result[token] = tag?.rawValue
    }
    return result
}

// --list <file>: lemma of each word (first column) alone, as "word<TAB>lemma", for the dictionary spike.
if let flag = CommandLine.arguments.firstIndex(of: "--list") {
    let path = CommandLine.arguments[flag + 1]
    let words = try String(contentsOfFile: path, encoding: .utf8).split(separator: "\n")
        .compactMap { $0.split(separator: " ").first.map(String.init) }
    for word in words {
        print("\(word)\t\((lemmas(of: word, inContext: false)[word] ?? nil) ?? "")")
    }
    exit(0)
}

var totals = (context: 0, alone: 0, missing: 0, all: 0)
var failures: [String] = []
for item in cases {
    let context = lemmas(of: item.line, inContext: true)
    let alone = lemmas(of: item.line, inContext: false)
    if printWords {
        let shown = tokens(of: item.line).map { "\($0.0)→\((context[$0.0] ?? nil) ?? "∅")" }
        print(shown.joined(separator: "  "))
    }
    for (token, expected) in item.gold.sorted(by: { $0.key < $1.key }) {
        totals.all += 1
        guard let found = context[token] else {
            failures.append("NOT A TOKEN  \(token)  in \"\(item.line)\"  tokens: \(tokens(of: item.line).map(\.0))")
            continue
        }
        let inContext = found?.lowercased()
        let isolated = (alone[token] ?? nil)?.lowercased()
        if inContext == expected {
            totals.context += 1
        }
        if isolated == expected {
            totals.alone += 1
        }
        if found == nil {
            totals.missing += 1
        }
        if inContext != expected || isolated != expected {
            failures.append(
                "\(token) → context: \(inContext ?? "∅"), alone: \(isolated ?? "∅"), expected: \(expected)"
            )
        }
    }
}

func percent(_ part: Int) -> String {
    String(format: "%.0f%%", Double(part) / Double(totals.all) * 100)
}

print("\nGold tokens: \(totals.all)")
print("In context right: \(totals.context) (\(percent(totals.context)))")
print("Alone right:      \(totals.alone) (\(percent(totals.alone)))")
print("No lemma (context): \(totals.missing)")
print("\nMisses:")
failures.forEach { print("  \($0)") }
