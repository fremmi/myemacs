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
   (quote
    ((c-mode . "ellemtel")
     (c++-mode . "ellemtel")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(cmake-tab-width 4)
 '(custom-safe-themes
   (quote
    ("0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5" default)))
 '(indent-tabs-mode t)
 '(org-agenda-files (quote ("~/docs/agenda.org")))
 '(package-check-signature (quote allow-unsigned))
 '(package-selected-packages
   (quote
    (chronos company-lsp ccls lsp-ui cpp-capf cpputils-cmake json-navigator company-ctags forge magithub gh docker docker-cli docker-tramp dockerfile-mode tramp magit-gh-pulls gnu-elpa-keyring-update json-mode restclient magit helm-fuzzy-find md-readme neato-graph-bar w3 docker-api docker-compose-mode cql-mode protobuf-mode elpy go-guru company-go go-mode kubernetes-tramp es-mode kubernetes smart-compile sr-speedbar meghanada irony company auto-complete-clang-async ggtags flycheck company-irony cmake-ide auto-complete-clang auto-complete-c-headers)))
 '(safe-local-variable-values (quote ((standard-indent . 4))))
 '(sh-basic-offset 8)
 '(show-trailing-whitespace t)
 '(standard-indent 8)
 '(xref-prompt-for-identifier
   (quote
    (not xref-find-definitions xref-find-definitions-other-window xref-find-definitions-other-frame xref-find-references))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (add-hook 'c++-mode-hook 'company-mode)
  (add-hook 'c-mode-hook 'company-mode)
  (define-key company-active-map (kbd "RET") 'company-complete-selection)
  (define-key company-active-map [return] 'company-complete-selection))

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
  :commands lsp
  :config
  (setq lsp-file-watch-threshold 300000))

(use-package lsp-ui :commands lsp-ui-mode)
(use-package company-lsp :commands company-lsp)

(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
	 (lambda () (require 'ccls) (lsp)))
  :config
  (setq ccls-executable "/usr/local/src/ccls/Release/ccls")
  )


(add-hook 'c-mode-common-hook
  (lambda()
    (global-set-key  (kbd "C-c o") 'ff-find-other-file)))

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




