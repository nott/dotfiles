(require 'mu4e)

(setq
 mu4e-get-mail-command "true"   ;; or fetchmail, or ...
 mu4e-update-interval 300)             ;; update every 5 minutes

(setq
 mu4e-maildir       "~/.mail/nottcc"   ;; top-level Maildir
 mu4e-sent-folder   "/Sent"       ;; folder for sent messages
 mu4e-drafts-folder "/Drafts"     ;; unfinished messages
 mu4e-trash-folder  "/Trash"      ;; trashed messages
 mu4e-refile-folder "/Archive")   ;; saved messages

(setq mu4e-view-show-addresses t)  ;; show email addresses along with names
(setq mu4e-headers-visible-lines 15)  ;; messages count in split view

;; rendering html
(defun my-render-html-message ()
  (let ((dom (libxml-parse-html-region (point-min) (point-max))))
    (erase-buffer)
    (shr-insert-document dom)
    (goto-char (point-min))))
(setq mu4e-html2text-command 'my-render-html-message)
