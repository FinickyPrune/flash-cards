# Product docs

Index of what FlashCards is and how it behaves. Read this, then only the docs your task touches.
Formats and update rules: `product-docs` skill. Actionable work: GitHub Issues.

## Foundation
- [vision.md](vision.md): who it's for, principles (private, on-device, no AI), platform, languages (English via screenshots, Serbian via CSV), MVP scope, non-goals.
- [glossary.md](glossary.md): domain terms with code names and ru UI labels.
- [roadmap.md](roadmap.md): MVP milestones 0–6 and the post-MVP list.
- [../architecture.md](../architecture.md): targets, layers, invariants, initial data model (engineering).

## Features
Catalog's folder tree with progress and the card editor for manual cards are shipped; everything else is planned.
- [catalog.md](features/catalog.md): folder tree, progress, Play on any folder.
- [card-editor.md](features/card-editor.md): add/edit screen, four back tiles, folder chip, duplicate check.
- [review.md](features/review.md): review flow, four ratings, session queue, summary.
- [screenshot-import.md](features/screenshot-import.md): entry points, share extension, batch flow, OCR, storage.
- [hints.md](features/hints.md): where the definition, synonyms, translation and lemma come from, offline; coverage.
- [csv.md](features/csv.md): CSV import with preview, folder export.

## Decisions
- [0001](decisions/0001-swiftdata-cloudkit-compatible.md): SwiftData, CloudKit-compatible model, local container.
- [0002](decisions/0002-replaceable-scheduler-and-review-log.md): SM-2-like scheduler behind a protocol, full review log, direction.
- [0003](decisions/0003-store-screenshot-copies.md): cards store a compressed screenshot copy.
- [0004](decisions/0004-share-extension-inbox.md): share extension only drops files into a shared inbox.
- [0005](decisions/0005-ocr-api-and-settings.md): OCR with `RecognizeTextRequest`, accurate, correction on; no Serbian screenshots.
- [0006](decisions/0006-dictionary-source.md): English hints and Russian translations from a trimmed Wiktionary SQLite; CC BY-SA, DRM-free copy per release.
- [0007](decisions/0007-lemma-candidates.md): hint entry and lemma from part of speech in context plus dictionary forms; hyphenated tokens joined.
