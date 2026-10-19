;;; -*- lexical-binding: t -*-
(defface kz/prose-face '((t))
  "Face used in `kz/prose-mode' buffers.")

(defun kz/setup-fonts (&optional frame)
  (when (display-graphic-p frame)
    (set-face-attribute 'default nil :font "Fantasque Sans Mono" :height 150)
    (set-fontset-font
     "fontset-default"
     (cons (decode-char 'ucs #x0600) (decode-char 'ucs #x06ff))
     "IRANSansX")
    (unless (query-fontset "fontset-prose")
      (create-fontset-from-fontset-spec "-*-*-*-*-*--*-*-*-*-*-*-fontset-prose"))
    (set-fontset-font "fontset-prose" '(#x600 . #x6ff) "IRANSansX")
    (set-face-attribute 'kz/prose-face nil :fontset "fontset-prose")))

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
