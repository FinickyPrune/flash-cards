# Hints
Where the card editor's suggested definition, synonyms, translation and lemma come from — all offline.
Status: planned (milestone 4); sources: decisions 0006, 0007

## Rules
- Replaceable sources per language pair: definition, synonyms, translation, lemma (glossary: Hint).
- Definition and synonyms come from the bundled English dictionary: trimmed Wiktionary in a
  read-only SQLite (decision 0006). Case-insensitive.
- Entry: picked from the token and its part of speech in the line, so `saw` in "I saw him"
  gives `see` (decision 0007). Definition tile: that entry's first sense, in English, also for
  `en → ru` folders. Showing other senses is (to be defined).
- Synonyms tile: comma-separated, at most 6, of the same sense; else the entry's own list;
  else empty. Synonyms tagged vulgar, offensive or obsolete are dropped (tags are incomplete).
  (assumption: format)
- Translation tile: Russian translations from the same dictionary, comma-separated, at most 6;
  those of the same sense first, else the entry's own; stress marks removed. Only for folders
  whose back language is Russian; otherwise empty. (assumption: format) (decision 0006)
- Hints are computed once, when the editor opens for a token; the lemma toggle doesn't change them.
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
- Definition: 96–99%. Synonyms: 55–81%, on the first sense or the entry's list 39–60%.
  Russian translations in the same data: 72–89%. Phrasal verbs and idioms: 65 of 70 sampled.
- Words Wiktionary has only as proper names (people, cities) get no definition.

## Not supported
- Online dictionary for expressions (later, behind a switch); Serbian hints.
- Apple's Translation framework: not in the MVP; maybe later as a fallback for words the
  dictionary has no translation for (findings on #4).
