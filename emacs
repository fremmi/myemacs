;;; Code:
(setq password-cache-expiry nil)

(require 'ido) (ido-mode t)

(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c l") 'org-store-link)

(define-key input-decode-map "\e[H" [home])
(define-key input-decode-map "\e[F" [end])
(define-key input-decode-map "\e[1;3A" [M-up])
(define-key input-decode-map "\e[1;3B" [M-down])
(define-key input-decode-map "\e[1;3C" [M-right])
(define-key input-decode-map "\e[1;3D" [M-left])


(setq org-support-shift-select t)

(add-hook 'org-mode-hook
          (lambda ()
            (org-defkey org-mode-map [?\C-c (up)] 'windmove-up)
            (org-defkey org-mode-map [?\C-c (down)] 'windmove-down)
            (org-defkey org-mode-map [?\C-c (right)] 'windmove-right)
            (org-defkey org-mode-map [?\C-c (left)] 'windmove-left)))



(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; Use local archives to downgrade packages
;; (add-to-list 'package-archives '("local-dir" . "/home/fremmi/tmp/melpa/packages") t)

(package-initialize)


(global-set-key (kbd "M-g M-c") 'go-to-column)

(setq js-indent-level 4)

(require 'parse-time)


(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)


(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))


(defun epoch-to-string (start end)
  "Fai qualcosa di bello"
  (interactive "r")
  (setq epoch (buffer-substring-no-properties start end))
  (setq str (format-time-string "%Y-%m-%d %T UTC" (seconds-to-time
                                                   (string-to-number epoch)
                                                   ))
        )
  (delete-region start end)
  (insert str)
  )


(defun go-to-column (column)
  (interactive "nColumn: ")
  (move-to-column column t))

(global-flycheck-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 8)
 '(c-default-style
   '((c-mode . "ellemtel")
     (c++-mode . "ellemtel")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu")))
 '(c-offsets-alist '((innamespace . +)))
 '(cmake-tab-width 4)
 '(custom-safe-themes
   '("0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5" default))
 '(indent-tabs-mode t)
 '(large-file-warning-threshold 300000000)
 '(lsp-clients-clangd-args '("--header-insertion-decorators=0"))
 '(org-agenda-files '("~/docs/agenda.org"))
 '(package-check-signature 'allow-unsigned)
 '(package-selected-packages
   '(editorconfig melpa-upstream-visit yaml-mode go-dlv restclient simpleclip magit lsp-ui lsp-java protobuf-mode gh gh-md gh-notify neotree dash go-autocomplete log4j-mode logview ag egg-timer jq-mode jq-format lsp-mode clang-format company-quickhelp chronos cpp-capf cpputils-cmake json-navigator company-ctags forge magithub docker docker-cli docker-tramp dockerfile-mode magit-gh-pulls gnu-elpa-keyring-update json-mode helm-fuzzy-find md-readme neato-graph-bar w3 docker-api docker-compose-mode elpy go-guru kubernetes-tramp es-mode kubernetes smart-compile sr-speedbar meghanada irony company auto-complete-clang-async ggtags flycheck company-irony cmake-ide auto-complete-clang auto-complete-c-headers))
 '(reb-re-syntax 'string)
 '(safe-local-variable-values
   '((cmake-ide-build-dir . "/home/fremmi/sources/c++-playgraund/thread/build/")
     (cmake-ide-cmake-opts . "")
     (standard-indent . 4)))
 '(sh-basic-offset 8)
 '(standard-indent 8)
 '(warning-minimum-level :error)
 '(xref-prompt-for-identifier
   '(not xref-find-definitions xref-find-definitions-other-window xref-find-definitions-other-frame xref-find-references))
 '(xterm-mouse-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lsp-headerline-breadcrumb-path-face ((t (:foreground "red"))))
 '(lsp-headerline-breadcrumb-symbols-face ((t (:foreground "color-18")))))


(put 'narrow-to-region 'disabled nil)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

(require 'ansi-color)
(defun ansi-color-region ()
    "Color the ANSI escape sequences in the acitve region.
Sequences start with an escape \033 (typically shown as \"^[\")
and end with \"m\", e.g. this is two sequences
  ^[[46;1mTEXT^[[0m
where the first sequence says to diplay TEXT as bold with
a cyan background and the second sequence turns it off.

This strips the ANSI escape sequences and if the buffer is saved,
the sequences will be lost."
    (interactive)
    (if (not (region-active-p))
	(message "ansi-color-region: region is not active"))
    (if buffer-read-only
	;; read-only buffers may be pointing a read-only file system, so don't mark the buffer as
	;; modified. If the buffer where to become modified, a warning will be generated when emacs
	;; tries to autosave.
	(let ((inhibit-read-only t)
	      (modified (buffer-modified-p)))
	  (ansi-color-apply-on-region (region-beginning) (region-end))
	  (set-buffer-modified-p modified))
          (ansi-color-apply-on-region (region-beginning) (region-end))))


;;;; This turn on ansi color on compilation buffer
(require 'ansi-color)
(defun colorize-compilation-buffer ()
   (ansi-color-apply-on-region compilation-filter-start (point)))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)
;;;;;;

;; C++ and GO  configuration;;

(defun my-go-mode-hook ()
  ; Call Gofmt before saving
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))
  )

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setenv "GOPATH" "/home/fremmi/go")
  :config
  (setq lsp-file-watch-threshold 300000)
  :hook
  ((c-mode c++-mode) . lsp)
  (go-mode . lsp-deferred)
  (go-mode . my-go-mode-hook)
  (go-mode . yas-minor-mode)
  (go-mode . lsp-go-install-save-hooks)
  (python-mode . lsp)
  )

(use-package lsp-ui :commands lsp-ui-mode)


(add-hook 'c-mode-common-hook
  (lambda()
    (global-set-key  (kbd "C-c o") 'ff-find-other-file)))

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (add-hook 'c++-mode-hook 'company-mode)
  (add-hook 'c-mode-hook 'company-mode)
  (add-hook 'c-mode-common-hook 'yas-minor-mode)
  (add-hook 'after-init-hook 'global-company-mode)
  (define-key company-active-map (kbd "RET") 'company-complete-selection)
  (define-key company-active-map [return] 'company-complete-selection))


(use-package lsp-java
  :ensure t
  :config (add-hook 'java-mode-hook 'lsp))

;; (use-package clang-format
;;   :ensure t
;;   :hook ((c++-mode . clang-format-mode)
;; 	 (before-save . clang-format-buffer))
;;   :config
;;   (setq clang-format-style "file"))

(defun my-clang-format-on-save ()
  "Run clang-format before saving the file."
  (when (eq major-mode 'c++-mode) ; Customize for specific major modes if needed
    (clang-format-buffer)))

(add-hook 'before-save-hook #'my-clang-format-on-save)


(add-to-list 'load-path "/home/fremmi/myemacs/copilot.el")
(require 'copilot)

(add-hook 'prog-mode-hook 'copilot-mode)
(define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
(define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)


(provide '.emacs)
;;; .emacs ends here

