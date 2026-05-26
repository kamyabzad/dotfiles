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
  
