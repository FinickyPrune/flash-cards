# 0007. Lemma from NLTagger in context, checked against the dictionary's forms
Status: accepted (2026-10-24)

## Context
Spike #5 (`tools/spikes/lemma/lemma.swift`): `NLTagger` `.lemma` on 50 subtitle-like lines got
81 of 88 tokens right in context (92%), 79 alone. Misses: some irregular past forms
(`saw`, `felt` unchanged), `better` unchanged, `left` (direction) → `leave`. `NLTokenizer` keeps
contractions whole (`I'm`, `mother's`) but splits hyphenated words (`well-known` → 2 tokens).
Wiktionary's inflection rows (decision 0006) map `saw` → `see`, `felt` → `feel`, `better` → `good`.

## Decision
- Lemma candidates for a token: the system lemma (tagging the whole line), then the
  dictionary's inflection targets. A candidate is used only if it is a dictionary headword and
  differs from the token. The first one is the lemma the toggle offers.
- The front starts as the form in the text; the toggle is never applied automatically, so a
  wrong lemma (`left` → `leave`) costs one tap at most.
- The word picker joins tokens written with a hyphen and no spaces (`well-known`) into one token.
- Spelling and abbreviation aliases (`tv` → `television`) are used only for lookup when the token
  has no entry, never as a lemma.

## Alternatives
- System lemma only — misses common irregular forms.
- Dictionary forms only — no context: `leaves` would be both `leave` and `leaf`.

## Consequences
The Lemmatizer depends on the dictionary. A language without a dictionary falls back to the
system lemma.
