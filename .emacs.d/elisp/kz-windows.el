;;; -*- lexical-binding: t -*-
(defvar kz/winner-buffer-confs nil)
(defvar kz/winner-buffer-index 0)

(defun kz/winner-normalize (data)
  (let ((lefts (sort (delete-dups (mapcar #'caar data)) #'<))
        (tops (sort (delete-dups (mapcar #'cadar data)) #'<)))
    (mapcar (lambda (entry)
              (list (cl-position (caar entry) lefts)
                    (cl-position (cadar entry) tops)
                    (cdr entry)))
            data)))

(defun kz/winner-confs-with-buffer (buf)
  (let ((ring (winner-ring (selected-frame)))
        (seen (list (kz/winner-normalize (winner-win-data)))))
    (cl-loop for i below (ring-length ring)
             for conf = (ring-ref ring i)
             for data = (kz/winner-normalize (cdr conf))
             when (and (rassq buf (cdr conf))
                       (not (member data seen)))
             do (push data seen)
             and collect conf)))

(defun kz/winner-switch-to (conf buf)
  (setq winner-point-alist (winner-make-point-alist))
  (winner-set conf)
  (when-let* ((win (get-buffer-window buf)))
    (select-window win)))

(defun kz/winner-cycle-buffer-layouts ()
  "Cycle through past winner layouts that include the current buffer."
  (interactive)
  (condition-case err
      (let ((buf (current-buffer)))
        (unless (eq last-command this-command)
          (setq kz/winner-buffer-confs
                (append (kz/winner-confs-with-buffer buf) (list (winner-conf)))
                kz/winner-buffer-index 0))
        (if (null (cdr kz/winner-buffer-confs))
            (message "No other layouts with %s" (buffer-name buf))
          (kz/winner-switch-to (nth kz/winner-buffer-index kz/winner-buffer-confs) buf)
          (setq kz/winner-buffer-index
                (mod (1+ kz/winner-buffer-index) (length kz/winner-buffer-confs)))
          (message "Layout %d / %d"
                   (if (zerop kz/winner-buffer-index)
                       (length kz/winner-buffer-confs)
                     kz/winner-buffer-index)
                   (length kz/winner-buffer-confs))))
    (error (message "%s" (error-message-string err)))))

(defun kz/winner-delete-layout ()
  "Delete the current layout from winner history and switch to another one."
  (interactive)
  (condition-case err
      (let* ((buf (current-buffer))
             (ring (winner-ring (selected-frame)))
             (data (kz/winner-normalize (winner-win-data)))
             (next (or (car (kz/winner-confs-with-buffer buf))
                       (cl-loop for i below (ring-length ring)
                                for conf = (ring-ref ring i)
                                unless (equal (kz/winner-normalize (cdr conf)) data)
                                return conf))))
        (when next
          (kz/winner-switch-to next buf))
        (let ((removed (cl-loop for i from (1- (ring-length ring)) downto 0
                                when (equal (kz/winner-normalize (cdr (ring-ref ring i))) data)
                                do (ring-remove ring i)
                                and count t)))
          (setq winner-modified-list (delq (selected-frame) winner-modified-list)
                kz/winner-buffer-confs nil)
          (winner-remember)
          (message "Deleted layout (%d entr%s)%s"
                   removed (if (= removed 1) "y" "ies")
                   (if next "" ", no other layout to switch to"))))
    (error (message "%s" (error-message-string err)))))
