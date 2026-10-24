"""Spike #6: build comparable read-only SQLite dictionaries from Open English WordNet and Wiktionary.

Run from tools/spikes/dictionary (README.md has the downloads):
    python3 -I build.py oewn  <english-wordnet-2025.xml.gz>   out/oewn.sqlite
    python3 -I build.py kaikki <kaikki.org-dictionary-English.jsonl.gz> out/kaikki.sqlite \
        [--trim] [--vocab <en_50k.txt> <en_50k.lemmas.tsv>] [--translations ru]
    python3 -I build.py names <kaikki.org-dictionary-English.jsonl.gz> data/freq/names.txt

Standard library only. Same schema for both sources, so `measure.py` compares them directly:
  entry(id, word, pos)                     one headword per part of speech, word in lower case
  sense(entry, n, gloss, tags)             in source order (both sources list common senses first)
  synonym(entry, sense, word)              sense is NULL when the source gives synonyms per entry
  form(form, lemma, pos)                   inflected form -> headword ("saw" -> "see"); pos of the form
  alias(form, target)                      Wiktionary only: spelling or abbreviation -> headword ("tv" -> "television")
  translation(entry, sense, word)          Wiktionary only, with --translations <code>; stress marks removed
--trim keeps at most 10 senses per entry and drops obsolete / archaic / rare senses.
--vocab keeps only headwords a subtitle can lead to: the frequency list's words, their system lemmas
and the lemmas their forms point to, plus multi-word entries made of the top 20k words. Synonyms are
then ranked by subtitle frequency, filtered by tag and capped.
`names` writes the words that are only proper names in Wiktionary, lower case, for `measure.py --names`.
"""

import gzip
import json
import os
import sqlite3
import sys
import xml.etree.ElementTree as ET

SCHEMA = """
CREATE TABLE entry(id INTEGER PRIMARY KEY, word TEXT NOT NULL, pos TEXT NOT NULL);
CREATE TABLE sense(entry INTEGER NOT NULL, n INTEGER NOT NULL, gloss TEXT NOT NULL, tags TEXT);
CREATE TABLE synonym(entry INTEGER NOT NULL, sense INTEGER, word TEXT NOT NULL);
CREATE TABLE form(form TEXT NOT NULL, lemma TEXT NOT NULL, pos TEXT NOT NULL);
CREATE TABLE alias(form TEXT NOT NULL, target TEXT NOT NULL);
CREATE TABLE translation(entry INTEGER NOT NULL, sense INTEGER, word TEXT NOT NULL);
"""
INDEXES = """
CREATE INDEX entry_word ON entry(word);
CREATE INDEX sense_entry ON sense(entry);
CREATE INDEX synonym_entry ON synonym(entry);
CREATE INDEX form_form ON form(form);
CREATE INDEX alias_form ON alias(form);
CREATE INDEX translation_entry ON translation(entry);
"""
OEWN_POS = {"n": "noun", "v": "verb", "a": "adj", "s": "adj", "r": "adv"}
# Wiktionary parts of speech that make sense as a card front.
KAIKKI_POS = {
    "noun", "verb", "adj", "adv", "phrase", "intj", "prep_phrase", "proverb", "pron",
    "contraction", "prep", "num", "conj", "det", "particle", "article", "postp",
}
DROPPED_TAGS = {"obsolete", "archaic", "rare", "dated"}
# A "form of" sense counts as an inflection (not an abbreviation or spelling) only with one of these.
DROPPED_FORM_TAGS = DROPPED_TAGS | {"dialectal", "nonstandard", "misspelling"}
INFLECTION_TAGS = {"plural", "past", "participle", "present", "third-person", "gerund", "comparative", "superlative"}
DROPPED_SYNONYM_TAGS = DROPPED_TAGS | {"vulgar", "offensive", "derogatory", "pejorative", "ethnic", "slur"}
MAX_TRIMMED_SENSES = 10
MAX_SYNONYMS = 6
MAX_TRANSLATIONS = 6
MAX_ALIASES = 3
STRESS_MARK = "\u0301"
PHRASE_VOCABULARY = 20000
UNRANKED = 10**6


def open_db(path):
    if os.path.exists(path):
        os.remove(path)
    db = sqlite3.connect(path)
    db.executescript(SCHEMA)
    return db


