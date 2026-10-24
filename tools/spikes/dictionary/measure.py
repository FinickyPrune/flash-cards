"""Spike #6: coverage of a dictionary built by build.py on subtitle words and phrases.

    python3 -I tools/spikes/dictionary/measure.py <dict.sqlite> <en_50k.txt> <en_50k.lemmas.tsv> \
        [--names <names.txt>] [--samples]

en_50k.txt: OpenSubtitles frequency list (hermitdave/FrequencyWords, 2018/en), "word count" per line.
en_50k.lemmas.tsv: NLTagger lemma per word, from `tools/spikes/lemma/lemma.swift --list`.
A word is found when the word, its system lemma, a `form` row or a WordNet-style suffix rule
leads to an entry, and only then an `alias` row. The same lookup runs for every dictionary.
names.txt: words that are only proper names in Wiktionary; left out of the word counts.
"""

import os
import sqlite3
import sys

PHRASES = [
    # phrasal verbs
    "give up", "figure out", "find out", "show up", "turn out", "come up with", "get away with",
    "hang out", "freak out", "make up", "break up", "work out", "pass out", "back off",
    "calm down", "look forward to", "run into", "put up with", "get over", "check out",
    "screw up", "mess up", "pull over", "shut up", "sort out", "come across", "bring up",
    "blow up", "chill out", "hook up", "rip off", "stand up for", "take over", "tell off",
    "walk out", "wind up", "zone out", "bail out", "cheer up", "cut off",
    # idioms and set phrases
    "break a leg", "piece of cake", "under the weather", "no way", "cut it out", "my bad",
    "big deal", "for real", "by the way", "get the hang of", "on the house", "out of the blue",
    "spill the beans", "call it a day", "in a nutshell", "kill time", "hit the road",
    "once in a blue moon", "the last straw", "pull someone's leg", "sleep on it", "deal breaker",
    "game changer", "heads up", "no big deal", "red flag", "small talk", "wake-up call",
    "long story short", "keep in touch",
]
# Detachment rules in the spirit of WordNet's morphy, tried after the form table.
SUFFIX_RULES = [
    ("ies", "y"), ("ves", "f"), ("ves", "fe"), ("ses", "s"), ("xes", "x"), ("zes", "z"),
    ("ches", "ch"), ("shes", "sh"), ("men", "man"), ("es", "e"), ("es", ""), ("s", ""),
    ("ied", "y"), ("ed", "e"), ("ed", ""), ("ing", "e"), ("ing", ""),
    ("ier", "y"), ("iest", "y"), ("er", ""), ("est", ""), ("er", "e"), ("est", "e"),
]
BUCKETS = [(0, 1000), (1000, 5000), (5000, 10000), (10000, 20000), (20000, 50000)]
SAMPLES = [
    "run", "leave", "deal", "mean", "awkward", "grab", "stubborn", "nonsense", "scared",
    "bother", "gorgeous", "betray", "sneaky", "hangover", "reckon", "wimp", "smug", "rant",
    "creepy", "dude", "binge", "ghost", "snitch", "salty", "lit", "crush", "bail", "gaslight",
]


