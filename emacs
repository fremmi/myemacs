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
;; (define-key input-decode-map "\e[1;5A" [C-up])
;; (define-key input-decode-map "\e[1;5B" [C-down])
(define-key input-decode-map "\e[1;3A" [M-up])
;;(define-key input-decode-map "\e[1;5B" [M-down])
(define-key input-decode-map "\e[1;3B" [M-down])
(define-key input-decode-map "\e[1;3C" [M-right])
(define-key input-decode-map "\e[1;3D" [M-left])


(setq org-support-shift-select t)
;(setq org-clock-idle-time 60)

(add-hook 'org-mode-hook
          (lambda ()
            (org-defkey org-mode-map [?\C-c (up)] 'windmove-up)
            (org-defkey org-mode-map [?\C-c (down)] 'windmove-down)
            (org-defkey org-mode-map [?\C-c (right)] 'windmove-right)
            (org-defkey org-mode-map [?\C-c (left)] 'windmove-left)))



(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)


(add-hook 'c-mode-common-hook
  (lambda()
    (global-set-key  (kbd "C-c o") 'ff-find-other-file)))





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


(require 'rtags) ;; optional, must have rtags installed
(global-flycheck-mode)
(cmake-ide-setup)

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
 '(cmake-ide-build-dir "/code/agent/build/debug")
 '(cmake-ide-cmake-opts
   "-DCMAKE_BUILD_TYPE=Debug -DDRAIOS_DEPENDENCIES_DIR=/code/agent/dependencies -DJAVA_HOME=/code/agent/dependencies/jdk1.7.0_75 -DAGENT_VERSION=0.1.1dev -DSTATSITE_VERSION=0.7.0-sysdig5 -DBUILD_DRIVER=ON -DBUILD_BPF=OFF -DPACKAGE_DEB_ONLY=OFF")
 '(cmake-ide-make-command "make --no-print-directory -j4 install")
 '(company-auto-complete (quote (quote company-explicit-action-p)))
 '(company-auto-complete-chars (quote (32 95 41 119 46 36 39 47 124 33)))
 '(company-idle-delay 0.2)
 '(custom-safe-themes
   (quote
    ("0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5" default)))
 '(global-company-mode t)
 '(indent-tabs-mode t)
 '(package-selected-packages
   (quote
    (magithub cql-mode protobuf-mode elpy go-guru company-go go-mode kubernetes-tramp es-mode kubernetes smart-compile sr-speedbar meghanada company-rtags flycheck-rtags irony company auto-complete-clang-async yasnippet yaml-mode rtags magit ggtags flycheck docker company-irony cmake-ide auto-complete-clang auto-complete-c-headers)))
 '(show-trailing-whitespace t)
 '(standard-indent 8))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; ensure that we use only rtags checking
;; https://github.com/Andersbakken/rtags#optional-1 
(defun setup-flycheck-rtags ()
  (interactive)
  (flycheck-select-checker 'rtags)
  ;; RTags creates more accurate overlays.
  (setq-local flycheck-highlighting-mode nil)
  (setq-local flycheck-check-syntax-automatically nil))

 

;; only run this if rtags is installed
(when (require 'rtags nil :noerror)
  ;; make sure you have company-mode installed
  (require 'company)
  (define-key c-mode-base-map (kbd "M-.")
    (function rtags-find-symbol-at-point))
  (define-key c-mode-base-map (kbd "M-,")
    (function rtags-find-references-at-point))
  ;; disable prelude's use of C-c r, as this is the rtags keyboard prefix
  ;; (define-key prelude-mode-map (kbd "C-c r") nil)
  ;; install standard rtags keybindings. Do M-. on the symbol below to
  ;; jump to definition and see the keybindings.
  (rtags-enable-standard-keybindings)
  ;; comment this out if you don't have or don't use helm
  ;; (setq rtags-use-helm t)
  ;; company completion setup
  (setq rtags-autostart-diagnostics t)
  (rtags-diagnostics)
  (setq rtags-completions-enabled t)
  (push 'company-rtags company-backends)
  (global-company-mode)
  (define-key c-mode-base-map (kbd "C-\t") (function company-complete))
  ;; use rtags flycheck mode -- clang warnings shown inline
  (require 'flycheck-rtags)
  ;; c-mode-common-hook is also called by c++-mode
  (add-hook 'c-mode-common-hook #'setup-flycheck-rtags))


(require 'go-guru)
(add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)
(push 'company-go company-backends)


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
