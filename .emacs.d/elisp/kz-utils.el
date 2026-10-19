;;; -*- lexical-binding: t -*-
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

(defun kz/paste-clipboard-file ()
  "Copy the file(s) referenced by the clipboard into `default-directory'.
Reads the `text/uri-list' clipboard target set by file managers, falling
back to the clipboard text when it names an existing file.  Files are
always copied, never moved, even when they were cut."
  (interactive)
  (require 'dnd)
  (let* ((uri-list (ignore-errors (gui-get-selection 'CLIPBOARD 'text/uri-list)))
         (files (or (delq nil
                          (mapcar (lambda (uri)
                                    (unless (string-prefix-p "#" uri)
                                      (dnd-get-local-file-name uri t)))
                                  (split-string (or uri-list "") "[\r\n]+" t "[ \t]+")))
                    (let ((text (string-trim (or (ignore-errors
                                                   (gui-get-selection 'CLIPBOARD 'STRING))
                                                 ""))))
                      (when (and (not (string-empty-p text)) (file-exists-p text))
                        (list text))))))
    (unless files (user-error "No file in clipboard"))
    (dolist (file files)
      (if (file-directory-p file)
          (copy-directory file default-directory t t nil)
        (copy-file file default-directory 1)))
    (message "Pasted %d file(s) into %s"
             (length files) (abbreviate-file-name default-directory))))

(defun kz/open-emacs-config ()
  (interactive)
  (persp-switch "main")
  (find-file "~/.emacs.d/init.el"))

(defun kz/sudo-find-file ()
  (interactive)
  (find-file (read-file-name "Sudo find file: " "/sudo::")))

(defun kz/evil-surround-word ()
  (interactive)
  (execute-kbd-macro (concat "viwS" (char-to-string (read-char)))))

(defun kz/uuid4 ()
  (interactive)
  (require 'org-id)
  (insert (org-id-uuid)))
