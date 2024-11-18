(defun kz/prompt-confirmed-p (msg)
  (eq (read-char (format "%s %s" msg "(y)es, (n)o")) ?y))

(defun kz/delete-visiting-file ()
  (interactive)
  (when (kz/prompt-confirmed-p "Delete this file?")
    (let ((file-name (buffer-file-name)))
    (progn (delete-file file-name)
           (set-buffer-modified-p nil)
           (kill-this-buffer)
           (message (concat "Deleted: " file-name))))))

(defun kz/rename-visiting-file ()
  (interactive)
  (let ((new-file-name (read-file-name ".")))
    (progn
      (rename-file (buffer-file-name) new-file-name)
      (when (buffer-modified-p) (save-buffer))
      (kill-this-buffer)
      (find-file new-file-name)
      (message (concat "Renamed to: " new-file-name)))))

(defun kz/split-window-below-all (arg)
  "Split window below from the parent or from root with ARG."
  (interactive "P")
  (split-window (if arg (frame-root-window)
                  (window-parent (selected-window)))
                nil 'below nil))

(defun kz/split-window-right-all (arg)
  "Split window right from the parent or from root with ARG."
  (interactive "P")
  (split-window (if arg (frame-root-window)
                  (window-parent (selected-window)))
                nil 'right nil))

(defun kz/get-line-content (line-no)
  (let* ((beg (progn (goto-line line-no) (point)))
         (end (progn (end-of-line) (point))))
    (buffer-substring beg end)))
