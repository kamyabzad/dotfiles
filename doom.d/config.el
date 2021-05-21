;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Kamyab Taghizadeh"
      user-mail-address "kamyab.zad@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font "Vazir Code 16"
      doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-horizon)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq lsp-file-watch-threshold 5000)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; set black formatter
(use-package! python-black
  :demand t
  :after python)

;; Feel free to throw your own personal keybindings here
(map! :leader :desc "Blacken Buffer" "m b b" #'python-black-buffer)
(map! :leader :desc "Blacken Region" "m b r" #'python-black-region)
(map! :leader :desc "Blacken Statement" "m b s" #'python-black-statement)

(map! :leader
      (:prefix-map ("a" . "Avy navigation")
      :desc "go to char" "a" #'avy-goto-char
      :desc "go to char 2" "c" #'avy-goto-char-2
      :desc "go to char n" "t" #'avy-goto-char-timer
      :desc "go to line" "l" #'avy-goto-line
      :desc "go to word 1" "w" #'avy-goto-word-1
      :desc "go to word 1" "e" #'avy-goto-word-0))

;; (map! :leader
;;       (:prefix-map ("y" . "folding")
;;       :desc "go to parent" "p" #'yafolding-go-parent-element
;;       :desc "hide parent element" "h" #'yafolding-hide-parent-element
;;       :desc "show element" "o" #'yafolding-show-element
;;       :desc "hide element" "c" #'yafolding-hide-element
;;       :desc "toggle element" "t" #'yafolding-toggle-element))

(setq highlight-indent-guides-method `bitmap)

(add-hook 'prog-mode-hook 'turn-on-diff-hl-mode)

;; vim incremet/decrement
(define-key evil-insert-state-map (kbd "C-j") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
(define-key evil-visual-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-z") 'evil-numbers/dec-at-pt)
(define-key evil-visual-state-map (kbd "C-z") 'evil-numbers/dec-at-pt)

;; vim-surrond config
(setq-default evil-surround-pairs-alist
  '((?\( . ("(" . ")"))
    (?\[ . ("[" . "]"))
    (?\{ . ("{" . "}"))

    (?\) . ("(" . ")"))
    (?\] . ("[" . "]"))
    (?\} . ("{" . "}"))

    (?# . ("#{" . "}"))
    (?b . ("(" . ")"))
    (?B . ("{" . "}"))
    (?> . ("<" . ">"))
    (?t . evil-surround-read-tag)
    (?< . evil-surround-read-tag)
    (?f . evil-surround-function)))

;; Org-mode config
(use-package org
  :hook (org-mode . org-bullets-mode)
  :hook (org-mode lambda () (display-line-numbers-mode 0) (hl-line-mode 0))
  :config
  (setq org-ellipsis " ▼")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-files '("~/Org/Tasks")))

(use-package visual-fill-column
  :defer
  :hook (org-mode lambda ()
                  (setq visual-fill-column-width 100
                        visual-fill-column-center-text t)
                  (visual-fill-column-mode 1)
                  ))



;; Company config
(use-package company
  :config
  (setq company-backends '(company-files company-capf company-yasnippet company-keywords))
  (setq company-dabbrev-downcase 0)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-async-wait 0.01)
  (setq company-async-timeout 1))


;; lsp-mode config
(setq lsp-file-watch-threshold 2000)

(modify-syntax-entry ?_ "w")
