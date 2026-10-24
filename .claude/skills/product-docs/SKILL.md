---
name: product-docs
description: How product knowledge is stored in `docs/product/` (vision, glossary, per-feature behaviour, decisions) — where each fact goes, formats, size limits, when to update. Use when writing or updating product docs, when a change alters product behaviour or adds a domain term, or when a product decision is made.
---

# Product docs

Product knowledge lives in `docs/product/`, versioned and reviewed with the code. It is
read **on demand**, so it costs context only when a task needs it. Start at the index,
`docs/product/README.md`, and open only the docs the task touches. To find a term, grep
`docs/product` instead of reading files whole; for a broad question, use an Explore subagent
and keep only its summary.

## Where each fact goes

| Fact | Home | Loaded |
|---|---|---|
| What the app is, one line + pointer to the index | `CLAUDE.md` → "Product" | every session, keep it at 3 lines |
| Map of the docs, one line each | `docs/product/README.md` | at the start of a product task |
| Who it's for, the problem, principles, non-goals | `docs/product/vision.md` | specs, scope questions |
| Domain terms and their names in code/UI | `docs/product/glossary.md` | naming types, screens, strings |
| Current behaviour of one area: rules, numbers, states, edge cases | `docs/product/features/<area>.md` | work touching that area |
| A choice between real alternatives that is costly to reverse | `docs/product/decisions/NNNN-<slug>.md` | when the question comes up again |
| Backlog, the spec of work not yet done, discussion | GitHub Issues | `gh issue view <n>` |
| How it's implemented | code and tests | never duplicated in docs |
| How the user likes to work | auto memory | not product facts |

## Writing rules
- **Current state only.** Docs describe what the app does now. When behaviour changes, rewrite
  the text; don't append "UPDATE:". History is in git, and the reasons are in decisions.
- **What and why, never how.** No type names, signatures or file paths, except glossary
  "Code name" cells. Code changes often; product rules don't.
- **Rules as literals**, e.g. "a card answered *Again* is shown again after 1 min", not "soon".
  These are the values tests take their expected literals from (`pragmatic-testing`).
- **Small, single-topic files**: index ≤ 40 lines, vision ≤ 80, feature doc ≤ 150, decision ≤ 40.
  Split a feature doc that grows past its limit by sub-area.
- Lead every file with a one-sentence summary. The index line repeats that sentence.
- Use glossary terms everywhere (docs, issues, code, UI strings), each spelled one way.
- Reference work as `#<issue>`, not by copying the spec.

## When to update
- **The PR that changes behaviour updates its feature doc** (and the glossary for new terms).
  A feature doc is created by the first PR that ships that area, not up front.
- An issue spec is temporary. Once the work ships, its durable rules move into the feature doc;
  acceptance criteria and the plan stay in the issue.
- Decision records: write one when you chose between real alternatives and reversing would
  cost (storage, scheduling algorithm, sync). Never edit an accepted one; supersede it
  with a new one.
- `vision.md` and decision records change only with the user. A PR that edits them gets
  the **Spec / plan** review flag.
- Keep the index in sync: add, rename or remove its line in the same commit as the file.

## Templates

`features/<area>.md`:
```markdown
# <Area>
<One sentence: what this area lets the user do.>

## Rules
- <rule with literal values> (#<issue>)

## States and edge cases
- Empty: … · Error: … · <other state>: …

## Not supported
- <deliberately out of scope, so nobody "fixes" it>
```

`decisions/NNNN-<slug>.md`:
```markdown
# NNNN. <Decision>
Status: accepted (YYYY-MM-DD) | superseded by NNNN
## Context
<the forces, 2–4 lines>
## Decision
<what we do>
## Alternatives
- <option> — <why not>
## Consequences
<what gets easier or harder>
```

`glossary.md` row: `| Term | Meaning | Code name |`.
