# 0005. OCR with RecognizeTextRequest, accurate, language correction on; no Serbian screenshots
Status: accepted (2026-10-24)

## Context
Spike #3 compared four Apple text APIs on 70 synthetic subtitle screenshots (Serbian Latin and
English) and real English ones (`tools/spikes/ocr`). No API supports Serbian or Croatian
(30 languages on macOS 26, 33 on iOS 27). On Serbian, base letters were right but ć and đ were
often lost (79–88% of diacritic words right). English was 0.0% CER with language correction
on, on synthetic and real screenshots. Serbian cards come from CSV in the MVP.

## Decision
- Vision's Swift `RecognizeTextRequest`, `.accurate`, `usesLanguageCorrection = true`.
- `recognitionLanguages` = the folder's learning language when supported; otherwise
  `automaticallyDetectsLanguage = true`.
- One observation per line; tokens without letters are dropped; subtitle-looking lines
  (centred, lowest) are shown first (`features/screenshot-import.md`).
- Screenshots in unsupported languages (Serbian) are not an MVP use case.

## Alternatives
- `VNRecognizeTextRequest` — same accuracy on English, slightly better on Serbian diacritics
  with correction off; older completion-style API.
- `RecognizeDocumentsRequest` — 2× slower, worse on small text.
- VisionKit `ImageAnalyzer` (Live Text) — no per-line boxes, merges UI text into the transcript.
- Serbian via a nearby language + dictionary diacritic restoration — possible later; with
  correction on, half the missed words appear in lower-ranked candidates.

## Consequences
English screenshot cards need no OCR fixes in practice. Serbian OCR would need its own work
(post-MVP). Timing measured on a Mac (50–200 ms per screenshot); check on a device in milestone 3.
