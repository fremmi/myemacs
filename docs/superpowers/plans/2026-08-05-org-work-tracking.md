# Org Work Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Track daily work — tickets, escalations, and unplanned work — as a per-item Org tree in `~/sysdig/org/work.org`, with chronology and time totals derived from `org-clock` data.

**Architecture:** All Emacs configuration goes into a single new `;;; Org: work tracking` section appended to the end of `~/myemacs/emacs` (a single-file config symlinked as `~/.emacs`). The Org data lives outside the config repo in `~/sysdig/org/`, its own git repo. Items are level-2 headings under one of three level-1 buckets; `org-clock` writes sessions into each item's `LOGBOOK` drawer, and both the chronological view and the time totals are read back out of that clock data.

**Tech Stack:** GNU Emacs 30.2, built-in Org 9.7.11 (no new packages), ERT for tests, git.

Spec: `docs/superpowers/specs/2026-08-05-org-work-tracking-design.md`

## Global Constraints

- No new packages. Org 9.7.11 ships with Emacs 30.2; everything here uses built-in Org, `org-clock`, `org-capture`, `org-agenda`, and ERT.
- Org data directory: `~/sysdig/org/`. Work file: `~/sysdig/org/work.org`. These paths are exact.
- The Org data repo is a **separate** git repo from `myemacs`. Never `git add` anything under `~/sysdig/org/` from within the `myemacs` repo, and never commit work content into `myemacs`.
- Do not rebind `C-c c` or `C-c a` — both belong to `claude-code` (`emacs:883-886`). The Org prefix is `C-c j`.
- Do not touch `C-c l` (`org-store-link`, `emacs:16`) or the `org-mode-hook` windmove overrides (`emacs:28-33`).
- No TODO keywords, deadlines, or scheduling anywhere. This system records work done, not work owed.
- Match the config's existing prefix-map style (`emacs:830-839`): `define-prefix-command`, then `global-set-key`, then `define-key ... #'function`.
- All new global symbols are prefixed `my/` (functions and variables) or `my-` (keymaps), matching `my-find-map` / `my-search-map`.
- Every task's verification runs from the `myemacs` repo root: `/home/francesco.emmi/myemacs`.

## Test Strategy

There is no test suite in this repo today; this plan creates one file,
`tests/org-work-tracking-tests.el`, containing ERT tests that assert on the
configuration the tasks produce. Tests run against the *real* config by loading
it, which is the only honest integration test for an init file:

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit
```

Two things to know about that command:

- It takes roughly 10-30 seconds because it loads the entire config (LSP,
  treemacs, tree-sitter, and the rest).
- It prints `Error (use-package): Cannot load xclip` and some `tsc-dyn-get` /
  `tree-sitter-langs` chatter on the way up. **This is pre-existing noise**, not
  a failure — `xclip` needs a running X display, which batch mode has none of.
  Judge success only by the ERT summary line (`Ran N tests ... 0 unexpected`)
  and the exit code.

Tests that need a scratch Org buffer must not write to the real
`~/sysdig/org/work.org`.

## File Structure

| File | Responsibility |
|---|---|
| `~/sysdig/org/work.org` | The data. Three bucket headings; items and their `LOGBOOK` drawers accumulate underneath. Not in this repo. |
| `~/sysdig/org/.git` | Version control for the data, separate from `myemacs`. |
| `emacs` (modify: delete line 105; append new section at EOF) | All Org configuration: paths, clock settings, capture templates, report/agenda commands, the `C-c j` keymap. |
| `tests/org-work-tracking-tests.el` (create) | ERT tests asserting the config loaded correctly and the report/clock-in helpers behave. |

---

### Task 1: Data layer — the work file and its git repo

**Files:**
- Create: `~/sysdig/org/work.org`
- Create: `~/sysdig/org/.gitignore`
- Create: `~/sysdig/org/` git repo

**Interfaces:**
- Consumes: nothing.
- Produces: the file `~/sysdig/org/work.org`, containing exactly three level-1 headings whose titles are `Tickets`, `Escalations`, and `Unplanned`. Every later task depends on those three titles being spelled exactly that way — the capture templates target them by name.

