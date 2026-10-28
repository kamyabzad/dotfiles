;;; -*- lexical-binding: t -*-
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

(defun kz/shell-single-quote (str)
  (if (string-match-p "\\`[A-Za-z0-9_@%+=:,./-]+\\'" str)
      str
    (concat "'" (replace-regexp-in-string "'" "'\\''" str t t) "'")))

(defun kz/restclient-copy-curl-command ()
  "Copy the restclient request at point as a readable curl command."
  (interactive)
  (require 'restclient)
  (restclient-http-parse-current-and-do
   (lambda (method url headers entity)
     (let ((parts (append
                   (list (concat "curl"
                                 (unless (string= method "GET")
                                   (concat " -X " method))
                                 " " (kz/shell-single-quote url)))
                   (mapcar (lambda (header)
                             (concat "-H " (kz/shell-single-quote
                                            (format "%s: %s" (car header) (cdr header)))))
                           (reverse headers))
                   (when (> (length (string-trim entity)) 0)
                     (list (concat "--data-raw " (kz/shell-single-quote (string-trim entity))))))))
       (kill-new (mapconcat #'identity parts " \\\n  "))
       (message "curl command copied to clipboard.")))))

(defun kz/restclient-apply-env (vars)
  (let ((env (cdr (assoc ":env" vars))))
    (if (or (null env) (string-empty-p (string-trim env)))
        vars
      (let ((prefix (concat ":" (string-trim env) "_"))
            (aliases nil))
        (dolist (var vars)
          (when (string-prefix-p prefix (car var))
            (push (cons (concat ":" (substring (car var) (length prefix))) (cdr var))
                  aliases)))
        (append (nreverse aliases) vars)))))

(with-eval-after-load 'restclient
  (advice-add 'restclient-find-vars-before-point :filter-return #'kz/restclient-apply-env))

(defun kz/restclient-envs ()
  (let ((pairs nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^:\\([^_:= \t\n]+\\)_\\([^:= \t\n]+\\)[ \t]*:?=" nil t)
        (push (cons (match-string-no-properties 1) (match-string-no-properties 2)) pairs)))
    (setq pairs (nreverse pairs))
    (delete-dups
     (delq nil (mapcar (lambda (pair)
                         (when (seq-some (lambda (other)
                                           (and (equal (cdr other) (cdr pair))
                                                (not (equal (car other) (car pair)))))
                                         pairs)
                           (car pair)))
                       pairs)))))

(defun kz/restclient-set-env (env)
  "Set the restclient :env override to ENV. Empty input clears the override."
  (interactive
   (list (completing-read
          (format "Env (current: %s): "
                  (or (cdr (assoc ":env" restclient-var-overrides)) "file"))
          (kz/restclient-envs))))
  (if (string-empty-p env)
      (progn (restclient-remove-var ":env")
             (message "restclient env override cleared"))
    (restclient-set-var ":env" env)
    (message "restclient env: %s" env)))