def finish(db):
    db.executescript(INDEXES)
    db.commit()
    db.execute("VACUUM")
    db.close()


def build_oewn(source, db):
    """Synonyms of a sense are the other members of its synset."""
    synsets = {}   # synset id -> (definition, [member entry ids])
    entries = []   # (entry id, lemma, pos, [synset ids], [irregular forms])
    for _, element in ET.iterparse(gzip.open(source), events=("end",)):
        if element.tag == "LexicalEntry":
            lemma = element.find("Lemma")
            entries.append((
                element.get("id"),
                lemma.get("writtenForm"),
                OEWN_POS[lemma.get("partOfSpeech")],
                [sense.get("synset") for sense in element.findall("Sense")],
                [form.get("writtenForm") for form in element.findall("Form")],
            ))
            element.clear()
        elif element.tag == "Synset":
            definition = element.findtext("Definition") or ""
            synsets[element.get("id")] = (definition, element.get("members").split())
            element.clear()
    lemma_of = {entry_id: lemma for entry_id, lemma, _, _, _ in entries}
    for entry_id, lemma, pos, synset_ids, forms in entries:
        row = db.execute("INSERT INTO entry(word, pos) VALUES (?, ?)", (lemma.lower(), pos)).lastrowid
        for n, synset_id in enumerate(synset_ids):
            definition, members = synsets[synset_id]
            db.execute("INSERT INTO sense VALUES (?, ?, ?, NULL)", (row, n, definition))
            for member in members:
                if member != entry_id:
                    db.execute("INSERT INTO synonym VALUES (?, ?, ?)", (row, n, lemma_of[member]))
        for form in forms:
            db.execute("INSERT INTO form VALUES (?, ?, ?)", (form.lower(), lemma.lower(), pos))


class Vocabulary:
    """Which Wiktionary headwords to keep and how common a word is in subtitles."""

    def __init__(self, freq_path, lemma_path, source):
        words = [line.split()[0].lower() for line in open(freq_path, encoding="utf-8")]
        self.rank = {word: n for n, word in reversed(list(enumerate(words)))}
        self.phrase_words = set(words[:PHRASE_VOCABULARY])
        self.keep = set(words)
        for line in open(lemma_path, encoding="utf-8"):
            self.keep.add(line.rstrip("\n").split("\t")[1].lower())
        self.common = set(self.keep)
        # Lemmas that forms of kept words point to ("saw" -> "see") must be kept too.
        for data in english_entries(source):
            if data["word"].lower() in self.keep:
                for sense in data.get("senses", []):
                    for target in sense.get("form_of", []) + sense.get("alt_of", []):
                        self.keep.add(target["word"].lower())

    def keeps(self, word):
        parts = word.replace("-", " ").split()
        return word in self.keep or (len(parts) > 1 and all(part in self.phrase_words for part in parts))

    def synonym_rank(self, word):
        """Single words before phrases, then by the rarest part's subtitle rank."""
        parts = word.lower().replace("-", " ").split() or [word]
        return len(parts) > 1, max(self.rank.get(part, UNRANKED) for part in parts)


def english_entries(source):
    for line in gzip.open(source, "rt", encoding="utf-8"):
        data = json.loads(line)
        if data.get("lang_code") == "en" and data.get("pos") in KAIKKI_POS:
            yield data


def usable_synonyms(word, synonyms, vocabulary):
    """Synonym words without dropped tags; with a vocabulary, capped.

    Synonyms written in the entry come first, in the editors' order. Thesaurus pages list theirs
    alphabetically, so those follow, most common in subtitles first.
    """
    direct, thesaurus = [], []
    for synonym in synonyms:
        candidate = synonym["word"]
        if set(synonym.get("tags", [])) & DROPPED_SYNONYM_TAGS or candidate.lower() == word:
            continue
        (thesaurus if synonym.get("source") else direct).append(candidate)
    if vocabulary:
        thesaurus.sort(key=vocabulary.synonym_rank)
    result = list(dict.fromkeys(direct + thesaurus))
    return result[:MAX_SYNONYMS] if vocabulary else result


def translations_of(item, language):
    """Distinct translations into `language` of an entry or sense, in source order."""
    words = [t["word"].replace(STRESS_MARK, "") for t in item.get("translations", [])
             if t.get("code") == language and t.get("word")]
    return list(dict.fromkeys(words))[:MAX_TRANSLATIONS]


