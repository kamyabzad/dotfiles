;;; -*- lexical-binding: t -*-
(require 'reformatter)

(defun kz/lua-format--make-args ()
  (let ((format-file (concat (projectile-project-root) ".lua-format")))
    (if (file-exists-p format-file)
        (list "-i" (concat "--config=" format-file))
      '("-i"))))

(reformatter-define lua-format
  :program "lua-format"
  :args (kz/lua-format--make-args)
  :lighter " LuaFMT")

(defun kz/format()
  (interactive)
  (when (eq major-mode 'python-mode)
    (if (eq evil-state 'visual)
        (python-black-region evil-visual-beginning evil-visual-end)
      (python-black-buffer)))
  (when (eq major-mode 'lua-mode) (lua-format-buffer))
  (when (eq major-mode 'go-mode) (gofmt)))
