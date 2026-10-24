# 0006. English hints from a trimmed Wiktionary SQLite bundled with the app
Status: accepted (2026-10-24)

## Context
Spike #6 built Open English WordNet 2025 and the English Wiktionary (kaikki.org, 2026-10-21)
into one SQLite schema and measured them on the OpenSubtitles top 50k words, names excluded
(`tools/spikes/dictionary`). Top 20k words: Wiktionary finds 96–99%, WordNet 88–93%; 70 phrasal
verbs and idioms: 65 vs 47. WordNet has more synonyms (74–87% vs 55–81%) but dated,
sense-mismatched ones ("hangover" → katzenjammer) and no informal senses.

## Decision
- Source: English Wiktionary via kaikki.org, rebuilt by a script in `tools/`; bundled read-only.
- Kept: headwords a subtitle word leads to (top 50k words, their lemmas, what their forms point
  to), multi-word entries of top-20k words; up to 10 senses each, minus obsolete / archaic /
  rare / dated. Without translations 56 MB on disk, ~24 MB compressed; with Russian 60 / ~25 MB.
- Synonyms: entry-written first, thesaurus ones by frequency; tagged vulgar, offensive,
  derogatory or obsolete dropped; at most 6.
- Definitions stay English for `en → ru`: English Wiktionary has no Russian definitions.
- The Translation tile uses the Russian translations in the same data (72–89% of the top 20k
  words, +~1.5 MB compressed), not Apple's Translation framework (owner, 2026-10-24).
- License: the file is an adaptation under CC BY-SA 4.0; app code is unaffected. In the app:
  "Wiktionary contributors", kaikki.org, FrequencyWords, license link, "modified". The file is
  also published DRM-free per release (CC FAQ: parallel distribution). Not legal advice.
  Release checklist: #11.
- Updates: rebuilt from a pinned kaikki dump (sha256 kept with the script) only when there is
  a reason (coverage gaps, build-rule fixes), at most a few times a year, and shipped with an
  app release. (assumption) Cards store the back as text, so an update never changes existing cards.

## Alternatives
- Open English WordNet (CC BY 4.0, 32 MB) — misses 7–12% of common words and most idioms.
- WordNet as a synonym fallback — senses don't line up with Wiktionary's; maybe later.
- System dictionary — no API for definition text on iOS.
- Online Wiktionary API — breaks "on-device, no network" and offline use, sends the user's
  words out; the same CC BY-SA attribution would still apply (only the DRM issue goes away).

## Consequences
18–28% of common words are headwords and also forms of another (`saw`): the entry is picked
by part of speech (decision 0007). Translations into other back languages need a rebuild with them.
