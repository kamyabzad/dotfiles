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
         (prompt (format "File: %s\nInstruction (it was written at line %d, right above the code it refers to; the instruction itself has already been removed from the file):\n%s\n\nApply the instruction or answer the question. If it was a change, only make the requested change."
                         file line instruction)))
    (when (string-empty-p (string-trim instruction))
      (user-error "Empty instruction"))
    (when block
      (delete-region (nth 0 block) (min (point-max) (1+ (nth 1 block)))))
    (save-buffer)
    (auto-revert-mode 1)
    (require 'agent-shell)
    (let ((agent-shell-session-strategy 'new)
          (agent-shell-display-action '(display-buffer-pop-up-window)))
      (agent-shell-insert
       :text prompt
       :submit t
       :shell-buffer (agent-shell-start
                      :config (agent-shell-anthropic-make-claude-code-config))))
    (message "Claude is working on: %s" instruction)))


(defun kz/claude-new-shell (name)
  "Create a new agent shell in the current project context.
The buffer is named *{project}-claude-NAME*."
  (interactive "sName: ")
  (require 'agent-shell)
  (let* ((project (projectile-project-name))
         (buffer-name (format "*%s-claude-%s*" project name))
         (default-directory (or (ignore-errors (projectile-project-root))
                                default-directory))
         (agent-shell-session-strategy 'new)
         (agent-shell-buffer-name-format (lambda (_agent _project) buffer-name)))
    (agent-shell-start
     :config (agent-shell-anthropic-make-claude-code-config))))



(defun kz/claude-comment-send ()
  "Send the comment at point to an existing Claude shell for the project.
Like `kz/claude-comment', but instead of creating a new shell, pick an
existing *{project}-claude-{name}* buffer via `completing-read' (as in
`kz/claude-switch')."
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
         (project (projectile-project-name))
         (regex (format "\\`\\*%s-claude-\\(.*\\)\\*\\'" (regexp-quote project)))
         (matches (cl-loop for buf in (buffer-list)
                           for bname = (buffer-name buf)
                           when (string-match regex bname)
                           collect (cons (match-string 1 bname) buf)))
         (buffer (cond
                  ((null matches)
                   (user-error "No Claude shell for project %s" project))
                  ((= 1 (length matches))
                   (cdar matches))
                  (t
                   (cdr (assoc (completing-read "Claude shell: "
                                                (mapcar #'car matches) nil t)
                               matches)))))
         (prompt (format "File: %s\nInstruction (it was written at line %d, right above the code it refers to; the instruction itself has already been removed from the file):\n%s\n\nApply the instruction or answer the question. If it was a change, only make the requested change."
                         file line instruction)))
    (when (string-empty-p (string-trim instruction))
      (user-error "Empty instruction"))
    (when block
      (delete-region (nth 0 block) (min (point-max) (1+ (nth 1 block)))))
    (save-buffer)
    (auto-revert-mode 1)
    (require 'agent-shell)
    (agent-shell-insert
     :text prompt
     :submit t
     :shell-buffer buffer)
    (display-buffer buffer)
    (message "Claude is working on: %s" instruction)))


(defun kz/claude-switch ()
  "Switch to a Claude shell for the current project.
Looks for buffers named *{project}-claude-{name}*.  If none exist,
create {project}-claude-main.  If one exists, switch to it.  If
multiple exist, prompt with completing-read on just the {name} part."
  (interactive)
  (let* ((project (projectile-project-name))
         (prefix (format "*%s-claude-" project))
         (regex (format "\\`\\*%s-claude-\\(.*\\)\\*\\'" (regexp-quote project)))
         (matches (cl-loop for buf in (buffer-list)
                           for bname = (buffer-name buf)
                           when (string-match regex bname)
                           collect (cons (match-string 1 bname) buf))))
    (cond
     ((null matches)
      (kz/claude-new-shell "main"))
     ((= 1 (length matches))
      (switch-to-buffer (cdar matches)))
     (t
      (let ((choice (completing-read "Claude shell: " (mapcar #'car matches) nil t)))
        (switch-to-buffer (cdr (assoc choice matches))))))))


(defun kz/get-commit-msg-suggestion-from-claude ()
  (interactive)
  (insert (string-trim-right (shell-command-to-string (concat
                                                       "claude -p 'suggest a good commit message for git diff of: "
                                                       (vc-root-dir)
                                                       "(your output should only be the git commit)'")))))


