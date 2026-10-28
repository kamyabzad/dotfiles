(defun kz/sudo-find-file ()
  (interactive)
  (find-file (read-file-name "Sudo find file: " "/sudo::")))

(defun kz/sudo-open-hosts ()
  (interactive)
  (find-file "/sudo::/etc/hosts"))

(defun kz/find-file-in (dir)
  (counsel-find-file nil dir))

(defun kz/find-file-in-project-root ()
  (interactive)
  (kz/find-file-in (or (ignore-errors (projectile-project-root)) default-directory)))

(defun kz/find-file-in-home ()
  (interactive)
  (kz/find-file-in "~/"))

(defun kz/find-file-in-root ()
  (interactive)
  (kz/find-file-in "/"))
