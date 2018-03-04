 (setq show-trailing-whitespace t)

(setq password-cache-expiry nil)

(setq-default indent-tabs-mode nil)

(require 'ido) (ido-mode t)

(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c l") 'org-store-link)

(define-key input-decode-map "\e[H" [home])
(define-key input-decode-map "\e[F" [end])
(define-key input-decode-map "\e[1;5A" [C-up])
(define-key input-decode-map "\e[1;5B" [C-down])
(define-key input-decode-map "\e[1;3A" [M-up])
;;(define-key input-decode-map "\e[1;5B" [M-down])
(define-key input-decode-map "\e[1;3B" [M-down])
(define-key input-decode-map "\e[1;3C" [M-right])
(define-key input-decode-map "\e[1;3D" [M-left])


(setq org-support-shift-select t)
(setq org-clock-idle-time 60)

(add-hook 'org-mode-hook
          (lambda ()
            (org-defkey org-mode-map [?\C-c (up)] 'windmove-up)
            (org-defkey org-mode-map [?\C-c (down)] 'windmove-down)
            (org-defkey org-mode-map [?\C-c (right)] 'windmove-right)
            (org-defkey org-mode-map [?\C-c (left)] 'windmove-left)))


(autoload 'gid "idutils" nil t)
(autoload 'ggtags-mode "gtags" "" t)
(global-set-key (kbd "M-.") 'gtags-find-tag)
(global-set-key (kbd "M-,") 'gtags-find-rtag)






(add-to-list 'semantic-default-submodes 'global-semantic-idle-completions-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-idle-summary-mode)
;; (add-to-list 'load-path "~/.emacs.d/elpa")


(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

(require 'yasnippet)
(yas-global-mode 1)

(defun my:ac-c-header-init()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/usr/include/c++/5/"))

(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1)
              (semantic-mode 1)
              (setq show-trailing-whitespace t))))

(add-hook 'c-mode-common-hook 'my:ac-c-header-init)

(add-hook 'c-mode-common-hook
  (lambda()
    (global-set-key  (kbd "C-c o") 'ff-find-other-file)))





(global-set-key (kbd "M-g M-c") 'go-to-column)

(setq js-indent-level 4)

(require 'parse-time)


(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)


(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(setq show-trailing-whitespace t)

;; (add-to-list 'load-path "~/.emacs.d/elpa/magit/lisp")
;; (require 'magit)

;; (with-eval-after-load 'info
;;   (info-initialize)
;;   (add-to-list 'Info-directory-list
;;                       "~/.emacs.d/elpa/magit/Documentation/"))

;; (add-to-list 'load-path "~/.emacs.d/elpa/magit-gerrit")
;; (require 'magit-gerrit)

;; if remote url is not using the default gerrit port and
;; ssh scheme, need to manually set this variable
;; (setq-default magit-gerrit-ssh-creds "femmi@gerrit.minervanetworks.com")


;; if necessary, use an alternative remote instead of 'origin'
;; (setq-default magit-gerrit-remote "origin")


;; (setq magit-repo-dirs '("/home/fremmi/source/" "/home/fremmi/source/"))

;; (eval-after-load "magit"
;;   '(mapc (apply-partially 'add-to-list 'magit-repo-dirs)
;;                '("~/source/dss" "~/source/itvbackend")))




;; (add-to-list 'load-path (format "%s/jdee-2.4.1/lisp" "/home/fremmi/.emacs.d"))
;; (autoload 'jde-mode "jde" "JDE mode" t)
;; (setq auto-mode-alist
;;               (append '(("\\.java\\'" . jde-mode)) auto-mode-alist))






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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(c-basic-offset 8)
 '(c-default-style "ellemtel")
 '(custom-enabled-themes (quote (wheatgrass)))
 '(global-semantic-decoration-mode t)
 '(global-semantic-highlight-edits-mode t)
 '(global-semantic-highlight-func-mode t)
 '(global-semantic-idle-completions-mode t nil (semantic/idle))
 '(global-semantic-idle-scheduler-mode t)
 '(global-semantic-idle-summary-mode t)
 '(global-semantic-stickyfunc-mode t)
 '(global-semanticdb-minor-mode t)
 '(indent-tabs-mode t)
 '(package-selected-packages
   (quote
    (es-mode emacsql emacsql-mysql auto-yasnippet ecb company-irony-c-headers docker-compose-mode magit yaml-mode docker docker-api docker-tramp dockerfile-mode yasnippet smart-compile magit-gerrit ggtags cmake-mode auto-complete-c-headers)))
 '(semantic-complete-inline-analyzer-idle-displayor-class (quote semantic-displayor-tooltip))
 '(semantic-idle-scheduler-idle-time 0.2)
 '(semantic-mode nil)
 '(semanticdb-project-roots
   (quote
    ("/home/fremmi/draios/sysdig/" "/home/fremmi/draios/dragent/"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
