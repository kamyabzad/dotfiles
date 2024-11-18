(defcustom persp-sort-reverse-p t
  "Whether sort should be in reverse"
  :group 'perspective-mode
  :type 'boolean)

(defun persp-number (name)
  (+ 1 (cl-position name (persp-names))))

(defun persp-format-name (name)
  "Override to include number in modeline string"
  (let ((string-name (format "%s-%s" (persp-number name) name)))
    (if (equal name (persp-current-name))
        (propertize string-name 'face 'persp-selected-face)
      (cond ((eq persp-show-modestring 'header)
             (propertize string-name
                         'local-map persp-header-line-map
                         'mouse-face 'header-line-highlight))
            ((eq persp-show-modestring t)
             (propertize string-name
                         'local-map persp-mode-line-map
                         'mouse-face 'mode-line-highlight))))))

(defun persp-names-default-sort ()
  "Return a list of the names of all perspectives on the `selected-frame'.

If `persp-sort' is 'name (the default), then return them sorted
alphabetically. If `persp-sort' is 'access, then return them
sorted by the last time the perspective was switched to, the
current perspective being the first. If `persp-sort' is 'created,
then return them in the order they were created, with the newest
first."
  (let ((persps (hash-table-values (perspectives-hash))))
    (cond ((eq persp-sort 'name)
           (sort (mapcar 'persp-name persps) 'string<))
          ((eq persp-sort 'access)
           (mapcar 'persp-name
                   (sort persps (lambda (a b)
                                  (time-less-p (persp-last-switch-time b)
                                               (persp-last-switch-time a))))))
          ((eq persp-sort 'created)
           (mapcar 'persp-name
                   (sort persps (lambda (a b)
                                  (time-less-p (persp-created-time b)
                                               (persp-created-time a)))))))))

(defun persp-names ()
  (if persp-sort-reverse-p (reverse (persp-names-default-sort))
    (persp-names-default-sort)))

(defun kz/filter-persp-buffers (buf)
  (string-match-p
   "^[^*]\\|\\*scratch\\*"
   (buffer-name buf)))


(defun persp--switch-buffer-ivy-counsel-helper (arg fallback)
  (unless (featurep 'ivy)
    (user-error "Ivy not loaded"))
  (declare-function ivy-read "ivy.el")
  (if (and persp-mode (null arg))
      (let ((real-ivy-read (symbol-function 'ivy-read))
            (current-bufs
             (seq-filter #'kz/filter-persp-buffers (persp-current-buffers* t))))
        (cl-letf (((symbol-function 'ivy-read)
                   (lambda (&rest args)
                     (apply real-ivy-read
                            (append args
                                    (list :predicate
                                          (lambda (b)
                                            (memq (cdr b) current-bufs))))))))
          (funcall fallback)))
    (funcall fallback)))
