# Hints
Where the card editor's suggested definition, translation and lemma come from — all offline.
Status: planned (milestone 3); sources pending spikes (milestone 0)

## Rules
- Three replaceable sources per language pair: definition, translation, lemma (glossary: Hint).
- Every source is offline and on-device (vision principle 1).
- Serbian in the MVP: an offline dictionary bundled with the app, plus manual entry.
  Serbian is Latin script only.
- The system dictionary screen can't return definition text, so the Definition tile needs our
  own offline source, for English too. The system dictionary may appear only as a
  "Look up in dictionary" button.
- A bundled dictionary needs its license attribution in the app (Wiktionary: CC BY-SA).

## Spikes (milestone 0, decide before building tiles)
- **Dictionary source.** Offline Wiktionary extracts (e.g. kaikki.org): English Wiktionary
  (English definitions; for `sr → ru` chain a translation `en → ru`) and/or Russian
  Wiktionary (Russian directly; check Serbo-Croatian coverage). Built into a read-only SQLite
  by a script in `tools/`. Measure size and coverage; check CC BY-SA share-alike terms. Also
  store word forms → lemma, which solves Serbian morphology.
- **Translation framework.** Which pairs exist on iOS 26 (`en ↔ ru`, `es`, `sr`?) and how
  language-pack downloads work.
- **Lemmatisation.** System lemma tagging for en, ru, es, sr.

## Not supported
- Online dictionary for expressions (later, behind a switch); synonyms.
