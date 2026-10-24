# 0007. Lemma and hint entry from NLTagger in context plus the dictionary's forms
Status: accepted (2026-10-24)

## Context
Spike #5 (`tools/spikes/lemma/lemma.swift`, macOS 26.6; ru/es not checked, English only in
the MVP): `NLTagger` `.lemma` on 49 subtitle-like lines got 81 of 88 tokens right in context,
79 alone. Misses: `saw`, `felt`, `better` unchanged; `left` (direction) → `leave`. `NLTokenizer`
keeps contractions whole (`I'm`, `mother's`), splits hyphenated words, drops `♪`, `-`, `...`.
Many inflections are headwords too (`saw`, `running`, `years`): taking the token's own entry
picked the expected entry for 39 of 85 tokens.

## Decision
- Hint entry: an inflection row of the token with the part of speech `NLTagger` gives it in
  the line (`saw` verb → `see`); else the token's entry with that part of speech; else the
  system lemma; else any entry of the token; else an alias (`tv` → `television`).
  83 of 85 right (`entry_choice.py`); misses: `left` in "turn left" tagged as a verb, `humiliated`.
- When that entry's headword differs from the token, the front starts as the headword
  (owner's choice, 2026-10-24) and a toggle switches it to the form in the text; a wrong
  lemma costs one tap. Toggling changes only the front; hints are not recomputed.
- The picker joins hyphenated tokens without spaces (`well-known`); they get a lemma only
  from inflection rows.

## Alternatives
- System lemma only — misses irregular forms. Token's own entry first — wrong for half.

## Consequences
The hint sources take the token with its line, not a bare word. A language without a
dictionary falls back to the system lemma.
