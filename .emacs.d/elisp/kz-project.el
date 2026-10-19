;;; -*- lexical-binding: t -*-
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

(defun kz/search-project ()
  (interactive)
  (counsel-git-grep))
