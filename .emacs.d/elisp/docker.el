(require 'docker)

(defvar kz/docker-container-prefix "")

(defun kz/docker-container-entries(&rest filters)
  (if (and filters (car filters))
      (aio-wait-for
       (docker-container-entries
        (mapconcat (lambda (f) (format "-f %s" f)) filters " "))))
  (aio-wait-for (docker-container-entries "--all")))

(defun kz/docker-project-container-entries(&rest filters)
  (mapcar
   (lambda (e) (substring (car e) (length kz/docker-container-prefix)))
   (seq-filter
    (lambda (e) (string-prefix-p kz/docker-container-prefix (car e)))
    (kz/docker-container-entries))))

(defun kz/docker-run-command (command container)
  docker-run-docker-async command container)

(defun kz/docker-project-run-command (command container)
  (docker-run-docker-async command (concat kz/docker-container-prefix container)))

(defun kz/docker-restart-container ()
  (interactive)
  (let ((container (completing-read "Restart container: " (kz/docker-container-entries))))
    (kz/docker-run-command "restart" container)))

(defun kz/docker-project-restart-container ()
  (interactive)
  (let ((container (completing-read "Restart container: " (kz/docker-project-container-entries))))
    (kz/docker-project-run-command "restart" container)))

(defun kz/docker-stop-container ()
  (interactive)
  (let ((container (completing-read "Stop container: " (kz/docker-container-entries "status=running"))))
    (kz/docker-run-command "stop" container)))

(defun kz/docker-project-stop-container ()
  (interactive)
  (let ((container (completing-read "Stop container: " (kz/docker-project-container-entries "status=running"))))
    (kz/docker-project-run-command "stop" container)))

(defun kz/docker-start-container ()
  (interactive)
  (let ((container (completing-read "Start container: " (kz/docker-container-entries "status=created" "status=exited"))))
    (kz/docker-run-command "start" container)))

(defun kz/docker-project-start-container ()
  (interactive)
  (let ((container (completing-read "Start container: " (kz/docker-project-container-entries "status=created" "status=exited"))))
    (kz/docker-project-run-command "start" container)))


(defun kz/docker-find-file ()
  (interactive)
  (let ((container (completing-read "Select container: " (kz/docker-container-entries "status=running"))))
    (counsel-find-file (concat "/docker:root@" container ":/"))))