- [ ] **Step 1: Create the directory and the work file**

```bash
mkdir -p ~/sysdig/org
cat > ~/sysdig/org/work.org <<'EOF'
#+TITLE: Work Log
#+STARTUP: overview

* Tickets

* Escalations

* Unplanned
EOF
```

- [ ] **Step 2: Verify the file parses as Org with the three expected buckets**

```bash
emacs --batch --eval '(progn
  (require (quote org))
  (find-file "~/sysdig/org/work.org")
  (let (tops)
    (org-map-entries (lambda () (when (= (org-current-level) 1)
                                  (push (org-get-heading t t t t) tops))))
    (setq tops (nreverse tops))
    (if (equal tops (list "Tickets" "Escalations" "Unplanned"))
        (message "OK buckets=%S" tops)
      (error "BAD buckets=%S" tops))))'
```

Expected: prints `OK buckets=("Tickets" "Escalations" "Unplanned")` and exits 0.

- [ ] **Step 3: Ignore Org's auto-generated clutter**

```bash
cat > ~/sysdig/org/.gitignore <<'EOF'
# Org / Emacs transients
.#*
*~
\#*\#
.org-id-locations
*_archive
EOF
```

- [ ] **Step 4: Initialise the data repo and commit**

Note the `git -C` — this keeps the operation inside `~/sysdig/org` and cannot
touch the `myemacs` repo.

```bash
git -C ~/sysdig/org init -q
git -C ~/sysdig/org add work.org .gitignore
git -C ~/sysdig/org commit -q -m "Add work log skeleton"
git -C ~/sysdig/org log --oneline
```

Expected: one commit listed.

- [ ] **Step 5: Confirm nothing leaked into the config repo**

Run: `git status --short`
Expected: no entries mentioning `sysdig` or `org/`.

---

### Task 2: Core Org paths and agenda wiring

**Files:**
- Modify: `emacs:105` (delete the `'(org-agenda-files nil)` line inside `custom-set-variables`)
- Modify: `emacs` (append the start of the new section at end of file)
- Create: `tests/org-work-tracking-tests.el`

**Interfaces:**
- Consumes: `~/sysdig/org/work.org` from Task 1.
- Produces:
  - `my/org-work-file` — a `defvar` holding the absolute, expanded path to `work.org` as a string. Tasks 3, 4, and 5 all reference this variable.
  - `org-directory` set to the expanded `~/sysdig/org`.
  - `org-agenda-files` set to `(list my/org-work-file)`.

- [ ] **Step 1: Write the failing test**

Create `tests/org-work-tracking-tests.el`:

