# Vision
An iPhone app that turns screenshots (e.g. of subtitled shows) into flash cards in a few taps and helps you learn them.

## Who and why
Language learners who meet new words in shows, apps and articles. Making cards by hand is the
step people skip, so the product's main value is **minimum effort to create a card**.

## Principles
1. **Private, on-device.** Screenshots, OCR, dictionaries and translations never leave the
   device. No network requests in the MVP, except StoreKit for the tip jar. No analytics or
   tracking; App Store privacy label "Data Not Collected".
2. **No AI tutoring.** No cloud models, no local LLMs.
3. **Suggestions over typing.** The app proposes the word, context and back text; the user
   picks. "Screenshot → card" takes a few taps. Manual entry is always available.
4. **Language-agnostic cards.** A card is two sides of text and/or image; the language is
   secondary.
5. **Fully offline** (system language-pack downloads aside).
6. **Standard iOS 26 SwiftUI components**, dark mode, Dynamic Type, VoiceOver on main screens.

## Platform and distribution
- iPhone only, iOS 26+. iPad later (layout differs).
- App Store, free; monetisation is a tip jar (StoreKit 2 consumables).
- UI languages: en and ru in the first release, es maybe later.
- iCloud sync is not in the MVP, but the data model stays CloudKit-compatible
  (decision 0001).
- First learning pair in focus: Serbian (Latin script only) → Russian; English is also expected.

## MVP scope
Catalog of nested folders, card editor, review game with spaced repetition, screenshot import
(in-app picker and share extension) with OCR and hints, CSV import/export.
Milestones and the post-MVP list: `roadmap.md`.

## Non-goals (MVP)
- Several back variants per card; synonyms; tags.
- Reverse-direction review UI (the model allows it, decision 0002).
- Notifications, widgets, iCloud sync, iPad.
- Serbian Cyrillic; online dictionaries.
- Hiding "obvious" words (the, и, je) — accepted idea, depends on the learner's level, later.
