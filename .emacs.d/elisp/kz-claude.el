;;; -*- lexical-binding: t -*-
(defvar kz/claude-program "claude")
(defvar kz/claude-extra-args '("--permission-mode" "acceptEdits"
                               "--allowedTools" "Read" "Edit" "Grep" "Glob"))

(defun kz/claude--comment-line-text ()
  (save-excursion
    (beginning-of-line)
    (when (and comment-start-skip
               (looking-at (concat "[ \t]*\\(?:" comment-start-skip "\\)")))
      (let ((text (buffer-substring-no-properties (match-end 0) (line-end-position))))
        (when (and comment-end-skip (not (string-empty-p comment-end)))
          (setq text (replace-regexp-in-string (concat "\\(?:" comment-end-skip "\\)\\'") "" text)))
        (string-trim text)))))

(defun kz/claude--comment-block ()
  (comment-normalize-vars)
  (when (kz/claude--comment-line-text)
    (let ((start (line-beginning-position))
          (end (line-end-position)))
      (save-excursion
        (while (and (zerop (forward-line -1)) (kz/claude--comment-line-text))
          (setq start (line-beginning-position))))
      (save-excursion
        (while (and (zerop (forward-line 1)) (not (eobp)) (kz/claude--comment-line-text))
          (setq end (line-end-position))))
      (let ((lines '()))
        (save-excursion
          (goto-char start)
          (while (progn (push (kz/claude--comment-line-text) lines)
                        (and (zerop (forward-line 1)) (bolp) (<= (point) end)))))
        (list start end (string-join (nreverse lines) "\n"))))))

(defun kz/claude--open-vterm (name args)
  (require 'vterm)
  (let ((vterm-shell (mapconcat #'shell-quote-argument (cons kz/claude-program args) " "))
        (buffer (generate-new-buffer name)))
    (select-window
     (display-buffer buffer
                     '((display-buffer-reuse-window display-buffer-in-direction)
                       (direction . right))))
    (with-current-buffer buffer
      (vterm-mode))
    buffer))

(defun kz/claude-comment ()
  "Send the comment at point to Claude as an instruction for this file.
The comment block is removed before Claude edits the file.  When point
is not on a comment, read the instruction from the minibuffer."
  (interactive)
  (unless buffer-file-name (user-error "Buffer is not visiting a file"))
  (let* ((block (kz/claude--comment-block))
         (instruction (if block
                          (nth 2 block)
                        (read-string "Claude: ")))
         (file buffer-file-name)
         (line (if block
                   (line-number-at-pos (nth 0 block))
                 (line-number-at-pos)))
         (default-directory (or (ignore-errors (projectile-project-root))
                                default-directory))
         (prompt (format "File: %s\nInstruction (it was written at line %d, right above the code it refers to; the instruction itself has already been removed from the file):\n%s\n\nApply the instruction by editing the file. Only make the requested change."
                         file line instruction)))
    (when (string-empty-p (string-trim instruction))
      (user-error "Empty instruction"))
    (when block
      (delete-region (nth 0 block) (min (point-max) (1+ (nth 1 block)))))
    (save-buffer)
    (auto-revert-mode 1)
    (kz/claude--open-vterm (format "*claude: %s*" (file-name-nondirectory file))
                           (cons prompt kz/claude-extra-args))
    (message "Claude is working on: %s" instruction)))


(defun kz/get-commit-msg-suggestion-from-claude ()
  (interactive)
  (insert (string-trim-right (shell-command-to-string (concat
                                                       "claude -p 'suggest a good commit message for git diff of: "
                                                       (vc-root-dir)
                                                       "(your output should only be the git commit)'")))))
