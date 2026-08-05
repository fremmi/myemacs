;;; Code:
(setq password-cache-expiry nil)
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(use-package xclip
  :ensure t
  :config
  (xclip-mode 1))

;; (require 'ido) (ido-mode t)

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
;; (add-to-list 'package-archives '("local-dir" . "/home/francesco.emmi/tmp/melpa/packages") t)

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
   '((c-mode . "ellemtel") (c++-mode . "ellemtel") (java-mode . "java")
     (awk-mode . "awk") (other . "gnu")))
 '(c-offsets-alist '((innamespace . +)))
 '(cmake-tab-width 4)
 '(custom-enabled-themes '(doom-one))
 '(custom-safe-themes
   '("dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176"
     "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8"
     "9e5e0ff3a81344c9b1e6bfc9b3dcf9b96d5ec6a60d8de6d4c762ee9e2121dfb2"
     "d481904809c509641a1a1f1b1eb80b94c58c210145effc2631c1a7f2e4a2fdf4"
     "3613617b9953c22fe46ef2b593a2e5bc79ef3cc88770602e7e569bbd71de113b"
     "720838034f1dd3b3da66f6bd4d053ee67c93a747b219d1c546c41c4e425daf93"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     "0c32e4f0789f567a560be625f239ee9ec651e524e46a4708eb4aba3b9cdc89c5"
     default))
 '(indent-tabs-mode t)
 '(large-file-warning-threshold 300000000)
 '(lsp-clients-clangd-args '("--header-insertion-decorators=0"))
 '(package-check-signature 'allow-unsigned)
 '(package-selected-packages
   '(ag agent-shell all-the-icons-completion auto-complete-c-headers
	auto-complete-clang auto-complete-clang-async auto-org-md
	biomejs-format chatgpt-shell chronos clang-format claude-code
	cmake-ide cmake-mode company-ctags company-irony
	company-quickhelp consult-lsp consult-projectile
	cpputils-cmake dired-preview dired-ranger dirvish docker
	docker-api docker-cli docker-compose-mode docker-tramp
	dockerfile-mode doom-modeline doom-themes eat egg-timer elpy
	envrc es-mode fzf ggtags gh-md gh-notify
	gnu-elpa-keyring-update go-autocomplete go-dlv go-guru
	graphviz-dot-mode helm-fuzzy-find hierarchy jq-format jq-mode
	json-mode json-navigator kubed kubernetes kubernetes-helm
	kubernetes-tramp latex-extra latex-preview-pane log4j-mode
	logview lsp-java lsp-ui magit-gh-pulls marginalia markdown-toc
	md-readme meghanada melpa-upstream-visit memoize
	neato-graph-bar neotree nerd-icons-completion orderless
	origami protobuf-mode realgud-jdb restclient rust-mode
	simpleclip smart-compile sr-speedbar transpose-frame
	tree-sitter-langs treemacs-magit treemacs-projectile vertico
	vterm which-key xclip zoxide))
 '(reb-re-syntax 'string)
 '(safe-local-variable-values
   '((cmake-ide-build-dir
      . "/home/francesco.emmi/sources/c++-playgraund/thread/build/")
     (cmake-ide-cmake-opts . "") (standard-indent . 4)))
 '(sh-basic-offset 8)
 '(standard-indent 8)
 '(warning-minimum-level :error)
 '(xref-prompt-for-identifier
   '(not xref-find-definitions xref-find-definitions-other-window
	 xref-find-definitions-other-frame xref-find-references)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lsp-headerline-breadcrumb-path-face ((t (:foreground "red"))))
 '(lsp-headerline-breadcrumb-symbols-face ((t (:foreground "#0087af")))))


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
  (setenv "GOPATH" "/home/francesco.emmi/go")
  :commands lsp
  :config
  (setq lsp-file-watch-threshold 300000)
  (setq lsp-clients-protobuf-server-command '("bufls"))
  :hook
  ((c-mode c++-mode) . lsp)
  (go-mode . lsp-deferred)
  (rust-mode . lsp-deferred)
  (go-mode . my-go-mode-hook)
  (go-mode . yas-minor-mode)
  (rust-mode . yas-minor-mode)
  (go-mode . lsp-go-install-save-hooks)
  (python-mode . lsp)
  (protobuf-mode . lsp))

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-show-with-mouse nil
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.5
        lsp-ui-doc-include-signature t)
  ;; NOTE: keep off "C-c d" — that's the global dirvish binding; a minor-mode
  ;; map would shadow it in LSP buffers.
  (define-key lsp-ui-mode-map (kbd "C-c u") #'lsp-ui-doc-focus-frame))

(use-package rust-mode
  :ensure t
  :config
  (setq rust-format-on-save t))

(add-hook 'c-mode-common-hook
  (lambda()
    (global-set-key  (kbd "C-c o") 'ff-find-other-file)))

;; Show line numbers when editing C/C++ and Rust code
(add-hook 'c-mode-common-hook 'display-line-numbers-mode)
(add-hook 'rust-mode-hook 'display-line-numbers-mode)

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


(defun create-file-link ()
  "Create a link with the format file://filename:line-number."
  (interactive)
  (when buffer-file-name
    (let* ((line-number (line-number-at-pos))
           (link (format "file://%s:%d" buffer-file-name line-number)))
      (kill-new link)
      (message "Link copied to kill ring: %s" link))))


(keymap-global-set "C-c k" 'kubed-prefix-map)

(use-package hydra :ensure t)

(use-package transpose-frame :ensure t)

(use-package ace-window
  :ensure t
  :custom-face
  (aw-leading-char-face ((t (:foreground "yellow" :weight bold :height 3.0))))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(defun my/transpose-frame ()
  "Transpose frame, hiding treemacs first to avoid side-window conflicts."
  (interactive)
  (let ((treemacs-open (and (fboundp 'treemacs-get-local-window)
                            (treemacs-get-local-window))))
    (when treemacs-open (treemacs))
    (transpose-frame)
    (when treemacs-open (treemacs))))

(defhydra hydra-window (:color red)
  "Window management"
  ("h" windmove-left "go left")
  ("j" windmove-down "go down")
  ("k" windmove-up "go up")
  ("l" windmove-right "go right")
  ("v" split-window-right "split vertical")
  ("s" split-window-below "split horizontal")
  ("t" my/transpose-frame "transpose")
  ("w" ace-window "pick window")
  ("x" ace-swap-window "swap windows")
  ("d" delete-window "delete")
  ("o" delete-other-windows "only this")
  ("q" nil "quit" :color blue))

(global-set-key (kbd "C-c w") 'hydra-window/body)

(provide '.emacs)
;;; .emacs ends here


(add-hook 'java-mode-hook
          (lambda ()
            (setq c-basic-offset 4)
            (setq tab-width 4)
            (setq indent-tabs-mode nil)))


;; Enable protobuf-mode for .proto files
(use-package protobuf-mode
  :mode "\\.proto\\'"
  :config
  (setq protobuf-style "google"))

(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides
        '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))


(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))


(use-package consult-projectile
  :after (consult projectile))

;; Theme
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; Better mode line
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 1))

;; Terminal-compatible icons (run M-x nerd-icons-install-fonts once)
(use-package nerd-icons :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :init (nerd-icons-completion-mode))

;; 2. Enable Consult Previews
;; This makes it so when you scroll through results in 'consult-line' 
;; or 'consult-buffer', the actual file scrolls in the background.
(setq consult-preview-key 'any)

;; Replace standard search with "Live" fuzzy search
(global-set-key (kbd "C-s") 'consult-line)          ;; Search current file
(global-set-key (kbd "C-x b") 'consult-buffer)     ;; Enhanced buffer switcher

(use-package tree-sitter-langs :ensure t)
(use-package tree-sitter
  :ensure t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook 'tree-sitter-hl-mode))


;; Ensure M-s is available as a prefix
(define-prefix-command 'my-search-map)
(global-set-key (kbd "M-s") 'my-search-map)

;; Bind the "Fuzzy find in directory" (The C-u simulator)
(global-set-key (kbd "M-s d") 
                (lambda () 
                  (interactive) 
                  (let ((current-prefix-arg '(4))) 
                    (call-interactively 'consult-find))))

;; Bind the other useful search commands to the same prefix
(global-set-key (kbd "M-s l") 'consult-line)
(global-set-key (kbd "M-s r") 'consult-ripgrep)
(global-set-key (kbd "M-s i") 'consult-imenu)
(global-set-key (kbd "M-s b") 'consult-buffer)     ;; "b" for Buffer switcher

;; --- zoxide (yazi-style `z'/`zi' smart directory jump) ---
;; Needs the `zoxide' CLI (installed). `zoxide-find-file' lists all tracked
;; dirs for a fuzzy pick via vertico -- the equivalent of yazi's `zi'.
(use-package zoxide
  :ensure t
  :init
  ;; Open the picked directory straight into dirvish.
  (setq zoxide-find-file-function #'dirvish)
  ;; Feed the zoxide database as you navigate in Emacs.
  (add-hook 'find-file-hook  #'zoxide-add)
  (add-hook 'dired-mode-hook #'zoxide-add)
  :bind
  ("C-c z" . zoxide-find-file))         ; jump from anywhere

;; --- dirvish (yazi-like file manager built on Dired) ---
;; Miller-column layout + live file previews (images, pdf, archives, code).
;; Replaces dired-preview. For full previews install CLI helpers:
;;   sudo apt install ffmpegthumbnailer mediainfo poppler-utils imagemagick tar unzip

;; --------------------------------------------------------------------------
;; Yazi-faithful keymap helpers.
;; The goal: every key you press in yazi does the same thing in dirvish, so you
;; only have to remember one set of bindings. yazi's default keymap is mirrored
;; below (motion h/j/k/l + gg/G, Space/v selection, y/x/p copy-cut-paste,
;; d/D trash-delete, a create, r rename, . hidden, , sort, s/S/z/Z find, etc.).
;; --------------------------------------------------------------------------

;; `s': yazi-style fd name search. `dirvish-fd' only prompts with C-u C-u and
;; otherwise lists everything, so this wrapper always asks for the term up front.
(defun my/dirvish-fd-search (patterns)
  "Prompt for PATTERNS and run an fd file-name search in the current dir.
PATTERNS is a comma-separated list of fd regexes (ANDed together)."
  (interactive (list (completing-read-multiple "Search files (fd): " nil)))
  (dirvish-fd default-directory patterns))

;; gg / G : jump to the first/last real file (skipping header lines).
(defun my/dirvish-top ()
  "yazi `gg': move to the first file."
  (interactive) (goto-char (point-min)) (dired-next-line 1))
(defun my/dirvish-bottom ()
  "yazi `G': move to the last file."
  (interactive) (goto-char (point-max)) (dired-previous-line 1))

;; <Space> : toggle the mark on the current file, then advance (like yazi).
(defun my/dirvish-toggle-mark-down ()
  "yazi `<Space>': toggle the mark on the current file, then move down."
  (interactive)
  (if (save-excursion (beginning-of-line) (looking-at-p dired-re-mark))
      (dired-unmark 1)
    (dired-mark 1)))

;; <C-a> : select all.   <C-r> : invert the current selection.
(defun my/dirvish-mark-all ()
  "yazi `<C-a>': mark every file in the listing."
  (interactive) (dired-unmark-all-marks) (dired-toggle-marks))

;; y / x / p : copy / cut / paste, the yazi two-step way (stage, then paste at
;; the destination). Backed by dired-ranger; `x' just flags the stage as a move.
(defvar my/dired-ranger-cut nil
  "Non-nil when the last stage (`x') was a cut rather than a copy.")
(defun my/dirvish-yank-copy (&optional arg)
  "yazi `y': stage the marked/current files for a copy."
  (interactive "P")
  (setq my/dired-ranger-cut nil)
  (dired-ranger-copy arg))
(defun my/dirvish-yank-cut (&optional arg)
  "yazi `x': stage the marked/current files for a move."
  (interactive "P")
  (setq my/dired-ranger-cut t)
  (dired-ranger-copy arg))
(defun my/dirvish-paste (&optional arg)
  "yazi `p': paste here, moving if the stage was a cut, else copying.
ARG is passed through to dired-ranger (both `dired-ranger-paste' and
`dired-ranger-move' require it): with \\[universal-argument] keep the
selection on the stack, or a numeric prefix pastes the nth entry."
  (interactive "P")
  (if my/dired-ranger-cut (dired-ranger-move arg) (dired-ranger-paste arg)))

;; d / D : trash / delete-permanently the marked or current files.
(defun my/dirvish-trash ()
  "yazi `d': move the marked/current files to the system trash."
  (interactive)
  (let ((delete-by-moving-to-trash t)) (dired-do-delete)))
(defun my/dirvish-delete-permanently ()
  "yazi `D': delete the marked/current files permanently (no trash)."
  (interactive)
  (let ((delete-by-moving-to-trash nil)) (dired-do-delete)))

;; a : create a file, or a directory if the name ends in `/' (matches yazi).
(defun my/dirvish-create (name)
  "yazi `a': create NAME; a trailing slash makes a directory."
  (interactive (list (read-string "Create (end with / for a directory): ")))
  (if (string-suffix-p "/" name)
      (dired-create-directory (directory-file-name name))
    (dired-create-empty-file name)))

;; . : toggle visibility of dotfiles by flipping ls's `-A' switch.
(defun my/dirvish-toggle-hidden ()
  "yazi `.': toggle whether dotfiles are shown."
  (interactive)
  (let ((sw (or dired-actual-switches "-l")))
    (dired-sort-other
     (if (string-match-p "[aA]" sw)
         (replace-regexp-in-string "[aA]" "" sw)
       (concat sw "A")))))

;; S : ripgrep file contents under the current dir.   Z : fzf-style file jump.
(defun my/dirvish-rg ()
  "yazi `S': ripgrep file contents under the current directory."
  (interactive)
  (if (fboundp 'consult-ripgrep) (consult-ripgrep default-directory)
    (call-interactively #'rgrep)))
(defun my/dirvish-fzf ()
  "yazi `Z': fuzzy-find a file under the current dir and jump to it."
  (interactive)
  (if (fboundp 'consult-fd) (consult-fd default-directory)
    (dirvish-fd default-directory "")))

;; o / O : open with the system default app (dirs are entered, as in yazi).
(defun my/dirvish-open-externally ()
  "yazi `o': open the file with the system default application."
  (interactive)
  (if (file-directory-p (dired-get-filename))
      (dired-find-file)
    (if (fboundp 'dired-do-open) (dired-do-open) (browse-url-of-dired-file))))

;; J : open the current file with jless in a new tmux window (great for JSON).
;; Requires Emacs to be running inside a tmux session; the jless window closes
;; when you quit jless, dropping you back to the Emacs/dirvish window.
(defun my/dirvish-jless ()
  "yazi-style `J': open the current file with jless in a new tmux window."
  (interactive)
  (let ((file (dired-get-filename)))
    (if (getenv "TMUX")
        (start-process "dirvish-jless" nil "tmux" "new-window"
                       (format "jless %s" (shell-quote-argument file)))
      (user-error "Not inside a tmux session"))))

;; cn : copy the file name without its extension (yazi's copy-name-no-ext).
(defun my/dirvish-copy-name-no-ext ()
  "yazi `cn': copy the current file name, sans extension, to the kill-ring."
  (interactive)
  (let ((n (file-name-sans-extension (file-name-nondirectory (dired-get-filename t)))))
    (kill-new n) (message "Copied: %s" n)))

;; `g' prefix: go-to / bookmarks, mirroring yazi's `g' menu.
(defun my/dirvish-cd (dir) "Open DIR in dirvish." (dired (expand-file-name dir)))
(defvar my/dirvish-goto-map
  (let ((m (make-sparse-keymap)))
    (define-key m "g" #'my/dirvish-top)                                       ; gg -> top
    (define-key m "h" (lambda () (interactive) (my/dirvish-cd "~/")))         ; gh -> home
    (define-key m "c" (lambda () (interactive) (my/dirvish-cd "~/.config")))  ; gc -> config
    (define-key m "d" (lambda () (interactive) (my/dirvish-cd "~/Downloads"))); gd -> downloads
    (define-key m "p" (lambda () (interactive) (my/dirvish-cd "~/sysdig")))   ; gp -> sysdig
    (define-key m "e" (lambda () (interactive) (my/dirvish-cd "~/.emacs.d"))) ; ge -> emacs
    (define-key m "a" #'dirvish-quick-access)                                 ; ga -> access menu
    (define-key m "f" #'dirvish-file-info-menu)                               ; gf -> file info
    m)
  "yazi-style `g' prefix for dirvish: go-to / bookmarks.")

;; `c' prefix: copy path/name to the kill-ring, mirroring yazi's `c' menu.
(defvar my/dirvish-copy-map
  (let ((m (make-sparse-keymap)))
    (define-key m "c" #'dirvish-copy-file-path)        ; cc -> full path
    (define-key m "d" #'dirvish-copy-file-directory)   ; cd -> directory path
    (define-key m "f" #'dirvish-copy-file-name)        ; cf -> file name
    (define-key m "n" #'my/dirvish-copy-name-no-ext)   ; cn -> name without ext
    m)
  "yazi-style `c' prefix for dirvish: copy path/name.")

;; dired-ranger gives yazi's stage-then-paste copy/cut/paste model.
(use-package dired-ranger :ensure t)

(use-package dirvish
  :ensure t
  :init
  ;; Use dirvish in place of plain Dired everywhere.
  (dirvish-override-dired-mode)
  ;; Dired/dirvish buffers are non-file buffers, so they don't refresh when the
  ;; directory changes on disk unless auto-revert is told to watch them. Enable
  ;; global auto-revert for such buffers so adding/removing files updates the
  ;; listing automatically (as Dirvish's README recommends).
  (setq global-auto-revert-non-file-buffers t)
  (global-auto-revert-mode 1)
  :custom
  ;; Quick-access bookmarks (yazi `g a' / `g <key>').
  (dirvish-quick-access-entries
   '(("h" "~/"            "Home")
     ("p" "~/sysdig/"     "Sysdig")
     ("e" "~/.emacs.d/"   "Emacs")))
  :config
  ;; Attributes shown in the file list (icons via your nerd-icons, git state...).
  (setq dirvish-attributes
        '(nerd-icons collapse git-msg file-time file-size subtree-state))
  ;; Image/video/gif/audio thumbnails need a graphical frame (and vipsthumbnail).
  ;; In a terminal they raise "Window system frame should be used" / missing-program
  ;; errors, so drop them there and keep only the TTY-friendly previewers.
  (unless (display-graphic-p)
    (setq dirvish-preview-dispatchers
          (cl-set-difference dirvish-preview-dispatchers
                             '(image gif video audio epub))))
  ;; Show full path + a short Dired-style header line.
  (setq dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-header-line-format '(:left (path) :right (free-space)))
  ;; Prefix maps are easiest to attach directly (use-package :bind is per-key).
  (define-key dirvish-mode-map "g" my/dirvish-goto-map)   ; yazi `g' go-to prefix
  (define-key dirvish-mode-map "c" my/dirvish-copy-map)   ; yazi `c' copy prefix
  :bind
  (("C-c d" . dirvish)                 ; open dirvish in current dir
   ("C-c D" . dirvish-fd)              ; fuzzy-find files into a dirvish buffer
   :map dirvish-mode-map
   ;; --- motion ---
   ("h"       . dired-up-directory)          ; leave dir  (to the parent pane)
   ("<left>"  . dired-up-directory)          ; yazi: arrow-left = leave dir
   ("j"       . dired-next-line)             ; down  (overrides dired's goto)
   ("k"       . dired-previous-line)         ; up    (overrides dired's kill)
   ("l"       . dired-find-file)             ; enter dir / open in Emacs
   ("<right>" . dired-find-file)             ; yazi: arrow-right = enter dir
   ("G"     . my/dirvish-bottom)             ; gg is on the `g' prefix above
   ("TAB"   . dirvish-subtree-toggle)        ; expand/collapse a dir inline (bonus)
   ;; --- selection ---
   ("SPC"   . my/dirvish-toggle-mark-down)   ; toggle mark + move down
   ("v"     . dired-mark)                    ; visual: marks region or current
   ("V"     . dired-unmark)                  ; visual unselect
   ("C-a"   . my/dirvish-mark-all)           ; select all
   ("C-r"   . dired-toggle-marks)            ; invert selection
   ;; --- file operations ---
   ("y"     . my/dirvish-yank-copy)          ; stage copy
   ("x"     . my/dirvish-yank-cut)           ; stage cut
   ("p"     . my/dirvish-paste)              ; paste here
   ("d"     . my/dirvish-trash)              ; trash
   ("D"     . my/dirvish-delete-permanently) ; delete permanently
   ("a"     . my/dirvish-create)             ; create file/dir
   ("r"     . dired-do-rename)               ; rename
   ("o"     . my/dirvish-open-externally)    ; open with system app
   ("O"     . dired-do-open)                 ; open interactively
   ("J"     . my/dirvish-jless)              ; open with jless in a new tmux window
   (";"     . dired-do-shell-command)        ; run a shell command
   (":"     . dired-do-async-shell-command)  ; run a shell command (async)
   ;; --- find / filter / sort / jump ---
   ("/"     . dired-isearch-filenames)       ; find (jump to a name)
   ("f"     . dirvish-narrow)                ; live filter of the listing
   ("s"     . my/dirvish-fd-search)          ; fd file-name search
   ("S"     . my/dirvish-rg)                 ; ripgrep file contents
   ("z"     . zoxide-find-file)              ; zoxide smart-jump
   ("Z"     . my/dirvish-fzf)                ; fzf-style fuzzy file jump
   ("."     . my/dirvish-toggle-hidden)      ; toggle dotfiles
   (","     . dirvish-quicksort)             ; sort menu
   ("M-t"   . dirvish-layout-toggle)))       ; toggle miller-column layout (bonus)

;; --- FIXED NAVIGATION & SEARCH ---

;; 1. Restore standard 'Go to Definition' (M-.)
;; By removing the remap above, M-. will now work with clangd again.

;; 2. Add LSP Search features to your M-s "Search Hub"
;; This allows you to search symbols without breaking the "Jump" function.
(with-eval-after-load 'lsp-mode
  (global-set-key (kbd "M-s s") #'consult-lsp-symbols)      ;; M-s s: Search symbols in project
  (global-set-key (kbd "M-s e") #'consult-lsp-diagnostics)) ;; M-s e: Search errors/warnings

;; Force-reset the jump command to stop the "Wrong type argument" error
(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map [remap xref-find-definitions] nil))

;; 3. Show LSP navigation results in the consult/vertico fzf-style picker
;; (with live preview), the same UI as C-c f g. lsp-find-definition,
;; -references, -implementation, -type-definition all route through these.
(with-eval-after-load 'consult
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package dap-mode
  :ensure t
  :config
  (dap-mode 1)
  (dap-ui-mode 1)          ; Adds the visual windows (stack, locals, etc.)
  (dap-tooltip-mode 1)     ; See variable values by hovering
  
  ;; This is the line you are missing:
  (require 'dap-cpptools)  ; Provides the bridge for Rust/C++/C
  
  ;; This command automatically downloads the VS Code extension
  ;; that Rust-Analyzer uses behind the scenes for debugging.
  (dap-cpptools-setup))


;; --- Treemacs (nvim-tree analogue) ---
(use-package treemacs
  :ensure t
  :defer t
  :bind (("C-c t" . treemacs)
         ("C-c 0" . treemacs-select-window))
  :config
  (setq treemacs-width 30
        treemacs-follow-after-init t
        treemacs-is-never-most-recent-window t
        treemacs-project-follow-cleanup t
        treemacs-show-hidden-files nil
        treemacs-display-in-side-window t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'deferred))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package magit
  :ensure t
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; --- ediff conflict resolution: "take both A and B" ---
;; Two knobs, both leaving `ediff-default-variant' at its default `combined' --
;; the merge buffer keeps starting out with both variants wrapped in markers:
;;
;;   - Use git's marker style instead of ediff's "<<<<<<< variant A" /
;;     ">>>>>>> variant B" / "####### Ancestor" / "======= end", so those markers
;;     look like a normal conflict.  5 elements is the minimum the code accepts,
;;     and dropping Ancestor is fine: plain conflict markers (no ||||||| section)
;;     mean `smerge-ediff' sets up a merge with no ancestor buffer anyway.
;;   - `d' (below) to take both sides with no delimiters at all.
;;
;; NB `magit-ediff-resolve-all' rebinds this buffer-locally, and its value is
;; malformed upstream (plain quote around unquoted commas), so + signals
;; "Invalid format" there.  `magit-ediff-resolve-rest' -- the default for
;; `magit-ediff-dwim' -- is unaffected.
(setq ediff-combination-pattern
      '("<<<<<<< HEAD" A "=======" B ">>>>>>> other"))

(defun my/ediff-copy-both-to-C (&optional n)
  "Copy the Nth diff region of A followed by B into the merge buffer.
Unlike \\[ediff-combine-diffs] this inserts no conflict markers.  N is a
prefix argument; without one, act on the current difference region."
  (interactive "P")
  (setq n (if (numberp n) (1- n) ediff-current-difference))
  (when (< n 0)
    (user-error "Move to a difference region first (n/p)"))
  (ediff-copy-diff
   n nil 'C nil
   (concat (ediff-get-region-contents n 'A ediff-control-buffer)
           (ediff-get-region-contents n 'B ediff-control-buffer)))
  (ediff-jump-to-difference (1+ n)))

(defun my/ediff-combine-to-C (&optional n)
  "Put both variants of the Nth diff region into the merge buffer, with markers.
Like \\[ediff-combine-diffs] -- the delimiters come from
`ediff-combination-pattern' -- but always reports what happened instead of
printing a bare nil when the region already holds the combination."
  (interactive "P")
  (setq n (if (numberp n) (1- n) ediff-current-difference))
  (when (< n 0)
    (user-error "Move to a difference region first (n/p)"))
  (let ((combined (ediff-get-combined-region n))
        (current  (ediff-get-region-contents n 'C ediff-control-buffer)))
    (if (string= current combined)
        (message "Region %d already holds both variants" (1+ n))
      (ediff-copy-diff n nil 'C nil combined)
      (message "Region %d: took both A and B (type `r' to restore)" (1+ n))))
  (ediff-jump-to-difference (1+ n)))

;; Only merge jobs have a separate merge buffer to copy into, so bind there.
;; `+' shadows `ediff-combine-diffs' with the reporting version above.
(add-hook 'ediff-keymap-setup-hook
          (lambda ()
            (when ediff-merge-job
              (define-key ediff-mode-map "d" #'my/ediff-copy-both-to-C)
              (define-key ediff-mode-map "+" #'my/ediff-combine-to-C))))

;; Open files without splitting: always reuse the existing non-treemacs window
(with-eval-after-load 'treemacs
  (dolist (node '(file-node-open file-node-closed tag-node-open tag-node-closed tag-node))
    (setf (alist-get node treemacs-RET-actions-config)
          #'treemacs-visit-node-no-split)))

;; Source files always reuse the single main window (+ the treemacs side
;; window) instead of splitting -- e.g. picking a `consult-ripgrep' result no
;; longer carves out a new tiny window. This rule matches only file-visiting
;; buffers, so help/magit/compilation/lsp popups are unaffected and keep their
;; normal splitting behavior.
(add-to-list 'display-buffer-alist
             `(,(lambda (buf _act)
                  (buffer-local-value 'buffer-file-name (get-buffer buf)))
               (display-buffer-reuse-window
                display-buffer-use-some-window)
               (inhibit-same-window . nil)))


;; --- which-key (prefix discoverability) ---
(use-package which-key
  :ensure t
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.4))


;; --- consult-lsp (used by M-s s / M-s e and the C-c f hub) ---
(use-package consult-lsp
  :ensure t
  :after (consult lsp-mode))


;; --- Telescope-style "find" hub on C-c f ---
;; Mirrors nvim Telescope mnemonics: ff/fg/fb/fr/fs/fd/fp.
(define-prefix-command 'my-find-map)
(global-set-key (kbd "C-c f") 'my-find-map)
(define-key my-find-map (kbd "f") #'consult-projectile-find-file)
(define-key my-find-map (kbd "g") #'consult-ripgrep)
(define-key my-find-map (kbd "b") #'consult-projectile)
(define-key my-find-map (kbd "r") #'consult-recent-file)
(define-key my-find-map (kbd "p") #'projectile-switch-project)
(with-eval-after-load 'consult-lsp
  (define-key my-find-map (kbd "s") #'consult-lsp-symbols)
  (define-key my-find-map (kbd "d") #'consult-lsp-diagnostics))


(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))


;; --- claude-code (Claude Code CLI integration) ---
;; Dev branch (v0.4.5+), installed via:
;;   M-x package-vc-install RET https://github.com/stevemolitor/claude-code.el
;; Requires Emacs 30 and the `eat' terminal backend (pure elisp, no native
;; module). Runs Claude Code CLI sessions in eat buffers, scoped per project.

;; eat: terminal backend used by claude-code (NonGNU ELPA).
(use-package eat
  :ensure t)

(use-package claude-code
  ;; NOT :ensure t -- installed from git via package-vc-install, not an archive.
  :after eat
  :config
  ;; Path to the Claude CLI (renamed from `claude-code-executable' in the rewrite).
  (setq claude-code-program "/home/francesco.emmi/.local/bin/claude")
  ;; Match the shell alias's flags if you want them in Emacs too:
  ;; (setq claude-code-program-switches '("--settings" "/home/francesco.emmi/.claude/spinner-verbs.json"))
  (claude-code-mode)              ; global mode (mode-line + buffer tracking)
  (setq claude-code-no-delete-other-windows t)
  ;; Open Claude in a dedicated right-side window; no other buffer can replace it.
  (setq claude-code-display-window-fn
        (lambda (buffer)
          (let ((win (display-buffer
                      buffer
                      '(display-buffer-in-side-window
                        (side . right)
                        (window-width . 0.35)
                        (slot . 0)
                        (window-parameters . ((no-other-window . nil)))))))
            (when win
              ;; Strong dedication (non-nil, non-t): blocks not just
              ;; `display-buffer' reuse but also `switch-to-buffer' /
              ;; `set-window-buffer', so no other buffer can take this window.
              (set-window-dedicated-p win 'claude))
            win)))
  :bind-keymap
  ("C-c c" . claude-code-command-map)   ; prefix: C-c c x = send command WITH CONTEXT
  :bind
  ("C-c a" . claude-code-transient)     ; transient menu
  ("C-c C-a" . my/jump-to-claude-window))

(defun my/jump-to-claude-window ()
  "Jump to the Claude Code window, crossing frames if needed."
  (interactive)
  (let ((win (cl-find-if
              (lambda (w)
                (string-prefix-p "*claude" (buffer-name (window-buffer w))))
              (window-list-1 nil 'nomini t))))
    (if win
        (progn
          (select-frame-set-input-focus (window-frame win))
          (select-window win))
      (claude-code))))

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
