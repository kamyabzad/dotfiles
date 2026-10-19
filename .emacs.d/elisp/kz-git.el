;;; -*- lexical-binding: t -*-
(defun kz/magit-diff-file ()
  (interactive)
  (let ((current (current-buffer))
        (other (magit-find-file-other-window (completing-read "from revision: " (magit-list-refnames)) (buffer-file-name))))
    (ediff-buffers current other)))

(defun kz/get-commit-msg-suggestion-from-claude ()
  (interactive)
  (insert (string-trim-right (shell-command-to-string (concat
                                                       "claude -p 'suggest a good commit message for git diff of: "
                                                       (vc-root-dir)
                                                       "(your output should only be the git commit)'")))))
