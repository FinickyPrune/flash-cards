# OCR spike (#3)

Compares Apple's text-recognition APIs and language settings on subtitle screenshots,
Serbian Latin and English. Runs on macOS (same Vision models as iOS); not part of the app.

```bash
cd tools/spikes/ocr
swift build -c release
.build/release/ocr-spike generate              # 70 synthetic screenshots + truth.json → out/synthetic
.build/release/ocr-spike run                   # every engine on out/synthetic → table on stdout
.build/release/ocr-spike run real "cs-CZ"      # real set, only engines whose name contains "cs-CZ"
```

- **Synthetic set**: subtitle-style lines (outline / shadow / box, white or yellow, 5 fonts)
  over procedural backgrounds, landscape full-screen and portrait letterboxed with clock and
  timecodes as noise. Deterministic (fixed seed).
- **Real set**: `real/` with screenshots and a hand-written `truth.json` in the same format.
  Gitignored: frames from shows are copyrighted.
- Per-sample predictions land in `out/results/<set>/<engine>.json`.

Metrics: CER on the subtitle text; share of words exactly right; of words with č ć š ž đ,
share exactly right and share right once diacritics are ignored; share of screenshots where
the subtitle came back as the right number of lines; noise lines returned; ms per image.
