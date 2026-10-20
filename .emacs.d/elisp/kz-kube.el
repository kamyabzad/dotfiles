;;; -*- lexical-binding: t -*-
(defun kz/set-kube-config()
  (interactive)
  (setenv "KUBECONFIG" (read-file-name "prompt: " "/home/kamyab/.kube/")))

(defun kz/project-kubit ()
  "Open kubit with the kubeconfig bound to the current project.
Fall back to plain `kubit' outside a bound project or with a prefix argument."
  (interactive)
  (let* ((root (projectile-project-root))
         (kubeconfig (and root
                          (cdr (seq-find (lambda (e) (file-equal-p (car e) root))
                                         kz/kubit-kubeconfigs)))))
    (if (and kubeconfig (not current-prefix-arg))
        (kubit nil kubeconfig)
      (call-interactively #'kubit))))

