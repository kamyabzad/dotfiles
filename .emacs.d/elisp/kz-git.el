;;; -*- lexical-binding: t -*-
(defun kz/magit-diff-file ()
  (interactive)
  (let ((current (current-buffer))
        (other (magit-find-file-other-window (completing-read "from revision: " (magit-list-refnames)) (buffer-file-name))))
    (ediff-buffers current other)))

