# Hints
Where the card editor's suggested definition, translation and lemma come from — all offline.
Status: planned (milestone 4); sources pending spikes (milestone 0)

## Rules
- Replaceable sources per language pair: definition, synonyms, translation, lemma (glossary: Hint).
- Definition and synonyms come from the bundled English dictionary (#6). Synonyms tile text:
  comma-separated synonyms of the picked word. (assumption: format, max count)
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
- **Translation framework** (#4, parked). For now the Translation tile is fed by a stub behind
  the translation source; findings so far are on #4 (`en → ru` supported, works only on a
  device, language packs downloaded with the user's permission).
- **Lemmatisation** (#5). System lemma tagging for English.

## Not supported
- Online dictionary for expressions (later, behind a switch); Serbian hints.
