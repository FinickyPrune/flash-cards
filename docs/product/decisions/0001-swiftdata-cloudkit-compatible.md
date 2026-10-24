# 0001. SwiftData with a CloudKit-compatible model, local container
Status: accepted (2026-10-24)

## Context
iCloud sync is wanted after the MVP. CloudKit-backed SwiftData forbids unique attributes,
non-optional relationships, properties without defaults and the deny delete rule. Retrofitting
these into a shipped schema means a data migration on users' devices.

## Decision
Use SwiftData and follow the CloudKit constraints from day one (see `docs/architecture.md` →
Invariants), with a local container (`cloudKitDatabase: .none`) in the MVP. Duplicates and other
uniqueness rules are checked in code.

## Alternatives
- Plain SwiftData with unique constraints — simpler now, migration when sync arrives.
- Core Data / SQLite — more control, more code, no benefit for the MVP.

## Consequences
Optional relationships and defaults everywhere; code must handle `nil` folders and cards.
Turning on sync later is a container setting plus testing, not a schema migration.
