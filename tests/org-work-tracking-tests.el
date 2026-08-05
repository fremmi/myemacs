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
(require 'org-clock)
(require 'cl-lib) ;; used below for `cl-count', `cl-letf', `cl-some'

;; Loading ~/.emacs (above) runs the real config, which sets
;; `org-clock-persist' to t and calls `org-clock-persistence-insinuate'.
;; That insinuation puts `org-clock-save' on `kill-emacs-hook', and
;; `ert-run-tests-batch-and-exit' ends the process by calling `kill-emacs' --
;; so, left alone, every test run overwrites the user's real
;; ~/.emacs.d/org-clock-save.el with this batch process's (irrelevant, and
;; possibly clock-less) state, discarding any real in-flight clock.
;;
;; Fix scope: remove only the hook, not `org-clock-persist' itself.  A test
;; below asserts the config sets `org-clock-persist' to t; leaving the
;; variable alone keeps that assertion honest regardless of test order,
;; while still eliminating the actual destructive write (which happens via
;; `org-clock-save' on `kill-emacs-hook', not via the variable being t).
(remove-hook 'kill-emacs-hook #'org-clock-save)

;; The same insinuation also puts `org-clock-load' on `org-mode-hook'.  If the
;; suite is run while a real clock is running, the persist file holds a resume
;; clock, and `org-clock-load' would then `y-or-n-p' inside a batch process
;; with no stdin and clock in against the real work.org -- writing a CLOCK line
;; into the user's log.  Reading is harmless; that write is not.
(remove-hook 'org-mode-hook #'org-clock-load)

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

(ert-deftest my/org-clock-idle-time-is-fifteen-minutes ()
  "Org offers to resolve idle time after 15 minutes, so a forgotten clock-out
does not silently credit a ticket with hours nobody worked."
  (should (equal org-clock-idle-time 15)))

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

(defun my/org-test--count-matches (regexp text)
  "Count non-overlapping matches of REGEXP in TEXT."
  (let ((count 0) (start 0))
    (while (string-match regexp text start)
      (setq count (1+ count))
      (setq start (match-end 0)))
    count))

(ert-deftest my/org-clock-report-preserves-user-content-and-later-headings ()
  "Report generation touches only the clocktable dblock.  Hand-written notes
and child headings under `Reports', and headings that come after it, must
survive verbatim across repeated calls with different ranges.  Also covers
a fixture where `Reports' is NOT the last heading in the file."
  (let* ((fixture (concat "#+TITLE: Work Log\n\n"
                           "* Tickets\n\n* Escalations\n\n"
                           "* Reports\n"
                           "Some hand-written note.\n"
                           "** Child Heading\n"
                           "Child content here.\n\n"
                           "* Unplanned\n"
                           "unplanned content\n"))
         (tmp (make-temp-file "work-" nil ".org" fixture))
         (my/org-work-file tmp))
    (unwind-protect
        (progn
          (my/org-clock-report "today")
          (with-current-buffer (find-file-noselect tmp)
            (let ((text (buffer-string)))
              (should (string-match-p "Some hand-written note\\." text))
              (should (string-match-p "^\\*\\* Child Heading$" text))
              (should (string-match-p "Child content here\\." text))
              (should (string-match-p "^\\* Unplanned$" text))
              (should (string-match-p "unplanned content" text))
              (should (= 1 (my/org-test--count-matches "^\\* Reports$" text)))
              (should (= 1 (my/org-test--count-matches "^#\\+BEGIN: clocktable" text)))
              (should (string-match-p ":block today" text))
              (should-not (buffer-modified-p))))
          ;; Re-run with a different range: same checks, block param updated.
          (my/org-clock-report "thisweek")
          (with-current-buffer (find-file-noselect tmp)
            (let ((text (buffer-string)))
              (should (string-match-p "Some hand-written note\\." text))
              (should (string-match-p "^\\*\\* Child Heading$" text))
              (should (string-match-p "Child content here\\." text))
              (should (string-match-p "^\\* Unplanned$" text))
              (should (string-match-p "unplanned content" text))
              (should (= 1 (my/org-test--count-matches "^\\* Reports$" text)))
              (should (= 1 (my/org-test--count-matches "^#\\+BEGIN: clocktable" text)))
              (should (string-match-p ":block thisweek" text))
              (should-not (string-match-p ":block today" text))
              (should-not (buffer-modified-p))))
          ;; The save actually reached disk, not just the live buffer.
          (with-temp-buffer
            (insert-file-contents tmp)
            (let ((text (buffer-string)))
              (should (string-match-p "^#\\+BEGIN: clocktable" text))
              (should (string-match-p ":block thisweek" text))
              (should (string-match-p "Some hand-written note\\." text))
              (should (string-match-p "unplanned content" text)))))
      (let ((buf (find-buffer-visiting tmp)))
        (when buf (with-current-buffer buf (set-buffer-modified-p nil) (kill-buffer buf))))
      (delete-file tmp))))

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
Deliberately does not assert what C-c c / C-c a *are* -- use-package binds
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

(ert-deftest my/org-clock-out-saves-the-work-file ()
  "Clocking out of an item in the work log saves it, so the log on disk
never lags behind what is in the buffer waiting for the next report run."
  (let* ((tmp (make-temp-file
               "work-" nil ".org"
               (concat "#+TITLE: Work Log\n\n"
                       "* Tickets\n** SD-1 first thing :ticket:\n")))
         (my/org-work-file tmp))
    (unwind-protect
        (with-current-buffer (find-file-noselect tmp)
          (goto-char (point-min))
          (re-search-forward "^\\*\\* SD-1")
          (org-clock-in)
          (should (org-clocking-p))
          (org-clock-out)
          (should-not (org-clocking-p))
          (should-not (buffer-modified-p)))
      (when (org-clocking-p) (org-clock-out nil t))
      (let ((buf (find-buffer-visiting tmp)))
        (when buf (with-current-buffer buf (set-buffer-modified-p nil) (kill-buffer buf))))
      (delete-file tmp))))
