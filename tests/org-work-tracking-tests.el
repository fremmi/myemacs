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
