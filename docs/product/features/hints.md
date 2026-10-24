# Hints
Where the card editor's suggested definition, translation and lemma come from — all offline.
Status: planned (milestone 3); sources pending spikes (milestone 0)

## Rules
- Three replaceable sources per language pair: definition, translation, lemma (glossary: Hint).
- Every source is offline and on-device (vision principle 1).
- Hints in the MVP cover **English** as the learning language. Serbian gets no hints: its cards
  come from CSV or manual entry (vision). Other languages get a hint only where a source
  happens to support them.
- The system dictionary screen can't return definition text, so the Definition tile needs our
  own offline source, for English too. The system dictionary may appear only as a
  "Look up in dictionary" button.
- A bundled dictionary needs its license attribution in the app (Wiktionary: CC BY-SA).

## Spikes (milestone 0, decide before building tiles)
- **Dictionary source** (#6). Offline English definitions from Wiktionary extracts
  (e.g. kaikki.org), built into a read-only SQLite by a script in `tools/`. Measure size and
  coverage; check CC BY-SA share-alike terms; store word forms → lemma.
- **Translation framework** (#4). Which pairs exist on iOS 26 (`en → ru` first) and how
  language-pack downloads work.
- **Lemmatisation** (#5). System lemma tagging for English.

## Not supported
- Online dictionary for expressions (later, behind a switch); synonyms; Serbian hints.
