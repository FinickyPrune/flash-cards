# Dictionary spike (#6)

Builds comparable read-only SQLite dictionaries from Open English WordNet and the English
Wiktionary (kaikki.org extract) and measures them on subtitle vocabulary. Python 3 standard
library only; not part of the app. Lemma spike (#5): `tools/spikes/lemma/lemma.swift`.

```bash
mkdir -p data/{oewn,kaikki,freq} out    # sources are big and licensed separately: keep them out of git
curl -L -o data/oewn/oewn-2025.xml.gz https://github.com/globalwordnet/english-wordnet/releases/download/2025-edition/english-wordnet-2025.xml.gz
curl -L -o data/kaikki/en.jsonl.gz https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl.gz   # 534 MB
curl -L -o data/freq/en_50k.txt https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/en/en_50k.txt
swiftc -O -o out/lemma ../lemma/lemma.swift && out/lemma --list data/freq/en_50k.txt > data/freq/en_50k.lemmas.tsv

python3 -I build.py oewn data/oewn/oewn-2025.xml.gz out/oewn.sqlite
python3 -I build.py kaikki data/kaikki/en.jsonl.gz out/kaikki.sqlite                  # everything, ~207 MB
python3 -I build.py kaikki data/kaikki/en.jsonl.gz out/kaikki-vocab-ru.sqlite \
    --trim --vocab data/freq/en_50k.txt data/freq/en_50k.lemmas.tsv --translations ru   # the candidate, ~58 MB
python3 -I measure.py out/kaikki-vocab-ru.sqlite data/freq/en_50k.txt data/freq/en_50k.lemmas.tsv --samples
```

`measure.py --names <file>` leaves words that are only proper names in Wiktionary out of the
counts (`pos == "name"` and no other part of speech; extracted from the same kaikki file).

Measures per frequency band of the OpenSubtitles list: share of words that resolve to an entry
(via the word, its system lemma, a form row, suffix rules or an alias), share with any synonym,
with a synonym on the first sense, with a Russian translation; 70 phrasal verbs and idioms;
first sense, synonyms and translations of 28 sample words.
