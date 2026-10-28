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
(setq scroll-conservatively 101
      scroll-margin 0
      scroll-preserve-screen-position t
      auto-window-vscroll nil)
(pixel-scroll-precision-mode 1)
(setq use-short-answers t)
(setq confirm-nonexistent-file-or-buffer nil)
(setq delete-by-moving-to-trash t)
(advice-add 'risky-local-variable-p :override #'ignore)
(winner-mode)

(add-hook 'prog-mode-hook
          (lambda ()
            (display-line-numbers-mode 1)
            (toggle-truncate-lines 1)))

;; Get rid of annoying backup/autosave/lock files
(setq create-lockfiles nil)
(setq temporary-file-directory "~/.emacs.d/tmp/")
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq custom-file "~/.emacs-custom.el")
(load custom-file)
(let ((dir (expand-file-name "~/.local/bin")))
  (add-to-list 'exec-path dir)
  (setenv "PATH" (concat dir path-separator (getenv "PATH"))))

(setq line-spacing 3)
(modify-syntax-entry ?_ "w")

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

(defun kz/split-window-sensibly-right (&optional window)
  (let ((window (or window (selected-window))))
    (or (and (window-splittable-p window t)
             (with-selected-window window (split-window-right)))
        (and (window-splittable-p window)
             (with-selected-window window (split-window-below)))
        (and (eq window (frame-root-window (window-frame window)))
             (not (window-minibuffer-p window))
             (let ((split-width-threshold 0))
               (when (window-splittable-p window t)
                 (with-selected-window window (split-window-right))))))))

(setq split-window-preferred-function #'kz/split-window-sensibly-right)

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

(dolist (file (directory-files "~/.emacs.d/elisp/" t "\\.el$"))
  (load-file file))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'kz/setup-fonts)
  (kz/setup-fonts))

(use-package persian-calendar
  :ensure nil
  :load-path "~/Projects/Emacs/persian-calendar.el/"
  :after calendar
  :demand t
  :commands (persian-calendar-mode)
  :custom
  (persian-calendar-auto-enable 1)
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal calendar-mode-map
      "P" #'persian-calendar-mode
      "p" #'kz/calendar-gregorian-print-date)))

(use-package dash)

(use-package swiper)

(use-package projectile
  :demand t
  :config (projectile-mode)
  :init
  (setq projectile-switch-project-action #'kz/projectile-switch-project-action)
  (setq projectile-git-submodule-command "true"))

(use-package counsel
  :demand t
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
  (load-theme 'doom-gruvbox)
  (custom-set-faces
   '(font-lock-keyword-face       ((t (:weight bold))))
   '(font-lock-function-name-face ((t (:weight bold))))
   '(font-lock-type-face          ((t (:weight semi-bold))))
   '(font-lock-builtin-face       ((t (:weight semi-bold))))
   '(font-lock-comment-face       ((t (:slant italic))))
   '(font-lock-function-call-face  ((t (:weight normal))))
   '(font-lock-property-use-face   ((t (:slant italic))))
   '(font-lock-property-name-face  ((t (:slant italic))))))

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

(use-package kirigami
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal 'global
      "zo" #'kirigami-open-fold
      "zO" #'kirigami-open-fold-rec
      "zc" #'kirigami-close-fold
      "za" #'kirigami-toggle-fold
      "zr" #'kirigami-open-folds
      "zm" #'kirigami-close-folds)))

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
  (evil-define-motion kz/evil-visual-left (count)
    :type exclusive
    (if (eq (current-bidi-paragraph-direction) 'right-to-left)
        (evil-forward-char count)
      (evil-backward-char count)))
  (evil-define-motion kz/evil-visual-right (count)
    :type exclusive
    (if (eq (current-bidi-paragraph-direction) 'right-to-left)
        (evil-backward-char count)
      (evil-forward-char count)))
  (evil-global-set-key 'motion "h" 'kz/evil-visual-left)
  (evil-global-set-key 'motion "l" 'kz/evil-visual-right)
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

(use-package reverse-im
  :demand t
  :custom
  (reverse-im-input-methods '("farsi-isiri-9147"))
  :config
  (reverse-im-mode t))

(use-package magit
  :defer t
  :config
  (setq magit-display-buffer-function
	(lambda (buffer)
	  (display-buffer buffer '(display-buffer-same-window))))
  (setq magit-commit-show-diff nil)
  (with-eval-after-load 'magit-status
	(define-key magit-status-mode-map (kbd "SPC") nil)))

(use-package general
  :config
  (general-evil-setup t)

  (general-create-definer kz/leader-define-key
    :states '(normal visual)
    :prefix "SPC")

  (kz/leader-define-key
    "`" 'mode-line-other-buffer
    "/"  'kz/search-project
    "SPC" 'projectile-find-file
    "u" 'universal-argument
    "a" 'avy-goto-word-0
    "bB" 'switch-to-buffer
    "bb" 'persp-counsel-switch-buffer
    "bd" 'kill-current-buffer
    "br" 'revert-buffer
    "cc" 'kz/claude-comment
    "cp" 'kz/claude-switch
    "cP" 'agent-shell-switch-buffer
    "cs" 'kz/send-to-project-claude
    "cn" 'kz/claude-new-shell
    "cf" 'kz/format
    "cr" 'agent-recall-resume
    "ct" 'agent-shell-open-transcript
    "dS" 'kz/docker-project-stop-container
    "dr" 'kz/docker-project-restart-container
    "ds" 'kz/docker-project-start-container
    "df" 'kz/docker-find-file
    "daS" 'kz/docker-stop-container
    "dar" 'kz/docker-restart-container
    "das" 'kz/docker-start-container
    "dd" 'dockerdock
    "dk" 'kz/project-kubit
    "dc" 'docker-compose
    "fD" 'kz/delete-visiting-file
    "fR" 'kz/rename-visiting-file
    "ff" 'counsel-find-file
    "fF" 'kz/sudo-find-file
    "fH" 'kz/sudo-open-hosts
    "fih" 'kz/find-file-in-home
    "fi/" 'kz/find-file-in-root
    "fip" 'kz/find-file-in-project-root
    "fp" 'kz/open-emacs-config
    "fs" 'save-buffer
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
    "wb" 'kz/winner-cycle-buffer-layouts
    "wx" 'kz/winner-delete-layout
    "ww" 'ace-window
    "ni" 'org-roam-node-insert
    "nf" 'org-roam-node-find
    "nu" 'org-roam-ui-open
    "nd" 'org-roam-dailies-map)

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
    :keymaps '(python-mode-map python-ts-mode-map)
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
  :hook ((python-base-mode go-ts-mode lua-mode lua-ts-mode rust-mode rust-ts-mode) . lsp)
  :commands lsp
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]tests\\'"))

(use-package lsp-ui
  :defer t
  :hook (lsp-mode . lsp-ui-mode))

(use-package lua-mode
  :config
  (setq lua-indent-level 4)
  (setq lua-ts-indent-offset 4))

(use-package go-ts-mode
  :preface
  (defun kz/go-settings ()
    (yas-minor-mode)
    (setq-local indent-tabs-mode t)
    (setq-local go-ts-mode-indent-offset tab-width)
    (setq gofmt-command "gofmt")
    (add-hook 'before-save-hook 'gofmt-before-save)
    (if (not (string-match "go" compile-command))
        (set (make-local-variable 'compile-command)
             "go build -v && go test -v && go vet")))
  :hook (go-ts-mode . kz/go-settings)
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

(use-package rust-mode
  :hook ((rust-mode rust-ts-mode) . yas-minor-mode))

(use-package restclient
  :mode ("\\.http\\'" . restclient-mode)
  :bind (:map restclient-mode-map
              ("C-c C-u" . kz/restclient-copy-curl-command)
              ("C-c C-e" . kz/restclient-set-env)))

(use-package markdown-ts-mode
  :mode ("\\.md\\'" . markdown-ts-mode))

(use-package markdown-ts-appear
  :vc (:url "https://github.com/Thysrael/markdown-ts-appear" :rev :newest)
  :hook (markdown-ts-mode . markdown-ts-appear-mode))

(use-package elpy
  :defer t)

(use-package python-black
  :defer t
  :demand t
  :hook (python-base-mode . python-black-on-save-mode-enable-dwim))

(use-package pyvenv
  :defer t
  :hook (python-base-mode . pyvenv-mode))

(use-package python-pytest)

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
				  (hl-line-mode 0)
                  (flyspell-mode))

  :bind ("C-c l" . 'org-store-link)
  :bind ("C-c h" . 'org-insert-heading)
  :bind ("C-c s" . 'org-insert-subheading)
  :bind ("C-c a" . 'org-agenda)
  :bind (:map org-mode-map ("C-c b" . kz/org-insert-src-block))
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

(use-package visual-fill-column
  :hook
  (org-mode . kz/prose-mode)
  (markdown-ts-mode . kz/prose-mode))
  
(use-package treesit
  :ensure nil
  :init
  (add-to-list 'treesit-major-mode-remap-alist '(json-mode . json-ts-mode))
  (setopt treesit-auto-install-grammar 'always
          treesit-font-lock-level 4
          treesit-enabled-modes t))

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
  (persp-initial-frame-name "org")
  :config
  (setq persp-sort 'oldest)

  (defun persp-number (name)
    (+ 1 (cl-position name (persp-names))))

  (defun persp-format-name (name)
    "Override to include number in modeline string"
    (let ((string-name (propertize (format "%s-%s" (persp-number name) name)
                                   'kz/persp-name name)))
      (if (equal name (persp-current-name))
          (propertize string-name 'face 'persp-selected-face)
        (cond ((eq persp-show-modestring 'header)
               (propertize string-name
                           'local-map persp-header-line-map
                           'mouse-face 'header-line-highlight))
              ((eq persp-show-modestring t)
               (propertize string-name
                           'local-map persp-mode-line-map
                           'mouse-face 'mode-line-highlight))))))

  (defun persp-mode-line-click (event)
    (interactive "e")
    (let* ((posn (posn-string (event-start event)))
           (name (and posn (get-text-property (cdr posn) 'kz/persp-name (car posn)))))
      (when name
        (persp-switch name)
        (persp-update-modestring))))

  (defun kz/filter-persp-buffers (buf)
    (string-match-p
     "^[^*]\\|\\*scratch\\*"
     (buffer-name buf)))


  (defun persp--switch-buffer-ivy-counsel-helper (arg fallback)
    (unless (featurep 'ivy)
      (user-error "Ivy not loaded"))
    (declare-function ivy-read "ivy.el")
    (if (and persp-mode (null arg))
        (let ((real-ivy-read (symbol-function 'ivy-read))
              (current-bufs
               (seq-filter #'kz/filter-persp-buffers (persp-current-buffers* t))))
          (cl-letf (((symbol-function 'ivy-read)
                     (lambda (&rest args)
                       (apply real-ivy-read
                              (append args
                                      (list :predicate
                                            (lambda (b)
                                              (memq (cdr b) current-bufs))))))))
            (funcall fallback)))
      (funcall fallback))))

(use-package docker
  :ensure t)

(use-package kubed)

(use-package kubit
  :ensure nil
  :load-path "~/Projects/Emacs/kubit/"
  :commands (kubit)
  :config
  (advice-add 'kubit :after (lambda (&rest _) (delete-other-windows))))

(use-package dockerdock
  :ensure nil
  :load-path "~/Projects/Emacs/dockerdock.el/"
  :commands (dockerdock))

(use-package hledger-mode
  :mode ("\\.journal\\'" . hledger-mode))

(use-package agent-shell
  :ensure t
  :hook (agent-shell-mode . agent-recall-track-sessions)
  :custom
  (agent-shell-anthropic-default-model-id "claude-opus-5-5"))

(use-package agent-recall
  :ensure nil
  :load-path "~/Projects/Emacs/agent-recall/"
  :config
  (setq agent-recall-search-paths '("~/Projects")))
