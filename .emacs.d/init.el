;;; -*- lexical-binding: t -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stolen bits from Doom Emacs to make the startup faster ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Silence noisy third-party warnings we can't fix
(with-eval-after-load 'warnings
  (add-to-list 'warning-suppress-types '(files missing-lexbind-cookie))
  (add-to-list 'warning-suppress-log-types '(files missing-lexbind-cookie))
  (add-to-list 'warning-suppress-types '(native-compiler))
  (add-to-list 'warning-suppress-log-types '(native-compiler)))
(setq native-comp-async-report-warnings-errors 'silent)

;; supressing garabge-collector at startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 16777216
          gc-cons-percentage 0.1)))

;; unset file-name-handler-alist temporarily 
(defvar doom--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist doom--file-name-handler-alist)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(global-hl-line-mode 1)
(global-visual-line-mode -1)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(setq-default indent-tabs-mode nil)
(setf dired-kill-when-opening-new-dired-buffer t)
(set-frame-parameter nil 'alpha-background 90)
(setq scroll-conservatively 1)
(setq use-short-answers t)
(setq confirm-nonexistent-file-or-buffer nil)
(setq delete-by-moving-to-trash t)
(advice-add 'risky-local-variable-p :override #'ignore)
(winner-mode)

(add-hook 'prog-mode-hook
          (lambda ()
            (display-line-numbers-mode 1)
            (toggle-truncate-lines 1)))

(dolist (file (directory-files "~/.emacs.d/elisp/" t "\\.el$"))
  (load-file file))


;; Get rid of annoying backup/autosave/lock files
(setq create-lockfiles nil)
(setq temporary-file-directory "~/.emacs.d/tmp/")
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq custom-file "~/.emacs-custom.el")
(load custom-file)
(add-to-list 'exec-path "~/.local/bin")

(set-face-attribute 'default nil :font "JetBrains Mono" :height 130)
(modify-syntax-entry ?_ "w")

;; font for arabic characters
(set-fontset-font
   "fontset-default"
   (cons (decode-char 'ucs #x0600) (decode-char 'ucs #x06ff)) ; arabic
   "Vazir Code")

(unless (query-fontset "fontset-prose")
  (create-fontset-from-fontset-spec "-*-*-*-*-*--*-*-*-*-*-*-fontset-prose"))
(set-fontset-font "fontset-prose" '(#x600 . #x6ff) "IRANSansX")

(defface kz/prose-face '((t))
  "Face used in `kz/prose-mode' buffers.")
(set-face-attribute 'kz/prose-face nil :fontset "fontset-prose")

(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; window layout settings ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq switch-to-buffer-obey-display-actions t)
(setq switch-to-buffer-in-dedicated-window 'pop)
(setq display-buffer-alist nil)
(setq help-window-select t)
(add-to-list 'display-buffer-alist
             '("\\*help\\*\\|\\*pytest\\*\\|\\*Gofmt Errors\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.25 )))

(setq calendar-week-start-day 6)

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

(use-package dash)

(use-package swiper)

(use-package projectile
  :demand t
  :config (projectile-mode)
  :init
  (setq projectile-switch-project-action #'kz/projectile-switch-project-action)
  (setq projectile-git-submodule-command "true"))

(use-package counsel
  :bind ("M-x" . counsel-M-x)
  :bind ("C-x b" . counsel-switch-buffer)
  :bind ("C-x C-b" . counsel-switch-buffer))

(use-package prescient
  :config
  (prescient-persist-mode 1))

(use-package company-prescient
  :after company
  :config
  (company-prescient-mode 1))

(use-package ivy
  :diminish
  :config
  (setq ivy-use-selectable-prompt t)
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-insert-current)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k"  . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill)) 
  :config
  (ivy-mode 1)
  (add-to-list 'ivy-initial-inputs-alist '(counsel-M-x . "")))

(use-package ivy-prescient
  :after ivy
  :config
  (ivy-prescient-mode 1))

(use-package marginalia
  :config
  (setq marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1))
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  (column-number-mode 1)
  (load-theme 'doom-xcode))

(use-package beacon
  :config
  (beacon-mode 1)
  (setq beacon-color "#3730d9"))

(use-package highlight-indent-guides
  :defer t
  :config
  (setq highlight-indent-guides-method 'character))

(use-package ace-window
  :defer t
  :config
  (setq aw-dispatch-always t))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-startup-banner "~/Pictures/berserker.png")
  (setq dashboard-banner-logo-title "")
  (setq dashboard-items '((projects . 5)
						  (agenda . 5)
						  (bookmarks . 5)))
  (setq dashboard-footer-messages '(""))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t))


(use-package avy
  :defer t)

(use-package undo-tree
  :init
  (global-undo-tree-mode 1)
  :config
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/tmp/undo-tree/"))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-want-C-o-jump t)
  (setq evil-want-respect-visual-line-mode nil)
  (setq evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  (evil-global-set-key 'motion "j" 'evil-next-line)
  (evil-global-set-key 'motion "k" 'evil-previous-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :init
  :config
  (evil-collection-init)
  :hook 'dired-mode lambda ()
    (evil-collection-define-key 'normal 'dired-mode-map
      (kbd "SPC") nil))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))


(use-package evil-commentary
  :after evil
  :init
  (evil-commentary-mode))

(use-package magit
  :defer t
  :config
  (setq magit-display-buffer-function
	(lambda (buffer)
	  (display-buffer buffer '(display-buffer-same-window))))
  (setq magit-commit-show-diff nil)
  (with-eval-after-load 'magit-status
	(define-key magit-status-mode-map (kbd "SPC") nil)))

(defun kz/enable-venv-from-pyrightconfig ()
  (interactive)
  (if (file-exists-p (concat (projectile-project-root) "pyrightconfig.json"))
      (when (cdr (assoc 'venv (json-read-file (concat (projectile-project-root) "pyrightconfig.json"))))
		 (pyvenv-workon (cdr (assoc 'venv (json-read-file (concat (projectile-project-root) "pyrightconfig.json"))))))
    (pyvenv-deactivate)))

(defun kz/projectile-switch-project-action ()
  (persp-switch (projectile-project-name))
  (when (vc-root-dir) (magit-status))
  (kz/enable-venv-from-pyrightconfig)
  (projectile-find-file))

(defun kz/open-emacs-config ()
  (interactive)
  (persp-switch "main")
  (find-file "~/.emacs.d/init.el"))

(defun kz/evil-surround-word ()
  (interactive)
  (execute-kbd-macro (concat "viwS" (char-to-string (read-char)))))

(defun kz/search-project ()
  (interactive)
  (counsel-git-grep))

(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer kz/leader-define-key
    :states '(normal visual emacs)
    :prefix "SPC")

  (kz/leader-define-key
    "`" 'mode-line-other-buffer
    "/"  'kz/search-project
    "SPC" 'projectile-find-file
    "a" 'avy-goto-word-0
    "bB" 'switch-to-buffer
    "bb" 'persp-counsel-switch-buffer
    "bd" 'kill-current-buffer
    "br" 'revert-buffer
    "cf" 'kz/format
    "dS" 'kz/docker-project-stop-container
    "dr" 'kz/docker-project-restart-container
    "ds" 'kz/docker-project-start-container
    "df" 'kz/docker-find-file
    "daS" 'kz/docker-stop-container
    "dar" 'kz/docker-restart-container
    "das" 'kz/docker-start-container
    "dd" 'docker
    "dc" 'docker-compose
    "fD" 'kz/delete-visiting-file
    "fR" 'kz/rename-visiting-file
    "ff" 'counsel-find-file
    "fp" 'kz/open-emacs-config
    "fs" 'save-buffer
    "fF" 'kz/sudo-find-file
    "gB" 'magit-blame-addition
    "gdf" 'kz/magit-diff-file
    "gff" 'magit-find-file
    "gg" 'magit-status
    "hf" 'describe-function
    "hk" 'describe-key
    "hv" 'describe-variable
    "pa" 'projectile-add-known-project
    "pb" 'counsel-projectile-switch-to-buffer
    "pd" 'projectile-dired
    "pf" 'projectile-find-file
    "pF" 'projectile-find-file-other-window
    "pi" 'projectile-invalidate-cache
    "pp" 'projectile-switch-project
    "wd" 'evil-window-delete
    "wh" 'evil-window-left
    "wj" 'evil-window-down
    "wk" 'evil-window-up
    "wl" 'evil-window-right
    "ws" 'split-window-below
    "wv" 'split-window-right
    "wS" 'kz/split-window-below-all
    "wV" 'kz/split-window-right-all
    "wp" 'winner-undo
    "wn" 'winner-redo
    "ww" 'ace-window)

  (general-create-definer kz/persp-define-key
    :states '(normal)
    :prefix "SPC TAB")

  (kz/persp-define-key
    "TAB" `persp-switch-last
    "`" `persp-switch
    "d" 'persp-kill
    "n" 'persp-next
    "p" 'persp-prev
    "R" 'persp-rename
    "S" 'persp-switch-to-scratch-buffer
    "1" (lambda () (interactive) (persp-switch-by-number 1))
    "2" (lambda () (interactive) (persp-switch-by-number 2))
    "3" (lambda () (interactive) (persp-switch-by-number 3))
    "4" (lambda () (interactive) (persp-switch-by-number 4))
    "5" (lambda () (interactive) (persp-switch-by-number 5))
    "6" (lambda () (interactive) (persp-switch-by-number 6))
    "7" (lambda () (interactive) (persp-switch-by-number 7))
    "8" (lambda () (interactive) (persp-switch-by-number 8))
    "9" (lambda () (interactive) (persp-switch-by-number 9))
    "0" (lambda () (interactive) (persp-switch-by-number 0)))

  (general-imap "j"
	(general-key-dispatch 'self-insert-command
	  "k" 'evil-normal-state))

  (general-define-key
   :keymaps 'evil-normal-state-map
   "\"" 'kz/evil-surround-word)

  (general-create-definer kz/lsp-mode-define-key
    :states '(normal)
    :keymaps 'lsp-mode-map
    :prefix "SPC c")

  (kz/lsp-mode-define-key
    "r" 'lsp-rename
    "d" 'lsp-find-definition
    "R" 'lsp-find-references)

  (general-create-definer kz/python-mode-define-key
    :states '(normal)
    :keymaps 'python-mode-map
    :prefix "SPC c")

  (kz/python-mode-define-key
    "tt" 'python-pytest-run-def-or-class-at-point
    "tf" 'python-pytest-file
    "ta" 'python-pytest))

(use-package which-key
  :init
  (which-key-mode)
  :config
  (setq which-key-idle-delay 0.0)
  (setq which-key-idle-secondary-delay 0.05))

(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay 0)
  (company-minimum-prefix-length 2)
  (global-company-mode 1)
  (company-dabbrev-downcase 0)
  (company-async-wait 0.01)
  (company-async-timeout 1)
  (company-tooltip-limit 5))

(use-package company-box
  :after company
  :hook (company-mode . company-box-mode)
  :config
  (setq company-backends '((company-capf company-files company-yasnippet))))

(use-package lsp-mode
  :defer t
  :hook ((python-mode go-mode lua-mode rust-mode) . lsp)
  :commands lsp
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]tests\\'"))

(use-package lsp-ui
  :defer t
  :hook (lsp-mode . lsp-ui-mode))

(use-package lua-mode
  :config
  (setq lua-indent-level 4))

(use-package go-mode
  :config
  (fset 'godef-jump 'lsp-find-definition))

(use-package clojure-mode)
(use-package cider
  :ensure t
  :pin melpa-stable)
(use-package inf-clojure)

(use-package vue-mode
  :config
  (setq js-indent-level 2))

(use-package dockerfile-mode)

(use-package typescript-mode)

(use-package rust-mode)

(use-package restclient)

(use-package elpy
  :defer t)

(use-package python-black
  :defer t
  :demand t)

(use-package pyvenv
  :defer t
  :hook (python-mode . pyvenv-mode))

(use-package python-pytest)

(defun kz/python-settings ()
  (python-black-on-save-mode-enable-dwim))

(add-hook 'python-mode-hook 'kz/python-settings)

(defun kz/go-settings ()
  (yas-minor-mode)
  (setq gofmt-command "gofmt")
  (add-hook 'before-save-hook 'gofmt-before-save)
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet")))

(defun kz/rust-settings ()
  (yas-minor-mode))

(add-hook 'go-mode-hook 'kz/go-settings)
(add-hook 'rust-mode-hook 'kz/rust-settings)

(use-package doom-snippets
  :load-path "~/.emacs.d/snippets"
  :after yasnippet)

(use-package flycheck
  :defer t
  :hook (lsp-mode . flycheck-mode))

(use-package diff-hl
  :defer t
  :hook (prog-mode . diff-hl-mode))

(use-package json-mode
  :defer t)
(use-package yaml-mode
  :defer t)
 
(use-package org
  :defer t
  :init 
  (require 'ob-python)
  :hook (org-mode lambda ()
				  (display-line-numbers-mode 0)
                  (org-indent-mode 1)
				  (hl-line-mode 0)
                  (flyspell-mode))

  :bind ("C-c l" . 'org-store-link)
  :bind ("C-c h" . 'org-insert-heading)
  :bind ("C-c s" . 'org-insert-subheading)
  :bind ("C-c a" . 'org-agenda)
  :bind (:map org-mode-map
         ("C-c j d" . kz/org-deadline-persian)
         ("C-c j s" . kz/org-schedule-persian))
  :config
  (setq org-agenda-format-date #'kz/org-agenda-format-date-persian)
  (setq org-directory "~/Org/")
  (setq org-ellipsis " ▼")
  (setq org-startup-folded 'showall)
  (setq org-hide-block-startup t)
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-start-with-log-mode t)
  (setq org-edit-src-content-indentation 0)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN_PROGRESS(p)" "REPEAT(r)" "|" "DONE(d)" "CANCELED(c)")))
  (setq org-tag-alist '(("PERSONAL" . ?p) ("CODING" . ?c) ("PROJECTS" . ?h) ("EDUCATIONAL" . ?u)
                        ("ENTERTAINMENT" . ?e) ("BOOKS" . ?b) ("MOVIES" . ?m) ("COURSES" . ?r) ("SKILLS" . ?s)))
  (setq org-html-validation-link nil))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/org/roam/")
  (org-roam-completion-everywhere t)
  (org-roam-db-autosync-mode 1)
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "%<%I:%M %p>: %?"
      :if-new (file+head "%(kz/persian-date-string \"-\").org" "#+title: %(kz/persian-date-string \"-\")\n"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i" . completion-at-point)))

(use-package org-roam-dailies
  :ensure nil
  :after org-roam
  :config
  (define-key global-map (kbd "C-c n d") org-roam-dailies-map)
  (define-key org-roam-dailies-map (kbd "c") #'kz/org-roam-dailies-goto-persian-date)
  (define-key org-roam-dailies-map (kbd "v") #'kz/org-roam-dailies-capture-persian-date)
  (advice-add 'org-roam-dailies-calendar--file-to-date
              :override #'kz/org-roam-dailies--file-to-gregorian-date))

(use-package org-roam-ui
    :after org-roam
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(use-package org-bullets
  :defer t
  :hook (org-mode . org-bullets-mode))

(use-package valign
  :defer t
  :hook (org-mode . valign-mode))

(use-package latex-preview-pane
  :defer t)

(use-package ispell
  :config
  (let ((entry (assoc "en_US,fa_IR" ispell-dictionary-alist)))
    (unless (and entry (> (length entry) 2))
      (ispell-set-spellchecker-params)
      (ispell-hunspell-add-multi-dic "en_US,fa_IR"))))

(defun kz/prose-mode ()
  (interactive)
  (visual-line-mode 1)
  (setq visual-fill-column-width 80
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1)
  (setq-local word-wrap t)
  (buffer-face-set 'kz/prose-face)
  (setq-local ispell-local-dictionary "en_US,fa_IR")
  (when (bound-and-true-p flyspell-mode)
    (flyspell-buffer))
  (evil-local-set-key 'motion "j" 'evil-next-visual-line)
  (evil-local-set-key 'motion "k" 'evil-previous-visual-line))

(use-package visual-fill-column
  :hook
  (org-mode . kz/prose-mode)
  (markdown-mode . kz/prose-mode))
  
(use-package tree-sitter
  :defer t
  :hook (prog-mode lambda ()
                     (require 'tree-sitter-langs)
                     (tree-sitter-mode 1)
                     (tree-sitter-hl-mode 1)))

(use-package pdf-tools
  :defer t
  :init
  (pdf-tools-install))

(use-package simple-httpd)
(use-package htmlize)

(use-package smartparens
  :init
  (require 'smartparens-config)
  :config
  (smartparens-global-mode 1))

(use-package perspective
  :defer t
  :init
  (persp-mode t)
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :config
  (setq persp-sort 'oldest))

(use-package docker
  :ensure t)

(use-package hledger-mode)

(require 'reformatter)
(reformatter-define lua-format
  :program "lua-format"
  :args (kz/lua-format--make-args)
  :lighter " LuaFMT")
(defun kz/lua-format--make-args ()
    (let ((format-file (concat (projectile-project-root) ".lua-format")))
      (if (file-exists-p format-file) '(concat "-i --config=" format-file)
        '("-i"))))

(defun kz/format()
  (interactive)
  (when (eq major-mode 'python-mode)
    (if (eq evil-state 'visual)
        (python-black-region evil-visual-beginning evil-visual-end)
      (python-black-buffer)))
  (when (eq major-mode 'lua-mode) (lua-format-buffer))
  (when (eq major-mode 'go-mode) (gofmt)))

(defun kz/magit-diff-file ()
  (interactive)
  (let ((current (current-buffer))
        (other (magit-find-file-other-window (completing-read "from revision: " (magit-list-refnames)) (buffer-file-name))))
    (ediff-buffers current other)))

(defun kz/find-file-in-new-window-layout ()
  (interactive)
  (progn
    (projectile-find-file)
    (delete-other-windows)))


(defun kz/sudo-find-file ()
  (interactive)
  (find-file (read-file-name "Sudo find file: " "/sudo::")))

(defun kz/uuid4 ()
  (interactive)
  (insert (uuid-string)))
