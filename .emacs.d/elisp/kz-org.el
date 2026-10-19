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

(add-hook 'window-setup-hook #'kz/open-org-project-on-startup)
