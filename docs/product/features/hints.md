# Hints
Where the card editor's suggested definition, translation and lemma come from — all offline.
Status: planned (milestone 4); sources chosen (decisions 0006, 0007), translation parked (#4)

## Rules
- Replaceable sources per language pair: definition, synonyms, translation, lemma (glossary: Hint).
- Definition and synonyms come from the bundled English dictionary: trimmed Wiktionary in a
  read-only SQLite (decision 0006). Lookup goes word → lemma candidates → alias (`tv` →
  `television`); case-insensitive.
- Entry: the one whose part of speech matches the token in its line (`NLTagger`), else the
  first. Definition tile: that entry's first sense, in English, also for `en → ru` folders.
  Showing other senses is (to be defined).
- Synonyms tile: comma-separated, at most 6, of the same sense; else the entry's own list;
  else empty. Vulgar, offensive and obsolete synonyms are never shown. (assumption: format)
- Lemma: decision 0007; the card editor's toggle uses it.
- Every source is offline and on-device (vision principle 1).
- Hints in the MVP cover **English** as the learning language. Serbian gets no hints: its cards
  come from CSV or manual entry (vision). Other languages get a hint only where a source
  happens to support them.
- The system dictionary screen can't return definition text, so the Definition tile needs our
  own offline source, for English too. The system dictionary may appear only as a
  "Look up in dictionary" button.
- Attribution in the app: Wiktionary (CC BY-SA 4.0), kaikki.org, FrequencyWords. The built
  dictionary file is also published DRM-free with each release (decision 0006).

## Coverage (OpenSubtitles top 20k words, names excluded; decision 0006)
- Definition: 96–99%. Synonyms: 55–81%, on the first sense 39–60%. Phrasal verbs and idioms:
  65 of 70 sampled.

## Spikes
- **Translation** (#4, parked). The Translation tile is fed by a stub behind the translation
  source. Options on #4: Apple's Translation framework (`en → ru` supported, device only,
  language packs downloaded with the user's permission) or the Russian translations already
  in the Wiktionary data (72–89% of the top 20k words). Owner decides.

## Not supported
- Online dictionary for expressions (later, behind a switch); Serbian hints.