```elisp
;;; org-work-tracking-tests.el --- Tests for the Org work-tracking setup  -*- lexical-binding: t; -*-

;; Run with:
;;   emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
;;         -f ert-run-tests-batch-and-exit
;;
;; Loading ~/.emacs in batch prints "Cannot load xclip" and tree-sitter
;; chatter; that is pre-existing noise, not failure.  Judge by the ERT
;; summary and the exit code.

(require 'ert)
(require 'org)

(ert-deftest my/org-work-file-points-at-the-work-log ()
  "`my/org-work-file' is an absolute path to an existing work.org."
  (should (boundp 'my/org-work-file))
  (should (stringp my/org-work-file))
  (should (file-name-absolute-p my/org-work-file))
  (should (string-suffix-p "sysdig/org/work.org" my/org-work-file))
  (should (file-exists-p my/org-work-file)))

(ert-deftest my/org-directory-is-the-sysdig-org-dir ()
  "`org-directory' points at ~/sysdig/org."
  (should (equal (file-truename org-directory)
                 (file-truename (expand-file-name "~/sysdig/org")))))

(ert-deftest my/org-agenda-files-is-exactly-the-work-file ()
  "The agenda reads the work file and nothing else."
  (should (equal org-agenda-files (list my/org-work-file))))
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -20
```

Expected: FAIL. `my/org-work-file` is unbound, and `org-agenda-files` is nil
because of `emacs:105`.

- [ ] **Step 3: Delete the stale `org-agenda-files` customisation**

In `emacs`, inside the `custom-set-variables` form, delete this entire line
(currently line 105):

```elisp
 '(org-agenda-files nil)
```

Leave every other entry in that form untouched. Removing the entry — rather than
overriding it later with `setq` — keeps one source of truth for the list.

- [ ] **Step 4: Append the section header and path configuration**

Append to the very end of `emacs`:

```elisp

;; --- Org: daily work tracking on C-c j ------------------------------------
;; Tracks three kinds of work as level-2 items under three buckets in one
;; file: tickets, escalations, and unplanned work.  There is deliberately no
;; TODO/deadline machinery: this records what was done, not what is owed.
;; Chronology and time totals are both derived from `org-clock' data, so the
;; tree is organised by item rather than by date.

(setq org-directory (expand-file-name "~/sysdig/org"))

(defvar my/org-work-file (expand-file-name "work.org" org-directory)
  "The single file holding the work log.
Contains three level-1 buckets: Tickets, Escalations, Unplanned.")

(setq org-agenda-files (list my/org-work-file))
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -20
```

Expected: `Ran 3 tests, 3 results as expected` and exit code 0.

- [ ] **Step 6: Commit**

```bash
git add emacs tests/org-work-tracking-tests.el
git commit -m "org: point agenda at ~/sysdig/org/work.org

Drop the stale '(org-agenda-files nil) customisation so the work file
is the single source of truth for the agenda."
```

---

### Task 3: Clocking behaviour and capture templates

**Files:**
- Modify: `emacs` (append to the Org section from Task 2)
- Modify: `tests/org-work-tracking-tests.el`

**Interfaces:**
- Consumes: `my/org-work-file` from Task 2.
- Produces: `org-capture-templates` containing exactly three templates, with keys `"t"`, `"e"`, and `"u"`, each targeting its bucket in `my/org-work-file` and each carrying `:clock-in t :clock-keep t`. Task 5 binds `org-capture` to `C-c j c` to reach them.

- [ ] **Step 1: Write the failing tests**

Append to `tests/org-work-tracking-tests.el`:

```elisp
(defun my/org-test--template (key)
  "Return the `org-capture-templates' entry whose key is KEY."
  (assoc key org-capture-templates))

