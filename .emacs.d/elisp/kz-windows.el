(defvar kz/winner-buffer-confs nil)
(defvar kz/winner-buffer-index 0)

(defun kz/winner-confs-with-buffer (buf)
  (let ((ring (winner-ring (selected-frame)))
        (seen (list (winner-win-data))))
    (cl-loop for i below (ring-length ring)
             for conf = (ring-ref ring i)
             when (and (rassq buf (cdr conf))
                       (not (member (cdr conf) seen)))
             do (push (cdr conf) seen)
             and collect conf)))

(defun kz/winner-cycle-buffer-layouts ()
  "Cycle through past winner layouts that include the current buffer."
  (interactive)
  (let ((buf (current-buffer)))
    (unless (eq last-command this-command)
      (setq kz/winner-buffer-confs
            (append (kz/winner-confs-with-buffer buf) (list (winner-conf)))
            kz/winner-buffer-index 0))
    (if (null (cdr kz/winner-buffer-confs))
        (message "No other layouts with %s" (buffer-name buf))
      (setq winner-point-alist (winner-make-point-alist))
      (winner-set (nth kz/winner-buffer-index kz/winner-buffer-confs))
      (when-let ((win (get-buffer-window buf)))
        (select-window win))
      (setq kz/winner-buffer-index
            (mod (1+ kz/winner-buffer-index) (length kz/winner-buffer-confs)))
      (message "Layout %d / %d"
               (if (zerop kz/winner-buffer-index)
                   (length kz/winner-buffer-confs)
                 kz/winner-buffer-index)
               (length kz/winner-buffer-confs)))))
