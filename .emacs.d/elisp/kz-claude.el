;;; -*- lexical-binding: t -*-
(defvar kz/claude-program "claude")
(defvar kz/claude-extra-args '("--permission-mode" "acceptEdits"
                               "--allowedTools" "Read" "Edit" "Grep" "Glob"))

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



(defun kz/claude--shell-name ()
  (when (string-match "\\`\\*.+-claude-\\(.+\\)\\*\\'" (buffer-name))
    (match-string 1 (buffer-name))))

(defun kz/claude--capture-name ()
  (when-let ((name (kz/claude--shell-name)))
    `((kz-claude-name . ,name))))

(defun kz/claude--unique-buffer-name (project name)
  (let ((candidate (format "*%s-claude-%s*" project name))
        (n 2))
    (while (get-buffer candidate)
      (setq candidate (format "*%s-claude-%s-%d*" project name n)
            n (1+ n)))
    candidate))

(defun kz/claude--resume-with-project-name (orig session-id &rest args)
  (let* ((name (or (agent-recall-metadata-get session-id 'kz-claude-name)
                   "main"))
         (agent-shell-buffer-name-format
          (lambda (_agent _project)
            (kz/claude--unique-buffer-name (projectile-project-name) name))))
    (apply orig session-id args)))

(with-eval-after-load 'agent-recall
  (add-hook 'agent-recall-capture-functions #'kz/claude--capture-name)
  (advice-add 'agent-recall--start-resume :around
              #'kz/claude--resume-with-project-name))


(defun kz/send-to-project-claude ()
  "Like `agent-shell-send-region-to', but only offer shells in the current project."
  (interactive)
  (require 'agent-shell)
  (let ((buffers (agent-shell-project-buffers)))
    (unless buffers
      (user-error "No agent shell for this project"))
    (cl-letf (((symbol-function 'agent-shell-buffers) (lambda () buffers)))
      (agent-shell-send-region-to))))


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


