# Roadmap
MVP milestones in order, and what comes after. Actionable work for the current milestone is in GitHub Issues.

## MVP
0. **Spikes** (done): OCR (#3, decision 0005), English dictionary with Russian translations
   (#6, decision 0006), lemma (#5, decision 0007, English only).
1. **Foundation**: models, catalog (folder tree), card editor add/edit, manual cards.
2. **Review**: scheduler, session builder, review screen, session summary, folder progress.
   After this the app is usable with manual cards.
3. **CSV**: import with preview, folder export. Comes before screenshots because it is how
   Serbian cards enter the app.
4. **Screenshots**: inbox, photo picker, OCR, word/phrase picker, dictionary build script and
   bundled file, hint tiles, duplicate check.
5. **Share extension**: extension, App Group, inbox banner.
6. **Release**: en + ru localisation, icon, one-screen onboarding, tip jar (StoreKit 2
   consumables), dictionary attribution and DRM-free dictionary file in the GitHub release (#11), App Store.

## After MVP
- Cards from a website, document or query (direction to be designed).
- Reverse-direction review UI; review of hard words; FSRS.
- iCloud sync (CloudKit) and iPad.
- Hiding obvious words by frequency and level; an "I know this word" list.
- Several back variants per card; tags; Serbian Cyrillic; Spanish UI.
- Serbian screenshots (OCR via a nearby language + dictionary diacritic restoration) and Serbian hints.
- Online dictionary for expressions behind a switch; notifications; widget.
- Highlighting the picked word on the screenshot (OCR coordinates); full backup with images;
  folder choice in the share extension.
