// Spike #4: programmatic translation with installed languages, latency and failure modes.
//   swiftc -O -o translate tools/spikes/translation/translate.swift
//   ./translate <source> <target> term...
import Foundation
import Translation

setvbuf(stdout, nil, _IOLBF, 0)

let arguments = Array(CommandLine.arguments.dropFirst())
let source = Locale.Language(identifier: arguments[0])
let target = Locale.Language(identifier: arguments[1])
let terms = Array(arguments.dropFirst(2))

func elapsed(since start: Date) -> String {
    String(format: "%5.0f ms  ", Date().timeIntervalSince(start) * 1000)
}

func run(_ label: String, _ make: () -> TranslationSession) async {
    let session = make()
    let ready = await session.isReady
    print("== \(label): isReady=\(ready) canRequestDownloads=\(session.canRequestDownloads)")
    for term in terms {
        let start = Date()
        do {
            let response = try await session.translate(term)
            print(elapsed(since: start) + "\(term) → \(response.targetText)")
        } catch {
            print(elapsed(since: start) + "\(term) → ERROR \(error)")
        }
    }
}

await run("default") { TranslationSession(installedSource: source, target: target) }
if #available(macOS 26.4, *) {
    await run("lowLatency") {
        TranslationSession(installedSource: source, target: target, preferredStrategy: .lowLatency)
    }
    await run("highFidelity") { TranslationSession(
        installedSource: source,
        target: target,
        preferredStrategy: .highFidelity
    ) }
}