def build_kaikki(source, db, trim, vocabulary, language=None):
    """Senses that are only "form of X" become rows in `form`, not glosses.

    Spellings and abbreviations ("tv" -> "television") go to `alias`, only for entries without senses
    of their own and, with a vocabulary, only to common targets: the app uses them only when a word
    has no entry, so "saw" never resolves to "squad automatic weapon" (the "SAW" entry).
    """
    for data in english_entries(source):
        word = data["word"].lower()
        if vocabulary and not vocabulary.keeps(word):
            continue
        senses, alternatives = [], []
        for sense in data.get("senses", []):
            tags = set(sense.get("tags", []))
            if "form-of" in tags or "alt-of" in tags:
                if "form-of" in tags and tags & INFLECTION_TAGS and not tags & DROPPED_FORM_TAGS:
                    for target in sense.get("form_of", []):
                        db.execute("INSERT INTO form VALUES (?, ?, ?)", (word, target["word"].lower(), data["pos"]))
                else:
                    alternatives += [target["word"].lower() for target in sense.get("form_of", []) + sense.get("alt_of", [])]
                continue
            glosses = sense.get("glosses")
            if not glosses or (trim and tags & DROPPED_TAGS):
                continue
            senses.append((
                glosses[-1],
                tags,
                usable_synonyms(word, sense.get("synonyms", []), vocabulary),
                translations_of(sense, language) if language else [],
            ))
        if trim:
            senses = senses[:MAX_TRIMMED_SENSES]
        if not senses:
            targets = [t for t in dict.fromkeys(alternatives) if not vocabulary or t in vocabulary.common]
            for target in targets[:MAX_ALIASES]:
                db.execute("INSERT INTO alias VALUES (?, ?)", (word, target))
            continue
        row = db.execute("INSERT INTO entry(word, pos) VALUES (?, ?)", (word, data["pos"])).lastrowid
        for n, (gloss, tags, synonyms, translations) in enumerate(senses):
            db.execute("INSERT INTO sense VALUES (?, ?, ?, ?)", (row, n, gloss, ",".join(sorted(tags)) or None))
            for synonym in synonyms:
                db.execute("INSERT INTO synonym VALUES (?, ?, ?)", (row, n, synonym))
            for translation in translations:
                db.execute("INSERT INTO translation VALUES (?, ?, ?)", (row, n, translation))
        for translation in translations_of(data, language) if language else []:
            db.execute("INSERT INTO translation VALUES (?, NULL, ?)", (row, translation))
        for synonym in usable_synonyms(word, data.get("synonyms", []), vocabulary):
            db.execute("INSERT INTO synonym VALUES (?, NULL, ?)", (row, synonym))
        for form in data.get("forms", []):
            tags = set(form.get("tags", []))
            if tags & ({"table-tags", "inflection-template", "romanization"} | DROPPED_FORM_TAGS):
                continue
            if form["form"].lower() != word:
                db.execute("INSERT INTO form VALUES (?, ?, ?)", (form["form"].lower(), word, data["pos"]))


def write_names(source, target):
    names, others = set(), set()
    for line in gzip.open(source, "rt", encoding="utf-8"):
        data = json.loads(line)
        if data.get("lang_code") == "en":
            (names if data.get("pos") == "name" else others).add(data["word"].lower())
    with open(target, "w", encoding="utf-8") as file:
        file.write("\n".join(sorted(names - others)))


def main():
    kind, source, target = sys.argv[1:4]
    if kind == "names":
        write_names(source, target)
        return
    db = open_db(target)
    if kind == "oewn":
        build_oewn(source, db)
    else:
        vocabulary = None
        if "--vocab" in sys.argv:
            flag = sys.argv.index("--vocab")
            vocabulary = Vocabulary(sys.argv[flag + 1], sys.argv[flag + 2], source)
        language = sys.argv[sys.argv.index("--translations") + 1] if "--translations" in sys.argv else None
        build_kaikki(source, db, trim="--trim" in sys.argv, vocabulary=vocabulary, language=language)
    finish(db)
    print(f"{target}: {os.path.getsize(target) / 1e6:.1f} MB")


main()
