;;; -*- lexical-binding: t -*-
(defun kz/set-kube-config()
  (interactive)
  (setenv "KUBECONFIG" (read-file-name "prompt: " "/home/kamyab/.kube/")))
