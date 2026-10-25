# Architecture
Targets, layers, invariants and the initial data model. Read when planning structural work.

> The data model below is the agreed **initial design**. Once milestone 1 ships, the code is
> the source of truth: trim this file to the invariants and drop the listing.

## Targets
- App target + **Share Extension** target, sharing an **App Group** container that holds `inbox/`.
- The extension never touches SwiftData; it only copies files into `inbox/`.
- Local Swift package **FlashCore** (`Packages/FlashCore`, tests run with `make test`): pure logic without UI or SwiftData — `Scheduler` (SM-2),
  front-key normalisation, CSV parser, tokenisation, session queue building. Unit-tested.

## Layers
View → `@Observable` view model → services → SwiftData.
- Views read data straight from SwiftData (`@Query`, observing models) and never change it.
- Every change goes through the screen's view model, which calls a service protocol
  (`@Mockable`, e.g. `CatalogServicing`). The service owns the rules and the save; view models
  own form state, presentation state and error messages.
- A parent's view model creates its children's and passes the service down: a presenter builds
  its sheets' view models, the view model of the screen that owns a `NavigationStack` builds every
  pushed screen's. The app builds the first one, once, with the real service.
- A view model's `init` is cheap and has no side effects: SwiftUI may build and drop it on any
  parent render. Start work (fetching, lookups) from `.task`.
Services: `TextRecognizer` (Vision OCR), `InboxStore`, `DictionaryService` (bundled read-only
SQLite, decision 0006; backs the definition and synonym providers and the lemma forms),
`CSVImporter`, `SessionBuilder`. Review depends on the `Scheduler` protocol and an array of cards, not on folders.

Hint sources are protocols, swappable per language pair. `TranslationProvider` is backed by
`DictionaryService` (Russian translations, decision 0006). Apple's Translation framework is a
possible later fallback (notes on #4: `TranslationSession(installedSource:target:)`, device only).
```swift
protocol DefinitionProvider { func definition(for term: String, language: String) async -> String? }
protocol SynonymProvider { func synonyms(for term: String, language: String) async -> [String] }
protocol TranslationProvider { func translation(for term: String, from: String, to: String) async -> String? }
protocol Lemmatizer { func lemma(for token: String, language: String) -> String? }
```
Decision 0007 needs more than these signatures: the hint sources take the token with its line
(part of speech in context) and the synonym source the sense the definition used. Reshape
them in milestone 4.

## Frameworks
SwiftUI, Observation, SwiftData, Vision (OCR: `RecognizeTextRequest`, settings in decision 0005), NaturalLanguage (`NLTokenizer`, lemma tagging),
PhotosUI (`PhotosPicker`), StoreKit 2 (tip jar only).

## Invariants
- No network calls except StoreKit (vision principle 1).
- CloudKit-compatible model (decision 0001): every property has a default or is optional,
  every relationship is optional, no `@Attribute(.unique)`, no `.deny` delete rule. Uniqueness
  (duplicates) is enforced in code. Container is local: `cloudKitDatabase: .none`.
- OCR runs on the original image; only the compressed copy is stored (decision 0003).
- Heavy work (OCR, CSV parsing, image compression, bulk queries) runs off the main actor
  (`swift-conventions`).

## Initial data model
```
Folder
  id: UUID
  name: String
  parent: Folder?            // inverse: children
  children: [Folder]?        // cascade
  cards: [Card]?             // cascade
  learningLanguage: String?  // root folder only; subfolders inherit
  backLanguage: String?      // root folder only
  lastBackSource: String?    // last back source used in this root folder
  createdAt: Date

Card
  id: UUID
  folder: Folder?
  front: String
  frontKey: String           // normalised front for duplicate detection
  context: String?
  screenshot: Data?          // compressed JPEG, @Attribute(.externalStorage)
  back: String
  backSource: String         // "definition" | "synonyms" | "translation" | "custom"
  createdAt, updatedAt: Date
  reviewStates: [ReviewState]?  // cascade
  reviewLogs: [ReviewLog]?      // cascade

ReviewState                  // per card and direction, separate from Card
  card: Card?
  direction: String          // "forward" | "reverse"
  dueDate: Date?
  intervalDays: Double
  ease: Double
  repetitions: Int
  lapses: Int

ReviewLog                    // every rating; lets us recompute history for FSRS later
  card: Card?
  direction: String
  rating: Int                // 0 again, 1 hard, 2 good, 3 easy
  reviewedAt: Date
```
