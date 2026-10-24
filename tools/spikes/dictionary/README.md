# Dictionary spike (#6)

Builds comparable read-only SQLite dictionaries from Open English WordNet and the English
Wiktionary (kaikki.org extract) and measures them on subtitle vocabulary. Python 3 standard
library only; not part of the app. Lemma spike (#5): `tools/spikes/lemma/lemma.swift`.

```bash
cd tools/spikes/dictionary           # data/ and out/ are gitignored here, not at the repo root
mkdir -p data/{oewn,kaikki,freq} out
curl -L -o data/oewn/oewn-2025.xml.gz https://github.com/globalwordnet/english-wordnet/releases/download/2025-edition/english-wordnet-2025.xml.gz
curl -L -o data/kaikki/en.jsonl.gz https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl.gz   # 534 MB, latest dump
curl -L -o data/freq/en_50k.txt https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/en/en_50k.txt
swiftc -O -o out/lemma ../lemma/lemma.swift
out/lemma --list data/freq/en_50k.txt > data/freq/en_50k.lemmas.tsv
out/lemma --gold > data/freq/gold.tsv
python3 -I build.py names data/kaikki/en.jsonl.gz data/freq/names.txt

python3 -I build.py oewn data/oewn/oewn-2025.xml.gz out/oewn.sqlite
python3 -I build.py kaikki data/kaikki/en.jsonl.gz out/kaikki.sqlite                  # everything
python3 -I build.py kaikki data/kaikki/en.jsonl.gz out/kaikki-vocab-ru.sqlite \
    --trim --vocab data/freq/en_50k.txt data/freq/en_50k.lemmas.tsv --translations ru   # the candidate
python3 -I measure.py out/kaikki-vocab-ru.sqlite data/freq/en_50k.txt data/freq/en_50k.lemmas.tsv \
    --names data/freq/names.txt --samples
python3 -I entry_choice.py out/kaikki-vocab-ru.sqlite data/freq/gold.tsv
gzip -9 -c out/kaikki-vocab-ru.sqlite | wc -c                                          # download-size estimate
```

Numbers in decision 0006 come from these inputs (sha256):
- kaikki dump of 2026-10-21: `cabb3a13b7179d5f8c5909e06b1dcd2e2ae6465d05f35de56509a5b4e2bf0a49`
- OEWN 2025: `9ca6d1dcb75f822fdd66617f7d9da48142ace38dd544d6ad5e2feca1674ad3fe`
- en_50k.txt: `5351ff405b1126ef555791dd4d9798a48e3e9a501a9fc481a9da957752cfb458`

`measure.py` reports per frequency band of the OpenSubtitles list (names excluded): share of
words that resolve to an entry, share that are also an inflection of another headword, share
with any synonym, with a synonym on the first sense or the entry's own list, with a Russian
translation; 70 phrasal verbs and idioms; first sense, synonyms and translations of 28 words.
`entry_choice.py` compares two rules for picking the Definition tile's entry on the lemma
spike's 85 gold tokens.
