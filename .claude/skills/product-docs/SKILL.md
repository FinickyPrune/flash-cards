---
name: product-docs
description: How product knowledge is stored in `docs/product/` (vision, glossary, roadmap, per-feature behaviour, decisions) and `docs/architecture.md` — where each fact goes, formats, size limits, when to update. Use when writing or updating product docs, when a change alters product behaviour or adds a domain term, or when a product decision is made.
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
| Milestone order, post-MVP list (one line each) | `docs/product/roadmap.md` | picking the next work |
| Domain terms and their names in code/UI | `docs/product/glossary.md` | naming types, screens, strings |
| Agreed behaviour of one area: rules, numbers, states, edge cases | `docs/product/features/<area>.md` | work touching that area |
| A choice between real alternatives that is costly to reverse | `docs/product/decisions/NNNN-<slug>.md` | when the question comes up again |
| Targets, layers, invariants, data model | `docs/architecture.md` | structural work |
| Actionable work: acceptance criteria, plan, discussion | GitHub Issues | `gh issue view <n>` |
| How it's implemented | code and tests | never duplicated in docs |
| How the user likes to work | auto memory | not product facts |

## Writing rules
- **The agreed behaviour, kept current.** Each feature doc starts with
  `Status: planned (milestone N) | partial | shipped`; in a `partial` doc, mark unshipped rules
  `(planned)`. When behaviour changes, rewrite the text; don't append "UPDATE:". History is in
  git, and the reasons are in decisions.
- **Mark what isn't settled**: `(assumption)` = a sensible default, may change, tell the user
  first; `(spike)` = verify with an experiment before building on it; `(to be defined)` = ask
  the user before implementing. Plain text = decided.
- **What and why, never how.** No type names, signatures or file paths in `docs/product`,
  except glossary "Code name" cells; those belong in `docs/architecture.md`. Code changes
  often; product rules don't.
- **Rules as literals**, e.g. "a card answered *Again* is shown again after 1 min", not "soon".
  These are the values tests take their expected literals from (`pragmatic-testing`).
- **Small, single-topic files**: index ≤ 40 lines, vision ≤ 80, feature doc ≤ 150, decision ≤ 40.
  Split a feature doc that grows past its limit by sub-area.
- Lead every file with a one-sentence summary. The index line repeats that sentence.
- Use glossary terms everywhere (docs, issues, code, UI strings), each spelled one way.
- Reference work as `#<issue>`, not by copying the spec.

## When to update
- **The PR that changes behaviour updates its feature doc** (and the glossary for new terms):
  flip `Status`, drop `(planned)`, resolve the markers it settled.
- Issues point to doc sections instead of copying rules ("implements `review.md` → Rules 1–4")
  and add acceptance criteria. Rules agreed during a spec interview go into the feature doc;
  only the plan and criteria stay in the issue.
- Decision records: write one when you chose between real alternatives and reversing would
  cost (storage, scheduling algorithm, sync). Never edit an accepted one; supersede it
  with a new one.
- `vision.md` and decision records change only with the user. A PR that edits them gets
  the **Spec / plan** review flag.
- Keep the index in sync: add, rename or remove its line in the same commit as the file.
- Once code exists for something `docs/architecture.md` describes (e.g. the data model), the
  code is the source of truth: trim the doc to invariants.

## Templates

`features/<area>.md`:
```markdown
# <Area>
<One sentence: what this area lets the user do.>
Status: planned (milestone N) | partial | shipped

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
