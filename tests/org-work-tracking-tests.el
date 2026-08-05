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
