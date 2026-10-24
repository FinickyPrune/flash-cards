import AppKit
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Ground truth for one generated screenshot.
struct Sample: Codable {
    var file: String
    var language: String // "sr" | "en"
    var layout: String // "landscape" | "portrait"
    var style: String // "outline" | "shadow" | "box"
    var lines: [String]
    /// Subtitle area in normalised coordinates, origin bottom-left (Vision's convention).
    var subtitleBox: CGRect
    /// Non-subtitle text drawn on the screenshot (clock, timecodes, logo).
    var noise: [String]
}

/// Deterministic RNG so the synthetic set is reproducible from a seed.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// What one generated screenshot shows.
struct SampleSpec {
    var sentence: String
    var language: String
    var layout: String
    var style: String
}

/// How a subtitle line is drawn.
struct TextLook {
    var font: String
    var size: CGFloat
    var yellow: Bool
    var style: String
}

enum Generator {
    static let fonts = ["Helvetica Neue", "Arial", "Avenir Next", "Verdana", "Trebuchet MS"]
    static let styles = ["outline", "shadow", "box"]

    static func run(outDir: URL, seed: UInt64) throws {
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        var rng = SplitMix64(state: seed)
        var samples: [Sample] = []
        let sets = [("sr", Corpus.serbian), ("en", Corpus.english)]
        for (language, sentences) in sets {
            for (index, sentence) in sentences.enumerated() {
                for layout in ["landscape", "portrait"] {
                    let style = styles[(index + (layout == "portrait" ? 1 : 0)) % styles.count]
                    let file = "\(language)-\(String(format: "%02d", index))-\(layout).png"
                    let spec = SampleSpec(sentence: sentence, language: language, layout: layout, style: style)
                    let sample = try render(spec, file: outDir.appendingPathComponent(file), rng: &rng)
                    samples.append(sample)
                }
            }
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(samples).write(to: outDir.appendingPathComponent("truth.json"))
        print("Generated \(samples.count) screenshots in \(outDir.path)")
    }

    // swiftlint:disable:next function_body_length
    static func render(_ spec: SampleSpec, file: URL, rng: inout SplitMix64) throws -> Sample {
        let portrait = spec.layout == "portrait"
        let size = portrait ? CGSize(width: 1179, height: 2556) : CGSize(width: 2556, height: 1179)
        // Video frame: whole screen in landscape, a 16:9 band in portrait.
        let video = portrait
            ? CGRect(x: 0, y: (size.height - 663) / 2, width: size.width, height: 663)
            : CGRect(origin: .zero, size: size)
        guard let ctx = CGContext(
            data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, // swiftlint:disable:this force_unwrapping
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { throw SpikeError.render }

        ctx.setFillColor(CGColor(gray: 0, alpha: 1))
        ctx.fill(CGRect(origin: .zero, size: size))
        drawScene(in: video, ctx: ctx, rng: &rng)

        let fontName = fonts.randomElement(using: &rng) ?? "Helvetica Neue"
        let fontSize = portrait ? CGFloat.random(in: 30 ... 40, using: &rng) : CGFloat.random(
            in: 54 ... 72,
            using: &rng
        )
        let yellow = Int.random(in: 0 ..< 5, using: &rng) == 0
        let look = TextLook(font: fontName, size: fontSize, yellow: yellow, style: spec.style)
        let lines = Corpus.lines(for: spec.sentence, maxChars: portrait ? 38 : 42)
        let lineHeight = fontSize * 1.25
        let bottom = video.minY + video.height * 0.07
        var subtitleBox = CGRect.null
        for (offset, line) in lines.reversed().enumerated() {
            let origin = CGPoint(x: video.midX, y: bottom + CGFloat(offset) * lineHeight)
            let rect = drawText(line, look: look, center: origin, ctx: ctx)
            subtitleBox = subtitleBox.union(rect)
        }

        var noise: [String] = []
        if portrait {
            noise = ["9:41", "1:02:13", "-24:51"]
            drawLabel("9:41", at: CGPoint(x: 120, y: size.height - 110), size: 34, ctx: ctx)
            drawLabel("1:02:13", at: CGPoint(x: 60, y: video.minY - 70), size: 26, ctx: ctx)
            drawLabel("-24:51", at: CGPoint(x: size.width - 160, y: video.minY - 70), size: 26, ctx: ctx)
        } else if Bool.random(using: &rng) {
            noise = ["S2 E5"]
            drawLabel("S2 E5", at: CGPoint(x: 80, y: size.height - 90), size: 30, ctx: ctx)
        }

        guard let image = ctx.makeImage(),
              let dest = CGImageDestinationCreateWithURL(file as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { throw SpikeError.render }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { throw SpikeError.render }

        let normalised = CGRect(
            x: subtitleBox.minX / size.width, y: subtitleBox.minY / size.height,
            width: subtitleBox.width / size.width, height: subtitleBox.height / size.height
        )
        return Sample(
            file: file.lastPathComponent, language: spec.language, layout: spec.layout, style: spec.style,
            lines: lines, subtitleBox: normalised, noise: noise
        )
    }

    /// A rough "video frame": gradient sky/ground plus soft blobs, sometimes bright behind the text.
    static func drawScene(in rect: CGRect, ctx: CGContext, rng: inout SplitMix64) {
        func color() -> CGColor {
            CGColor(
                red: .random(in: 0 ... 1, using: &rng), green: .random(in: 0 ... 1, using: &rng),
                blue: .random(in: 0 ... 1, using: &rng), alpha: 1
            )
        }
        ctx.saveGState()
        ctx.clip(to: rect)
        let colors = [color(), color(), color()] as CFArray
        if let gradient = CGGradient(
            colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
            colors: colors,
            locations: [0, 0.5, 1]
        ) {
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: rect.maxY),
                end: CGPoint(x: rect.maxX, y: rect.minY),
                options: []
            )
        }
        for _ in 0 ..< 14 {
            let radius = CGFloat.random(in: 40 ... rect.height * 0.5, using: &rng)
            let center = CGPoint(
                x: .random(in: rect.minX ... rect.maxX, using: &rng),
                y: .random(in: rect.minY ... rect.maxY, using: &rng)
            )
            ctx.setFillColor(color().copy(alpha: .random(in: 0.2 ... 0.7, using: &rng)) ?? color())
            ctx.fillEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 1.4
            ))
        }
        ctx.restoreGState()
    }

    /// Draws one line centred on `origin.x` with its baseline at `origin.y`; returns its box.
    @discardableResult
    static func drawText(_ text: String, look: TextLook, center origin: CGPoint, ctx: CGContext) -> CGRect {
        let size = look.size
        let style = look.style
        let nsFont = NSFont(name: look.font, size: size) ?? NSFont.systemFont(ofSize: size, weight: .medium)
        let fill = look.yellow ? NSColor(red: 1, green: 0.92, blue: 0.2, alpha: 1) : NSColor.white
        var attributes: [NSAttributedString.Key: Any] = [.font: nsFont, .foregroundColor: fill]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        // Outline: a thick stroke-only pass first, then the plain fill on top.
        attributes[.strokeColor] = NSColor.black
        attributes[.strokeWidth] = 12
        let outline = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        let start = CGPoint(x: origin.x - width / 2, y: origin.y)
        let box = CGRect(
            x: start.x - size * 0.3,
            y: start.y - size * 0.3,
            width: width + size * 0.6,
            height: size * 1.3
        )
        ctx.saveGState()
        if style == "box" {
            ctx.setFillColor(CGColor(gray: 0, alpha: 0.6))
            ctx.fill(box)
        }
        if style == "shadow" {
            ctx.setShadow(offset: CGSize(width: 2, height: -2), blur: 6, color: CGColor(gray: 0, alpha: 0.95))
        }
        if style == "outline" {
            ctx.textPosition = start
            CTLineDraw(outline, ctx)
        }
        ctx.textPosition = start
        CTLineDraw(line, ctx)
        ctx.restoreGState()
        return box
    }

    static func drawLabel(_ text: String, at point: CGPoint, size: CGFloat, ctx: CGContext) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: .semibold), .foregroundColor: NSColor(white: 0.9, alpha: 1),
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        ctx.textPosition = point
        CTLineDraw(line, ctx)
    }
}

enum SpikeError: Error {
    case render
    case load(String)
}
