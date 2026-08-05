# Org-based daily work tracking

**Date:** 2026-08-05
**Status:** Approved, pending implementation

## Problem

There is no way to answer two recurring questions at the end of a day or week:

1. What did I work on? (needed for standups and status updates, and for recalling
   an investigation weeks later)
2. How long did each thing take?

Work arrives in three shapes: Jira-style **tickets**, customer **escalations**,
and **unplanned** work for which no ticket exists.

The existing Emacs config loads Org (`emacs:16`, `emacs:26-33`) but configures
nothing beyond `org-store-link` and some windmove overrides, and explicitly sets
`org-agenda-files` to nil (`emacs:105`).

## Non-goals

Deliberately excluded to keep the system maintainable:

- TODO keywords, deadlines, scheduling, or any task-management workflow. The
  request is for a record of work done, not a list of work owed. Entries have no
  state to keep current, so the file cannot drift out of date.
- `org-roam` / `denote` / any zettelkasten layer.
- Jira API synchronisation. Ticket IDs are typed as plain text.
- Per-day journal files (`org-journal`). Chronology is derived from clock data
  instead, so a single item spanning several days stays a single item.

## Design

### Data layer

Files live in `~/sysdig/org/`, alongside the existing `~/sysdig/escalations/`
and `~/sysdig/tasks/` conventions. That directory is its own git repository, so
work content never enters the `myemacs` config repo.

A single file, `~/sysdig/org/work.org`, seeded with three buckets:

```org
#+TITLE: Work Log
#+STARTUP: overview

* Tickets
* Escalations
* Unplanned
```

Items are level-2 headings under a bucket. Each carries:

- a tag matching its bucket (`:ticket:`, `:escalation:`, `:unplanned:`), so
  reports can filter by tag independently of tree position;
- an inactive creation timestamp;
- a `LOGBOOK` drawer accumulating clock sessions.

Organising by item rather than by date is the central decision. `org-clock`
already stamps every session with its start and end time, so the chronological
view is derivable from the clock data, while a per-item tree additionally gives
per-ticket time rollups. A date-organised tree (datetree) would give the first
without the second.

### Capture

`C-c j c` opens the capture menu. Three templates:

| Key | Bucket | Prompts |
|-----|--------|---------|
| `t` | Tickets | ticket ID, then description |
| `e` | Escalations | escalation ID, then description |
| `u` | Unplanned | description only |

ID and description are prompted separately so the ID remains greppable in a
predictable position.

Each template targets its bucket via `(file+olp "~/sysdig/org/work.org"
"<Bucket>")` and sets `:clock-in t :clock-keep t`, so capturing an item and
starting to work on it is one gesture.

### Clocking

- `org-clock-persist` enabled (with `org-clock-persistence-insinuate`) so an
  in-progress clock survives an Emacs restart rather than being lost silently.
- `org-clock-into-drawer` set to `"LOGBOOK"`.
- `org-clock-out-remove-zero-time-clocks` enabled so a mis-start leaves no noise.

Bindings: `C-c j i` clocks into an existing item, chosen by completion over the
file's headings — this is how a ticket is resumed on a later day. `C-c j o`
clocks out. `C-c j g` jumps to the running clock.

### Reporting

Both views read the same clock data.

- `C-c j r` runs `my/org-clock-report`, which prompts for a range (today / this
  week / last week) and inserts or refreshes a clocktable at point in
  `work.org`, blocked so the ticket / escalation / unplanned split is visible.
- `C-c j a` opens `org-agenda` with log mode enabled, listing clocked entries in
  chronological order for a chosen day — the standup view.

- `C-c j f` opens `work.org` directly.

### Config integration

One new `;;; Org: work tracking` section appended to the end of `emacs`,
following the file's existing convention of adding recent work at the end.

The `C-c j` prefix is implemented as a `my-org-map` prefix keymap, matching the
`my-search-map` (`emacs:406`) and `my-find-map` (`emacs:831`) pattern already in
the config. `C-c j` was verified free.

`C-c c` and `C-c a`, Org's canonical capture and agenda bindings, are already
bound to `claude-code` (`emacs:883-886`) and are left alone. `C-c l`
(`org-store-link`) and the `org-mode-hook` windmove overrides (`emacs:28-33`)
are also untouched.

The `'(org-agenda-files nil)` entry inside `custom-set-variables` at `emacs:105`
is removed, rather than being overridden by a later `setq`, so the agenda file
list has a single source of truth.

## Verification

1. Static: `emacs --batch -l ~/.emacs` loads with no errors, and
   `org-capture-templates`, `org-agenda-files`, and the `C-c j` keymap are bound
   as intended.
2. Live: capture one item of each of the three kinds, clock in, clock out,
   confirm a `LOGBOOK` entry appears, then run `C-c j r` and confirm the
   clocktable reports the elapsed time under the right bucket.