(ert-deftest my/org-capture-has-three-templates ()
  "Exactly three capture templates exist, keyed t/e/u."
  (should (equal (sort (mapcar #'car org-capture-templates) #'string<)
                 '("e" "t" "u"))))

(ert-deftest my/org-capture-templates-target-their-buckets ()
  "Each template files into its own bucket in the work file."
  (dolist (pair '(("t" . "Tickets")
                  ("e" . "Escalations")
                  ("u" . "Unplanned")))
    (let ((target (nth 3 (my/org-test--template (car pair)))))
      (should (equal (car target) 'file+olp))
      (should (equal (nth 1 target) my/org-work-file))
      (should (equal (nth 2 target) (cdr pair))))))

(ert-deftest my/org-capture-templates-clock-in-and-stay-clocked ()
  "Capturing an item starts its clock and leaves it running."
  (dolist (key '("t" "e" "u"))
    (let ((plist (nthcdr 5 (my/org-test--template key))))
      (should (eq (plist-get plist :clock-in) t))
      (should (eq (plist-get plist :clock-keep) t)))))

(ert-deftest my/org-capture-templates-tag-by-bucket ()
  "Each template's body tags the new item with its kind."
  (dolist (pair '(("t" . ":ticket:")
                  ("e" . ":escalation:")
                  ("u" . ":unplanned:")))
    (should (string-match-p (regexp-quote (cdr pair))
                            (nth 4 (my/org-test--template (car pair)))))))

(ert-deftest my/org-clock-settings-are-durable ()
  "Clock sessions land in LOGBOOK, survive restarts, and skip zero-time noise."
  (should (equal org-clock-into-drawer "LOGBOOK"))
  (should org-clock-persist)
  (should org-clock-out-remove-zero-time-clocks))
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -25
```

Expected: the 3 tests from Task 2 pass; the 5 new ones FAIL (`org-capture-templates` is still at its default).

- [ ] **Step 3: Append the clock and capture configuration**

Append to the end of `emacs`:

```elisp
;; Clocking.  `org-clock-persist' keeps a running clock across restarts, so an
;; Emacs restart mid-task does not silently discard the session.
(require 'org-clock)
(setq org-clock-into-drawer "LOGBOOK"
      org-clock-out-remove-zero-time-clocks t
      org-clock-persist t
      org-clock-history-length 25)
(org-clock-persistence-insinuate)

;; Capture.  Each template files a level-2 item under its bucket and starts
;; clocking immediately, so "I am starting this" is one gesture.  ID and
;; description are separate prompts to keep the ID greppable at a fixed
;; position in the headline.
(setq org-capture-templates
      `(("t" "Ticket" entry
         (file+olp ,my/org-work-file "Tickets")
         "* %^{Ticket ID} %^{Description} :ticket:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
         :clock-in t :clock-keep t)
        ("e" "Escalation" entry
         (file+olp ,my/org-work-file "Escalations")
         "* %^{Escalation ID} %^{Description} :escalation:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
         :clock-in t :clock-keep t)
        ("u" "Unplanned" entry
         (file+olp ,my/org-work-file "Unplanned")
         "* %^{Description} :unplanned:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?"
         :clock-in t :clock-keep t)))
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -20
```

Expected: `Ran 8 tests, 8 results as expected` and exit code 0.

- [ ] **Step 5: Commit**

```bash
git add emacs tests/org-work-tracking-tests.el
git commit -m "org: capture templates for tickets, escalations, unplanned work

Each template files into its bucket and clocks in immediately; clock
sessions persist across restarts and land in LOGBOOK drawers."
```

---

### Task 4: Reporting — clocktable and the agenda log view

**Files:**
- Modify: `emacs` (append to the Org section)
- Modify: `tests/org-work-tracking-tests.el`

**Interfaces:**
- Consumes: `my/org-work-file` (Task 2), the clock settings (Task 3).
- Produces three interactive commands, bound by Task 5:
  - `(my/org-clock-report RANGE)` — `RANGE` is a string, one of `"today"`, `"thisweek"`, `"lastweek"`. Rebuilds a single clocktable under a `* Reports` heading in the work file, creating that heading if absent. Returns nil; its effect is the buffer contents.
  - `(my/org-agenda-log)` — no arguments. Opens the day agenda with clock log mode on.
  - `(my/org-open-work-file)` — no arguments. Visits `my/org-work-file`.

- [ ] **Step 1: Write the failing tests**

Append to `tests/org-work-tracking-tests.el`:

```elisp
(ert-deftest my/org-report-commands-are-interactive ()
  "The reporting entry points exist and are commands."
  (dolist (fn '(my/org-clock-report my/org-agenda-log my/org-open-work-file))
    (should (fboundp fn))
    (should (commandp fn))))

(ert-deftest my/org-clock-report-builds-one-table-under-reports ()
  "Reporting creates a `* Reports' heading holding exactly one clocktable.
Runs against a temporary copy so the real work log is never touched."
  (let* ((tmp (make-temp-file "work-" nil ".org"
                              "#+TITLE: Work Log\n\n* Tickets\n\n* Escalations\n\n* Unplanned\n"))
         (my/org-work-file tmp))
    (unwind-protect
        (progn
          (my/org-clock-report "today")
          (with-current-buffer (find-file-noselect tmp)
            (let ((text (buffer-string)))
              (should (string-match-p "^\\* Reports$" text))
              ;; Exactly one table, and it is a clocktable for today.
              (should (= 1 (cl-count "#+BEGIN: clocktable"
                                     (split-string text "\n")
                                     :test (lambda (needle line)
                                             (string-prefix-p needle line)))))
              (should (string-match-p ":block today" text))))
          ;; Re-running refreshes in place rather than appending a second table.
          (my/org-clock-report "thisweek")
          (with-current-buffer (find-file-noselect tmp)
            (let ((text (buffer-string)))
              (should (= 1 (cl-count "#+BEGIN: clocktable"
                                     (split-string text "\n")
                                     :test (lambda (needle line)
                                             (string-prefix-p needle line)))))
              (should (string-match-p ":block thisweek" text))
              (should-not (string-match-p ":block today" text)))))
      (let ((buf (find-buffer-visiting tmp)))
        (when buf (with-current-buffer buf (set-buffer-modified-p nil) (kill-buffer buf))))
      (delete-file tmp))))
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -25
```

Expected: the 8 earlier tests pass; the 2 new ones FAIL with void-function
`my/org-clock-report`.

- [ ] **Step 3: Append the reporting commands**

Append to the end of `emacs`:

```elisp
;; Reporting.  Both views read the same clock data: the clocktable answers
;; "how long", the agenda log answers "in what order".
(require 'org-clock)
(require 'cl-lib)

(defun my/org-open-work-file ()
  "Visit the work log."
  (interactive)
  (find-file my/org-work-file))

(defun my/org-clock-report (range)
  "Rebuild the clocktable for RANGE under the `Reports' heading of the work log.
RANGE is an Org clocktable :block value such as \"today\", \"thisweek\" or
\"lastweek\".  Any previous table is replaced, so reports refresh in place
instead of accumulating."
  (interactive
   (list (completing-read "Range: " '("today" "thisweek" "lastweek") nil t "today")))
  (with-current-buffer (find-file-noselect my/org-work-file)
    (org-with-wide-buffer
     (goto-char (point-min))
     (if (re-search-forward "^\\* Reports[ \t]*$" nil t)
         (org-back-to-heading t)
       (goto-char (point-max))
       (unless (bolp) (insert "\n"))
       (insert "\n* Reports\n")
       (org-back-to-heading t))
     ;; Clear whatever the previous run left behind.
     (let ((end (save-excursion (org-end-of-subtree t t))))
       (forward-line 1)
       (delete-region (point) end))
     (insert (format (concat "#+BEGIN: clocktable :maxlevel 3 :scope file"
                            " :block %s :link t :fileskip0 t\n#+END:\n")
                     range))
     (re-search-backward "^#\\+BEGIN: clocktable" nil t)
     (org-update-dblock)))
  (my/org-open-work-file)
  (goto-char (point-min))
  (re-search-forward "^\\* Reports[ \t]*$" nil t)
  nil)

(defun my/org-agenda-log ()
  "Show one day's agenda with clocked entries listed chronologically.
This is the standup view: what happened, in what order."
  (interactive)
  (let ((org-agenda-start-with-log-mode '(clock))
        (org-agenda-span 'day))
    (org-agenda nil "a")))
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -20
```

Expected: `Ran 10 tests, 10 results as expected` and exit code 0.

- [ ] **Step 5: Confirm the real work log was not modified by the test run**

Run: `git -C ~/sysdig/org status --short`
Expected: empty output. The report test uses a temp file; if `work.org` shows as
modified, the test leaked and `my/org-work-file` was not properly let-bound.

- [ ] **Step 6: Commit**

```bash
git add emacs tests/org-work-tracking-tests.el
git commit -m "org: clocktable report and agenda log view

my/org-clock-report rebuilds a single table under a Reports heading so
reports refresh in place; my/org-agenda-log gives the chronological view."
```

---

### Task 5: The `C-c j` keymap and end-to-end verification

**Files:**
- Modify: `emacs` (append to the Org section)
- Modify: `tests/org-work-tracking-tests.el`

**Interfaces:**
- Consumes: `my/org-clock-report`, `my/org-agenda-log`, `my/org-open-work-file` (Task 4); `org-capture-templates` (Task 3).
- Produces: `my-org-map`, a prefix keymap on `C-c j`. This is the final task; nothing consumes it.

- [ ] **Step 1: Write the failing tests**

Append to `tests/org-work-tracking-tests.el`:

```elisp
(ert-deftest my/org-prefix-map-is-on-c-c-j ()
  "C-c j is a prefix map with the expected commands behind it."
  (should (keymapp (key-binding (kbd "C-c j"))))
  (dolist (pair '(("C-c j c" . org-capture)
                  ("C-c j i" . my/org-clock-in-item)
                  ("C-c j o" . org-clock-out)
                  ("C-c j g" . org-clock-goto)
                  ("C-c j r" . my/org-clock-report)
                  ("C-c j a" . my/org-agenda-log)
                  ("C-c j f" . my/org-open-work-file)))
    (should (eq (key-binding (kbd (car pair))) (cdr pair)))))

(ert-deftest my/org-existing-bindings-are-untouched ()
  "org-store-link keeps C-c l, and Org has not taken claude-code's keys.
Deliberately does not assert what C-c c / C-c a *are* — use-package binds
those lazily via :bind-keymap, so their value in batch mode is an
implementation detail.  What matters is that Org did not claim them."
  (should (eq (key-binding (kbd "C-c l")) 'org-store-link))
  (should-not (eq (key-binding (kbd "C-c c")) 'org-capture))
  (should-not (eq (key-binding (kbd "C-c a")) 'org-agenda)))

(ert-deftest my/org-clock-in-item-offers-the-files-items ()
  "`my/org-clock-in-item' completes over level-2 items and clocks into the pick.
Uses a temporary work file and a stubbed `completing-read'."
  (let* ((tmp (make-temp-file
               "work-" nil ".org"
               (concat "#+TITLE: Work Log\n\n* Tickets\n** SD-1 first thing :ticket:\n"
                       "* Escalations\n** ESC-9 second thing :escalation:\n"
                       "* Unplanned\n")))
         (my/org-work-file tmp)
         offered)
    (unwind-protect
        (progn
          (cl-letf (((symbol-function 'completing-read)
                     (lambda (_prompt collection &rest _)
                       (setq offered collection)
                       (car collection))))
            (my/org-clock-in-item))
          (should (= 2 (length offered)))
          (should (cl-some (lambda (s) (string-match-p "SD-1 first thing" s)) offered))
          (should (cl-some (lambda (s) (string-match-p "ESC-9 second thing" s)) offered))
          (should (org-clocking-p)))
      (when (org-clocking-p) (org-clock-out nil t))
      (let ((buf (find-buffer-visiting tmp)))
        (when buf (with-current-buffer buf (set-buffer-modified-p nil) (kill-buffer buf))))
      (delete-file tmp))))
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -25
```

Expected: the 10 earlier tests pass; the 3 new ones FAIL — `C-c j` is unbound
and `my/org-clock-in-item` is void.

- [ ] **Step 3: Append the resume-clock helper and the keymap**

Append to the end of `emacs`:

```elisp
(defun my/org-clock-in-item ()
  "Pick an existing item from the work log by completion and clock into it.
This is how a ticket or escalation is resumed on a later day."
  (interactive)
  (let ((buf (find-file-noselect my/org-work-file))
        (items nil))
    (with-current-buffer buf
      (org-with-wide-buffer
       (org-map-entries
        (lambda ()
          (when (= (org-current-level) 2)
            (push (cons (org-format-outline-path
                         (org-get-outline-path t) 120 nil " / ")
                        (point))
                  items))))))
    (setq items (nreverse items))
    (unless items
      (user-error "No items yet in %s -- capture one with C-c j c" my/org-work-file))
    (let* ((choice (completing-read "Clock into: " (mapcar #'car items) nil t))
           (pos (cdr (assoc choice items))))
      (with-current-buffer buf
        (org-with-point-at pos (org-clock-in))))))

;; --- Work-tracking hub on C-c j ---
;; C-c c and C-c a, Org's usual capture/agenda keys, belong to claude-code.
(define-prefix-command 'my-org-map)
(global-set-key (kbd "C-c j") 'my-org-map)
(define-key my-org-map (kbd "c") #'org-capture)            ;; c/t/e/u to capture
(define-key my-org-map (kbd "i") #'my/org-clock-in-item)    ;; resume an item
(define-key my-org-map (kbd "o") #'org-clock-out)
(define-key my-org-map (kbd "g") #'org-clock-goto)          ;; jump to running clock
(define-key my-org-map (kbd "r") #'my/org-clock-report)     ;; how long
(define-key my-org-map (kbd "a") #'my/org-agenda-log)       ;; what happened, in order
(define-key my-org-map (kbd "f") #'my/org-open-work-file)
```

- [ ] **Step 4: Run the full suite to verify it passes**

```bash
emacs --batch -l ~/.emacs -l tests/org-work-tracking-tests.el \
      -f ert-run-tests-batch-and-exit 2>&1 | tail -20
```

Expected: `Ran 13 tests, 13 results as expected` and exit code 0.

- [ ] **Step 5: End-to-end check against the real work file**

This exercises the whole loop the way a person would — capture, clock, report —
and then leaves the result in place for the user to look at.

```bash
emacs --batch -l ~/.emacs --eval '(progn
  (require (quote org-capture))
  ;; Capture an unplanned item without interactive prompts.
  (let ((org-capture-templates
         (list (list "x" "E2E" (quote entry)
                     (list (quote file+olp) my/org-work-file "Unplanned")
                     "* e2e smoke check :unplanned:\n:PROPERTIES:\n:CREATED: %U\n:END:\n"
                     :clock-in t :clock-keep t :immediate-finish t))))
    (org-capture nil "x"))
  (unless (org-clocking-p) (error "capture did not clock in"))
  (sleep-for 61)
  (org-clock-out)
  (my/org-clock-report "today")
  (with-current-buffer (find-file-noselect my/org-work-file)
    (let ((text (buffer-string)))
      (unless (string-match-p "e2e smoke check" text) (error "item not filed"))
      (unless (string-match-p "CLOCK:" text) (error "no LOGBOOK clock line"))
      (unless (string-match-p "clocktable" text) (error "no report")))
    (save-buffer))
  (message "E2E-OK"))' 2>&1 | tail -5
```

Expected: prints `E2E-OK`. The `sleep-for 61` is needed because
`org-clock-out-remove-zero-time-clocks` discards sessions under a minute.

- [ ] **Step 6: Inspect the result and clean up the smoke-test item**

Run: `emacs ~/sysdig/org/work.org` (or `git -C ~/sysdig/org diff`) and confirm
the item, its `LOGBOOK` drawer with a `CLOCK:` line, and the `* Reports`
clocktable all look right. Then delete the `e2e smoke check` heading and its
drawer, leaving the `* Reports` section in place.

- [ ] **Step 7: Commit both repos**

```bash
git add emacs tests/org-work-tracking-tests.el
git commit -m "org: bind the work-tracking hub to C-c j

Adds my/org-clock-in-item for resuming an item on a later day, and a
my-org-map prefix map, leaving C-c c and C-c a to claude-code."

git -C ~/sysdig/org add -A
git -C ~/sysdig/org commit -q -m "Add Reports section"
```

- [ ] **Step 8: Confirm the config loads in a real (non-batch) session**

Batch mode never loads `xclip` or draws a frame, so finish with an interactive
smoke test:

```bash
emacs --eval '(message "interactive load OK")'
```

Expected: Emacs opens with no error in `*Messages*` and no `*Warnings*` buffer
mentioning the Org section. Then press `C-c j` and confirm which-key lists the
seven bindings.

---

## Post-implementation

Once all five tasks are done, the daily loop is:

| Action | Keys |
|---|---|
| Start something new | `C-c j c` then `t` / `e` / `u` |
| Resume something from a previous day | `C-c j i` |
| Stop the clock | `C-c j o` |
| Where was I? | `C-c j g` |
| How long did things take? | `C-c j r` |
| What did I do, in order? | `C-c j a` |
| Open the log | `C-c j f` |

Committing `~/sysdig/org` is manual and deliberately left that way — no
auto-commit hook, so nothing is written to git history without intent.
