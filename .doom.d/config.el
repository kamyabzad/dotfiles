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
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font "JetBrains Mono 28"
      doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


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


;; font for arabic characters
(set-fontset-font
 "fontset-default"
 (cons (decode-char 'ucs #x0600) (decode-char 'ucs #x06ff)) ; arabic
 "Vazir Code")

;; make underlines a part of 'word'
(modify-syntax-entry ?_ "w")

;; prefer vertical split
(setq split-width-threshold nil)

;; dired config
(put 'dired-find-alternate-file 'disabled nil)
(defun kz/alternate-dired-up-directory ()
  (interactive)
  (find-alternate-file ".."))
(after! evil-collection
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'kz/alternate-dired-up-directory
    "L" 'dired-find-alternate-file))


;; Org-mode config
(after! org
  (setq org-ellipsis " ▼")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-tags-column -80)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN_PROGRESS(p)" "REPEAT(r)" "|" "DONE(d)" "CANCELED(c)")))
  (setq org-tag-alist '(("PERSONAL" . ?p) ("CODING" . ?c) ("PROJECTS" . ?h) ("EDUCATIONAL" . ?u)
                        ("ENTERTAINMENT" . ?e) ("BOOKS" . ?b) ("MOVIES" . ?m) ("COURSES" . ?r) ("SKILLS" . ?s) ("WORK" . ?w))))

(use-package org-roam
  :init
  (setq org-roam-v2-ack t))

(after! projectile
  (setq projectile-project-search-path '("~/Projects")))

(defun kz/org-mode ()
  (display-line-numbers-mode 0)
  (visual-fill-column-mode 1)
  (hl-line-mode 0)
  (org-bullets-mode 1)
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t))

(add-hook! 'org-mode-hook 'kz/org-mode)

;; lsp config
(setq lsp-ui-doc-show-with-cursor t)
(setq lsp-ui-doc-show-with-mouse t)
(setq lsp-ui-doc-delay 0.5)

(after! dictionary
  (setq dictionary-tooltip-dictionary "wikt-en-all"))

(after! marginalia
  (setq marginalia-align 'right))

(after! company
  (setq company-dabbrev-downcase 0)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-async-wait 0.01)
  (setq company-async-timeout 1)
  (setq company-tooltip-limit 5))

(after! persp-mode
  (setq persp-add-buffer-on-after-change-major-mode-filter-functions nil))

(after! docker
  (setq docker-container-columns '((:name "Id" :width 16 :template "{{json .ID}}" :sort nil :format nil)
                                   (:name "Names" :width 30 :template "{{json .Names}}" :sort nil :format nil)
                                   (:name "Image" :width 30 :template "{{json .Image}}" :sort nil :format nil)
                                   (:name "Status" :width 20 :template "{{json .Status}}" :sort nil :format
                                    (lambda
                                      (x)
                                      (propertize x 'font-lock-face
                                                  (docker-container-status-face x))))
                                   (:name "Ports" :width 20 :template "{{json .Ports}}" :sort nil :format nil)
                                   (:name "Created" :width 23 :template "{{json .CreatedAt}}" :sort nil :format
                                    (lambda
                                      (x)
                                      (format-time-string "%F %T"
                                                          (date-to-time x))))
                                   (:name "Status" :width 20 :template "{{json .Status}}" :sort nil :format
                                    (lambda
                                      (x)
                                      (propertize x 'font-lock-face
                                                  (docker-container-status-face x)))))))


(after! dap-mode
  (require 'dap-python))

(defun kz/python-mode ()
  (tree-sitter-mode 1)
  (tree-sitter-hl-mode 1)
  (python-black-on-save-mode-enable-dwim))

(add-hook! 'python-mode-hook 'kz/python-mode)
(add-hook! 'projectile-before-switch-project-hook 'enable-venv-from-pyright)
(add-hook! 'shell-mode-hook '(lambda () (company-mode -1)))
(add-hook! 'eshell-mode-hook '(lambda () (company-mode -1)))
(add-hook! 'typescript-mode '(lambda () (setq tab-width 2)))
(add-hook! 'lsp-lua-language-server-after-open-hook '(lambda () (-> (lsp-workspaces) (cl-first)
                                                                    (lsp--workspace-server-capabilities)
                                                                    (lsp:server-capabilities-completion-provider?)
                                                                    (lsp:set-completion-options-trigger-characters? ["." ":" "(" "'" "\"" "[" "," "#" "*" "@" "|" "=" "-" "{" " "]))))


;; general keymaps
(define-key evil-normal-state-map (kbd "C-a") 'move-beginning-of-line)
(define-key evil-visual-state-map (kbd "C-a") 'move-beginning-of-line)
(define-key evil-motion-state-map (kbd "C-a") 'move-beginning-of-line)
(define-key evil-normal-state-map (kbd "C-e") 'move-end-of-line)
(define-key evil-visual-state-map (kbd "C-e") 'move-end-of-line)
(define-key evil-motion-state-map (kbd "C-e") 'move-end-of-line)
(define-key evil-normal-state-map (kbd "C-M-d") 'down-list)
(define-key evil-visual-state-map (kbd "C-M-d") 'down-list)

(defun evil-go-to-norm-exec ()
  (interactive)
  (evil-ex "'<,'>norm "))
(defun evil-surround-word ()
  (interactive)
  (execute-kbd-macro (concat "viwS" (char-to-string (read-char)))))

;; (define-key evil-visual-state-map (kbd "C-o") 'evil-go-to-norm-exec)
(define-key evil-normal-state-map (kbd "\"")  'evil-surround-word)

;; Avy keymaps
(map! :leader
      :desc "Avy go to word" "a" #'avy-goto-word-0)

(map! :leader
      (:prefix-map ("d" . "Debug")
       :desc "Open dap-hydra" "h" #'dap-hydra
       :desc "Run dap-debug" "d" #'dap-debug-custom
       :desc "Toggle breakpoint" "b" #'dap-breakpoint-toggle
       :desc "Delete all breakpoints" "D" #'dap-breakpoint-delete-all
       :desc "Quit debugging" "q" #'dap-disconnect))

(map! :leader
      (:prefix-map ("o d" . "Dockerdock")
      :desc "Start container" "s" #'dockerdock-start
      :desc "Stop container" "S" #'dockerdock-stop
      :desc "Restart container" "r" #'dockerdock-restart
      :desc "Pause container" "p" #'dockerdock-pause
      :desc "Unpause container" "P" #'dockerdock-unpause
      :desc "Kill container" "k" #'dockerdock-kill))

;; calc
(define-key global-map (kbd "C-x c") #'calc)

(defun dap-debug-django () (interactive)
       (if (file-exists-p (concat (projectile-project-root) "src/manage.py"))
           (dap-debug (list :type "python"
                            :args '("runserver" "--noreload")
                            :cwd (projectile-project-root)
                            :console "integratedTerminal"
                            :program (concat (projectile-project-root) "src/manage.py")
                            :request "launch"
                            :name "Django debug"
                            :debugOptions ["DebugStdLib" "ShowReturnValue" "RedirectOutput"]
                            :django t))
         (command-execute 'dap-debug)))

(defun dap-debug-test () (interactive)
       (if (file-exists-p (concat (projectile-project-root) "src/manage.py"))
           (dap-debug (list :type "python"
                            :args '("test" "tests.test_admin_global_preference.GlobalPreferenceTestCase.test_update_waap")
                            :cwd (projectile-project-root)
                            :console "integratedTerminal"
                            :program (concat (projectile-project-root) "src/manage.py")
                            :request "launch"
                            :name "Django debug"
                            :debugOptions ["DebugStdLib" "ShowReturnValue" "RedirectOutput"]
                            :django t))
         (command-execute 'dap-debug)))

(defun enable-venv-from-pyright ()
  (if (file-exists-p (concat (projectile-project-root) "pyrightconfig.json"))
      (when (cdr (assoc 'venv (json-read-file (concat (projectile-project-root) "pyrightconfig.json"))))
        (pyvenv-workon (cdr (assoc 'venv (json-read-file (concat (projectile-project-root) "pyrightconfig.json"))))))
    (pyvenv-deactivate)))

;; load local packagews
(load! "lisp/py-absolufy-imports.el")
(load! "lisp/dockerdock.el")
