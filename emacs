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
 '(cmake-tab-width 4)
 '(custom-safe-themes
   '("0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5" default))
 '(indent-tabs-mode t)
 '(large-file-warning-threshold 300000000)
 '(org-agenda-files '("~/docs/agenda.org"))
 '(package-check-signature 'allow-unsigned)
 '(package-selected-packages
   '(gh-md gh-notify neotree dash go-autocomplete log4j-mode logview ag projectile egg-timer jq-mode jq-format lsp-mode ccls clang-format company-quickhelp chronos lsp-ui cpp-capf cpputils-cmake json-navigator company-ctags forge magithub gh docker docker-cli docker-tramp dockerfile-mode tramp magit-gh-pulls gnu-elpa-keyring-update json-mode restclient magit helm-fuzzy-find md-readme neato-graph-bar w3 docker-api docker-compose-mode cql-mode protobuf-mode elpy go-guru company-go go-mode kubernetes-tramp es-mode kubernetes smart-compile sr-speedbar meghanada irony company auto-complete-clang-async ggtags flycheck company-irony cmake-ide auto-complete-clang auto-complete-c-headers))
 '(reb-re-syntax 'string)
 '(safe-local-variable-values
   '((cmake-ide-build-dir . "/home/fremmi/sources/c++-playgraund/thread/build/")
     (cmake-ide-cmake-opts . "")
     (standard-indent . 4)))
 '(sh-basic-offset 8)
 '(standard-indent 8)
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

;; (use-package company-irony
;;   :ensure t
;;   :config
;;   (require 'company)
;;   (add-to-list 'company-backends 'company-irony))

;; (use-package irony
;;   :ensure t
;;   :config
;;   (add-hook 'c++-mode-hook 'irony-mode)
;;   (add-hook 'c-mode-hook 'irony-mode)
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

;; (use-package ggtags
;;   :ensure t
;;   :config
;;   (add-hook 'c++-mode-hook 'ggtags-mode)
;;   (add-hook 'c-mode-hook 'ggtags-mode)
;;   (setq ggtags-extra-args (quote ("--skip-unreadable")))
;;   (setq ggtags-oversize-limit (* 5 1024 1024 1024))
;;   )

;; (use-package rtags
;;   :ensure t
;;   :config
;;   (cmake-ide-setup)
;;   (setq cmake-ide-build-dir "/code/agent/build/release-internal/")
;;   (require 'company)
;;   (define-key c-mode-base-map (kbd "M-.")
;;     (function rtags-find-symbol-at-point))
;;   (define-key c-mode-base-map (kbd "M-,")
;;     (function rtags-find-references-at-point))
;;   (rtags-enable-standard-keybindings)
;;   (setq rtags-autostart-diagnostics t)
;;   (rtags-diagnostics)
;;   (setq rtags-completions-enabled t)
;;   (push 'company-rtags company-backends)
;;   (define-key c-mode-base-map (kbd "C-\t") (function company-complete))
;;   (require 'flycheck-rtags)
;;   (add-hook 'c++-mode #'setup-flycheck-rtags)
;;   (add-hook 'c-mode #'setup-flycheck-rtags)
;;   )

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l")
  :commands lsp
  :config
  (setq lsp-file-watch-threshold 300000))

(use-package lsp-ui :commands lsp-ui-mode)
;;(use-package company-lsp :commands company-lsp)

(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
	 (lambda () (require 'ccls) (lsp)))
  :config
  (setq ccls-executable "/usr/local/src/ccls/Release/ccls")
  )


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
  ;; (add-to-list 'company-backends 'company-lsp)
  (define-key company-active-map (kbd "RET") 'company-complete-selection)
  (define-key company-active-map [return] 'company-complete-selection))



;; (setq company-transformers nil company-lsp-async t company-lsp-cache-candidates nil)

;; (require 'go-guru)
;; (add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)
;; (push 'company-go company-backends)




;; PYTHON CONFIGURATION
;; --------------------------------------

(elpy-enable)
(setq python-shell-interpreter "ipython"
            python-shell-interpreter-args "-i --simple-prompt")

;; use flycheck not flymake with elpy
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; ;; enable autopep8 formatting on save
;; (require 'py-autopep8)
;; (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)




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




;;;;GO

(setenv "GOPATH" "/home/fremmi/go")

(require 'lsp-mode)
(add-hook 'go-mode-hook #'lsp-deferred)

(defun my-go-mode-hook ()
  ; Call Gofmt before saving
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))
  )
(add-hook 'go-mode-hook 'my-go-mode-hook)


;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
(add-hook 'go-mode-hook 'yas-minor-mode)




