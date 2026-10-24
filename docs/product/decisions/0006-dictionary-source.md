# 0006. English hints from a trimmed Wiktionary SQLite bundled with the app
Status: accepted (2026-10-24)

## Context
Spike #6 built Open English WordNet 2025 and the English Wiktionary (kaikki.org, 2026-10-21)
into the same SQLite schema and measured them on the OpenSubtitles top 50k words, proper names
excluded (`tools/spikes/dictionary`). Top 20k words: Wiktionary finds 96–99%, WordNet 89–94%;
70 phrasal verbs and idioms: 65 vs 47. WordNet has more synonyms (75–88% vs 55–81%) but
dated, sense-mismatched ones ("hangover" → katzenjammer) and no informal senses.

## Decision
- Source: English Wiktionary via kaikki.org, rebuilt by a script in `tools/` (from
  `tools/spikes/dictionary/build.py`). Bundled read-only, opened in place.
- Kept: headwords a subtitle word leads to (top 50k words, their lemmas, the lemmas their
  forms point to) and multi-word entries made of top-20k words. Up to 10 senses per entry,
  minus obsolete / archaic / rare / dated ones. 58 MB on disk, ~25 MB compressed.
- Synonyms: written in the entry first (editors' order), thesaurus ones after, most common
  first; vulgar, offensive, derogatory and obsolete ones dropped; at most 6.
- Definition tile: English, the entry whose part of speech matches the token in context, its first sense.
- License: CC BY-SA 4.0. Attribution in the app (Wiktionary, kaikki.org; FrequencyWords for
  the selection). The built file is also published DRM-free with each release (GitHub release),
  which CC's FAQ accepts alongside DRM distribution such as the App Store.

## Alternatives
- Open English WordNet (CC BY 4.0, 32 MB) — misses 6–9% of common words and most idioms.
- WordNet as a synonym fallback — senses don't line up with Wiktionary's; maybe later.
- System dictionary — no API for definition text on iOS.

## Consequences
Russian translations are in the same data (72–89% of the top 20k): a possible Translation
source, owner to decide on #4. Sense choice beyond the first sense is open (`hints.md`).
