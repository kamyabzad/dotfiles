;;; -*- lexical-binding: t -*-
(defun kz/urls-to-xspf-playlist (urls output-file)
  "Generate a VLC XSPF playlist from URLS and write to OUTPUT-FILE.
Interactively, reads URLs from the active region (one per line)."
  (interactive
   (let* ((raw (if (use-region-p)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (read-string "Enter URLs (one per line):\n")))
          (urls (cl-remove-if #'string-empty-p
                              (mapcar #'string-trim (split-string raw "\n"))))
          (file (read-file-name "Save playlist as: " nil nil nil "playlist.xspf")))
     (list urls file)))
  (cl-flet ((xml-encode (url)
               ;; normalize to raw & first, then encode to &amp;
               (replace-regexp-in-string
                "&" "&amp;"
                (replace-regexp-in-string "&amp;" "&" url) t t)))
    (let* ((tracks (cl-loop for url in urls
                            for id from 0
                            concat (format "
		<track>
			<location>%s</location>
			<extension application=\"http://www.videolan.org/vlc/playlist/0\">
				<vlc:id>%d</vlc:id>
				<vlc:option>network-caching=1000</vlc:option>
			</extension>
		</track>" (xml-encode url) id)))
           (items (cl-loop for id from 0 below (length urls)
                           concat (format "\n\t\t<vlc:item tid=\"%d\"/>" id)))
           (xml (format "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<playlist xmlns=\"http://xspf.org/ns/0/\" xmlns:vlc=\"http://www.videolan.org/vlc/playlist/ns/0/\" version=\"1\">
	<title>Playlist</title>
	<trackList>%s
	</trackList>
	<extension application=\"http://www.videolan.org/vlc/playlist/0\">%s
	</extension>
</playlist>\n" tracks items)))
      (with-temp-file output-file
        (insert xml))
      (message "Playlist saved to %s (%d tracks)" output-file (length urls)))))