class Dictionary:
    def __init__(self, path):
        self.db = sqlite3.connect(path)
        self.words = {row[0] for row in self.db.execute("SELECT DISTINCT word FROM entry")}
        self.forms, self.aliases = {}, {}
        for form, lemma in self.db.execute("SELECT form, lemma FROM form"):
            self.forms.setdefault(form, set()).add(lemma)
        if self.db.execute("SELECT 1 FROM sqlite_master WHERE name = 'alias'").fetchone():
            for form, target in self.db.execute("SELECT form, target FROM alias"):
                self.aliases.setdefault(form, set()).add(target)

    def headword(self, word, system_lemma=None):
        """The entry a tapped word resolves to, or None."""
        candidates = [word]
        if system_lemma:
            candidates.append(system_lemma.lower())
        candidates += sorted(self.forms.get(word, ()))
        candidates += [word[: -len(old)] + new for old, new in SUFFIX_RULES if word.endswith(old)]
        candidates += sorted(self.aliases.get(word, ()))
        return next((c for c in candidates if c in self.words), None)

    def senses(self, word):
        return self.db.execute(
            "SELECT s.gloss, e.pos FROM sense s JOIN entry e ON e.id = s.entry "
            "WHERE e.word = ? ORDER BY e.id, s.n", (word,)
        ).fetchall()

    def synonyms(self, word, first_sense_only):
        query = (
            "SELECT DISTINCT y.word FROM synonym y JOIN entry e ON e.id = y.entry WHERE e.word = ?"
            + (" AND e.id = (SELECT MIN(id) FROM entry WHERE word = ?) AND (y.sense = 0 OR y.sense IS NULL)"
               if first_sense_only else "")
        )
        args = (word, word) if first_sense_only else (word,)
        return [row[0] for row in self.db.execute(query, args) if row[0].lower() != word]

    def translations(self, word):
        if not self.db.execute("SELECT 1 FROM sqlite_master WHERE name = 'translation'").fetchone():
            return []
        return [row[0] for row in self.db.execute(
            "SELECT DISTINCT t.word FROM translation t JOIN entry e ON e.id = t.entry WHERE e.word = ?", (word,)
        )]


def load_words(freq_path, lemma_path):
    words = [line.split()[0] for line in open(freq_path, encoding="utf-8")]
    lemmas = dict(line.rstrip("\n").split("\t") for line in open(lemma_path, encoding="utf-8"))
    return words, lemmas


def main():
    path, freq_path, lemma_path = sys.argv[1:4]
    dictionary = Dictionary(path)
    words, lemmas = load_words(freq_path, lemma_path)
    names = set()
    if "--names" in sys.argv:
        names = set(open(sys.argv[sys.argv.index("--names") + 1], encoding="utf-8").read().split("\n"))
    print(f"# {os.path.basename(path)}: {os.path.getsize(path) / 1e6:.1f} MB, {len(dictionary.words)} headwords")
    print("rank          found  any-synonym  first-sense-synonym  translation  misses (sample)")
    for low, high in BUCKETS:
        bucket = [w for w in words[low:high] if w.isalpha() and len(w) > 1 and w not in names]
        found = synonym_any = synonym_first = translated = 0
        misses = []
        for word in bucket:
            head = dictionary.headword(word, lemmas.get(word))
            if not head:
                misses.append(word)
                continue
            found += 1
            synonym_any += bool(dictionary.synonyms(head, first_sense_only=False))
            synonym_first += bool(dictionary.synonyms(head, first_sense_only=True))
            translated += bool(dictionary.translations(head))
        print(
            f"{low + 1:>5}-{high:<6} {found / len(bucket):6.1%} {synonym_any / len(bucket):12.1%}"
            f" {synonym_first / len(bucket):20.1%} {translated / len(bucket):12.1%}  {' '.join(misses[:12])}"
        )
    phrases = [p for p in PHRASES if dictionary.headword(p) or dictionary.headword(p.replace("someone's", "one's"))]
    missing = [p for p in PHRASES if p not in phrases and p.replace("someone's", "one's") not in phrases]
    print(f"phrases: {len(phrases)}/{len(PHRASES)} found; missing: {', '.join(missing)}")
    if "--samples" in sys.argv:
        for word in SAMPLES:
            senses = dictionary.senses(word)
            first = f"[{senses[0][1]}] {senses[0][0]}" if senses else "∅"
            print(f"\n{word} ({len(senses)} senses): {first}")
            print(f"   synonyms(1st): {', '.join(dictionary.synonyms(word, True)[:8]) or '∅'}")
            print(f"   synonyms(all): {', '.join(dictionary.synonyms(word, False)[:10]) or '∅'}")
            if dictionary.translations(word):
                print(f"   translations:  {', '.join(dictionary.translations(word)[:8])}")


main()
