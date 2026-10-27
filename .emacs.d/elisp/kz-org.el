;;; -*- lexical-binding: t -*-
(defvar kz/trusted-startup-org-files-list '()
  "Trusted org files for running their startup block")

(add-hook 'org-mode-hook
          (lambda() 
          (let ((starting-point (point)))
          (when (and
                 (buffer-file-name)
                 (member buffer-file-name kz/trusted-startup-org-files-list))
            (unless
              (org-babel-goto-named-src-block "startup")
              (progn
                (org-babel-execute-src-block)
                (goto-char (starting-point))))))))
  

(defun kz/open-org-project-on-startup ()
  (when (get-buffer dashboard-buffer-name)
    (with-current-buffer dashboard-buffer-name
      (setq default-directory (expand-file-name "~/org/")))))

(defun kz/org-insert-src-block (lang)
  (interactive "sLanguage: ")
  (if (use-region-p)
      (let ((beg (region-beginning))
            (end (copy-marker (region-end))))
        (goto-char beg)
        (beginning-of-line)
        (insert (format "#+begin_src %s\n" lang))
        (goto-char end)
        (unless (bolp) (insert "\n"))
        (insert "#+end_src\n")
        (set-marker end nil))
    (unless (bolp) (insert "\n"))
    (insert (format "#+begin_src %s\n\n#+end_src\n" lang))
    (forward-line -2)))


(add-hook 'window-setup-hook #'kz/open-org-project-on-startup)
