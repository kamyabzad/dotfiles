;;; -*- lexical-binding: t -*-
(require 'calendar)
(require 'cal-persia)

(defun kz/persian-date-string (separator)
  "Return the current org-capture date as a Persian (Jalali) YYYY-MM-DD string, joined by SEPARATOR."
  (let* ((time (or (ignore-errors (org-capture-get :default-time)) (current-time)))
         (decoded (decode-time time))
         (pdate (calendar-persian-from-absolute
                 (calendar-absolute-from-gregorian
                  (list (nth 4 decoded) (nth 3 decoded) (nth 5 decoded))))))
    (format "%04d%s%02d%s%02d" (nth 2 pdate) separator (nth 0 pdate) separator (nth 1 pdate))))

(defun kz/persian-date-to-time (year month day)
  "Return the Emacs time value for the Persian (Jalali) YEAR-MONTH-DAY."
  (let ((greg (calendar-gregorian-from-absolute
               (calendar-persian-to-absolute (list month day year)))))
    (encode-time 0 0 0 (nth 1 greg) (nth 0 greg) (nth 2 greg))))

(defun kz/read-persian-date ()
  "Prompt for a Persian (Jalali) date as YYYY-MM-DD and return its Emacs time value."
  (let ((parts (mapcar #'string-to-number
                        (split-string (read-string "Persian date (YYYY-MM-DD): ") "-"))))
    (apply #'kz/persian-date-to-time parts)))

(defun kz/org-roam-dailies--file-to-gregorian-date (file)
  "Convert a Persian-dated daily-note FILE to a Gregorian (MONTH DAY YEAR) date."
  (when-let* ((base (file-name-sans-extension (file-name-nondirectory file)))
              (parts (ignore-errors (mapcar #'string-to-number (split-string base "-"))))
              (year (nth 0 parts)) (month (nth 1 parts)) (day (nth 2 parts)))
    (calendar-gregorian-from-absolute (calendar-persian-to-absolute (list month day year)))))

(defun kz/org-agenda-format-date-persian (date)
  "Format Gregorian calendar DATE as a Persian (Jalali) date for the agenda header."
  (let* ((dayname (calendar-day-name date))
         (pdate (calendar-persian-from-absolute (calendar-absolute-from-gregorian date)))
         (month (aref calendar-persian-month-name-array (1- (nth 0 pdate)))))
    (format "%-10s %2d %s %4d" dayname (nth 1 pdate) month (nth 2 pdate))))

(defun kz/org-timestamp-to-persian-string (ts)
  "Return the Persian (Jalali) YYYY-MM-DD equivalent of Org timestamp string TS, bracketed."
  (let* ((time (org-time-string-to-time ts))
         (decoded (decode-time time))
         (pdate (calendar-persian-from-absolute
                 (calendar-absolute-from-gregorian
                  (list (nth 4 decoded) (nth 3 decoded) (nth 5 decoded))))))
    (format "[%04d-%02d-%02d]" (nth 2 pdate) (nth 0 pdate) (nth 1 pdate))))

(defun kz/org-append-persian-date (what)
  "Append the Persian (Jalali) equivalent next to the just-inserted WHAT timestamp.
WHAT is `deadline' or `scheduled'."
  (ignore-errors
    (when (bound-and-true-p org-last-inserted-timestamp)
      (let ((keyword (if (eq what 'deadline) org-deadline-string org-scheduled-string))
            (ts org-last-inserted-timestamp))
        (save-excursion
          (org-back-to-heading t)
          (when (re-search-forward (concat (regexp-quote keyword) " " (regexp-quote ts))
                                    (line-end-position 2) t)
            (when (looking-at " \\[[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\]")
              (replace-match ""))
            (insert " " (kz/org-timestamp-to-persian-string ts))))))))

(defun kz/org-append-persian-date-after-planning (what &rest _)
  "Advise `org-add-planning-info' to append the Persian date after DEADLINE/SCHEDULED."
  (when (memq what '(deadline scheduled))
    (kz/org-append-persian-date what)))

(advice-add 'org-add-planning-info :after #'kz/org-append-persian-date-after-planning)

(defun kz/org-remove-persian-date-before-removal (keyword)
  "Remove any bracketed Persian date following KEYWORD's timestamp, before KEYWORD itself is removed."
  (ignore-errors
    (save-excursion
      (org-back-to-heading t)
      (let ((end (save-excursion (outline-next-heading) (point))))
        (when (re-search-forward
               (concat "\\<" (regexp-quote keyword)
                       " +<[^>\n]+>\\( \\[[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\]\\)")
               end t)
          (replace-match "" nil nil nil 1))))))

(advice-add 'org-remove-timestamp-with-keyword :before #'kz/org-remove-persian-date-before-removal)
