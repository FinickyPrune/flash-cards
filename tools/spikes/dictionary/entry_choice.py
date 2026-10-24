"""Spike #6: which entry the Definition tile should use for a token, on the lemma spike's gold tokens.

    lemma --gold > data/freq/gold.tsv     # tools/spikes/lemma/lemma.swift
    python3 -I entry_choice.py out/kaikki-vocab-ru.sqlite data/freq/gold.tsv

gold.tsv: token, NLTagger lemma in context, NLTagger lexical class, expected lemma. The expected
entry is the expected lemma's ("saw" in "I saw him" -> "see"; "left" in "turn left" -> "left").
- word first: the token's own entry when it has one, else its lemma (the rule before review);
- by part of speech: an inflection row of the token with the context's part of speech wins
  ("saw" verb -> "see"), then the token's own entry with that part of speech, then the system
  lemma, then the token's entry of any part of speech.
"""

import sqlite3
import sys

POS = {"Noun": "noun", "Verb": "verb", "Adjective": "adj", "Adverb": "adv"}


def main():
    db = sqlite3.connect(sys.argv[1])
    entries = {}
    for word, pos in db.execute("SELECT word, pos FROM entry"):
        entries.setdefault(word, set()).add(pos)
    forms = {}
    for form, lemma, pos in db.execute("SELECT form, lemma, pos FROM form"):
        forms.setdefault(form, []).append((lemma, pos))

    def word_first(token, lemma, _):
        if token in entries:
            return token
        return lemma if lemma in entries else next((l for l, _ in forms.get(token, []) if l in entries), None)

    def by_part_of_speech(token, lemma, lexical_class):
        pos = POS.get(lexical_class)
        inflections = [l for l, p in forms.get(token, []) if p == pos and pos in entries.get(l, ())]
        if inflections:
            return lemma if lemma in inflections else inflections[0]
        if pos in entries.get(token, ()):
            return token
        if lemma != token and lemma in entries:
            return lemma
        return token if token in entries else None

    rules = {"word first": word_first, "by part of speech": by_part_of_speech}
    right = dict.fromkeys(rules, 0)
    rows = [line.rstrip("\n").split("\t") for line in open(sys.argv[2], encoding="utf-8")]
    for token, lemma, lexical_class, expected in rows:
        token, lemma, expected = token.lower(), lemma.lower(), expected.lower()
        picks = {name: rule(token, lemma, lexical_class) for name, rule in rules.items()}
        for name, pick in picks.items():
            right[name] += pick == expected
        if len(set(picks.values())) > 1 or picks["by part of speech"] != expected:
            shown = ", ".join(f"{name}: {pick}" for name, pick in picks.items())
            print(f"  {token} ({lexical_class}) expected {expected} | {shown}")
    for name, count in right.items():
        print(f"{name}: {count}/{len(rows)} right")


main()
