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

(defun kz/get-line-content (line-no)
  (let* ((beg (progn (goto-line line-no) (point)))
         (end (progn (end-of-line) (point))))
    (buffer-substring beg end)))

(defun kz/shell-split (str)
  "Split STR as shell words, respecting single/double quotes and backslash escapes."
  (let ((result '())
        (current "")
        (in-single nil)
        (in-double nil)
        (i 0)
        (len (length str)))
    (while (< i len)
      (let ((c (aref str i)))
        (cond
         (in-single
          (if (= c ?')
              (setq in-single nil)
            (setq current (concat current (char-to-string c)))))
         (in-double
          (cond
           ((= c ?\") (setq in-double nil))
           ((= c ?\\)
            (setq i (1+ i))
            (when (< i len)
              (setq current (concat current (char-to-string (aref str i))))))
           (t (setq current (concat current (char-to-string c))))))
         ((= c ?') (setq in-single t))
         ((= c ?\") (setq in-double t))
         ((= c ?\\)
          (setq i (1+ i))
          (when (< i len)
            (setq current (concat current (char-to-string (aref str i))))))
         ((memq c '(?\  ?\t ?\n ?\r))
          (unless (string= current "")
            (push current result)
            (setq current "")))
         (t (setq current (concat current (char-to-string c))))))
      (setq i (1+ i)))
    (unless (string= current "")
      (push current result))
    (nreverse result)))

(defun kz/curl-to-restclient (start end)
  "Convert the curl command in region to restclient.el format, replacing it."
  (interactive "r")
  (let* ((curl-str (buffer-substring-no-properties start end))
         (normalized (replace-regexp-in-string "\\\\\n[ \t]*" " " curl-str))
         (tokens (kz/shell-split (string-trim normalized)))
         (args (if (string= (downcase (car tokens)) "curl") (cdr tokens) tokens))
         (flags-with-values '("-X" "--request"
                              "-H" "--header"
                              "-d" "--data" "--data-raw" "--data-binary" "--data-urlencode"
                              "-u" "--user"
                              "-o" "--output"
                              "-A" "--user-agent"
                              "--url"
                              "-e" "--referer"
                              "--proxy" "-x"
                              "--connect-timeout" "--max-time" "-m"
                              "-F" "--form"
                              "--cert" "--key" "--cacert"
                              "-b" "--cookie" "-c" "--cookie-jar"
                              "--resolve"))
         (method "GET")
         (url nil)
         (headers '())
         (body nil))
    (let ((i 0))
      (while (< i (length args))
        (let ((arg (nth i args)))
          (cond
           ((or (string= arg "-X") (string= arg "--request"))
            (setq method (upcase (nth (1+ i) args)))
            (setq i (+ i 2)))
           ((or (string= arg "-H") (string= arg "--header"))
            (push (nth (1+ i) args) headers)
            (setq i (+ i 2)))
           ((member arg '("-d" "--data" "--data-raw" "--data-binary" "--data-urlencode"))
            (setq body (nth (1+ i) args))
            (when (string= method "GET") (setq method "POST"))
            (setq i (+ i 2)))
           ((string= arg "--url")
            (setq url (nth (1+ i) args))
            (setq i (+ i 2)))
           ((or (string= arg "-u") (string= arg "--user"))
            (push (concat "Authorization: Basic "
                          (base64-encode-string (nth (1+ i) args) t))
                  headers)
            (setq i (+ i 2)))
           ((or (string= arg "-I") (string= arg "--head"))
            (setq method "HEAD")
            (setq i (1+ i)))
           ((member arg flags-with-values)
            (setq i (+ i 2)))
           ((string-match "\\`--[^=]+=" arg)
            (setq i (1+ i)))
           ((and (not (string-prefix-p "-" arg))
                 (or (string-prefix-p "http://" arg)
                     (string-prefix-p "https://" arg)))
            (setq url arg)
            (setq i (1+ i)))
           (t (setq i (1+ i)))))))
    (unless url (user-error "No URL found in curl command"))
    (let* ((result (concat method " " url
                           (when headers
                             (concat "\n" (mapconcat #'identity (reverse headers) "\n")))
                           (when body (concat "\n\n" body)))))
      (delete-region start end)
      (insert result))))

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
