;;; .emacs --- Initialization file for Emacs

;;; Commentary:

;; Emacs Startup File --- initialization for Emacs

;;; Code:

;; Early start configuration
;; -------------------------

;; Ignoring warning "Unnecessary call to ‘package-initialize’ in init file"
;; until https://github.com/cask/cask/issues/463 is resolved
;; TODO: revert
(setq warning-minimum-level :emergency)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq
 inhibit-startup-screen t
 inhibit-splash-screen t)

(require 'cask)
(require 'use-package)
(cask-initialize)

;; Configuration of builtin emacs features
;; ---------------------------------------

(setq
 indent-tabs-mode nil
 tab-width 4
 column-number-mode t
 select-enable-clipboard t)

;; enable C-x C-u and C-x C-l
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; save backup versions of modified buffers in a single directory
;; (the default configuration puts them next to the edited files)
(make-directory "~/.emacs.d/saves/" t)
(setq
   backup-by-copying t
   backup-directory-alist
    '(("." . "~/.emacs.d/saves/"))
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)

;; Pretty buffer names for duplicate filenames
(use-package ido
  :config
  (ido-mode 1))

;; Display duplicate buffer names properly
(use-package uniquify
  :config
  (setq
   uniquify-buffer-name-style 'post-forward
   uniquify-separator ":"))

;; Enable line numbers
(use-package linum
  :config (global-linum-mode))

(use-package python
  :init
  ;; we need setq-default instead of setq because this is a buffer local variable
  ;; TODO: make it work (it used to!)
  (setq-default py-split-windows-on-execute-function 'split-window-horizontally))

;; Org mode settings
(use-package org
  :hook (org-mode . org-indent-mode)
  :init
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda)
  (setq
    org-log-done t
    org-agenda-files '("~/org")
    org-export-with-section-numbers nil)
  ;; eval plantuml diagrams without asking for confirmations
  (defun stas/org-confirm-babel-evaluate (lang body)
    (not (string= lang "plantuml")))
  (setq org-confirm-babel-evaluate 'stas/org-confirm-babel-evaluate))

;; Configuration of external packages
;; ----------------------------------

(use-package org-download
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(use-package org-roam
      :hook
      (after-init . org-roam-mode)
      :custom
      (org-roam-directory "~/org")
      (org-roam-db-location "~/.emacs.d/.org-roam.db")
      (org-roam-capture-templates
       '(("o" "other" plain (function org-roam-capture--get-point)
	  "%?"
	  :file-name "${slug}-%<%Y%m%d%H%M%S>"
	  :head "#+title: ${title}\n#+TODO: TODO(t) | DONE(d) SCHEDULED(s) RESCHEDULED(r)\n\n"
	  :unnarrowed t)
	 ("n" "notes" plain (function org-roam-capture--get-point)
	  "%?"
	  :file-name "${slug}-%<%Y%m%d%H%M%S>"
	  :head "#+title: ${title}\n#+TODO: TODO(t) | DONE(d) SCHEDULED(s) RESCHEDULED(r)\n\n- Source ::\n- Author ::\n- Tags ::\n\n* [[file:_takeaways.org][Takeaways]]\n\n"
	  :unnarrowed t))
	'(("d" "daily" plain (function org-roam-capture--get-point)
	  "%?"
	  :file-name "${slug}"
	  :head "#+title: ${title}\n#+TODO: TODO(t) | DONE(d) SCHEDULED(s) RESCHEDULED(r)\n\n* Tasks\n\n* Brain\n\n* Meeting Notes\n\n"
	  :immediate-finish t)))
       (org-roam-dailies-capture-templates
	'(("d" "daily" plain (function org-roam-capture--get-point)
	  "%?"
	  :file-name "%<%Y-%m-%d>"
	  :head "#+title: %<%Y-%m-%d>\n#+TODO: TODO(t) | DONE(d) SCHEDULED(s) RESCHEDULED(r)\n\n* Tasks\n\n* Brain\n\n* Meeting Notes\n\n"
	  :immediate-finish t)))
      :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph)
               ("C-c n d" . org-roam-dailies-find-date)
               ("C-c n r" . org-roam-dailies-find-tomorrow)
               ("C-c n t" . org-roam-dailies-find-today)
               ("C-c n y" . org-roam-dailies-find-yesterday))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))

(use-package ob-http)

(use-package ox-gfm)

(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package editorconfig
  :config (editorconfig-mode 1))

(use-package projectile
  :init
  (setq projectile-keymap-prefix (kbd "C-c p"))
  :hook (after-init . projectile-global-mode))

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (yas-load-directory "~/.emacs.d/snippets"))

(use-package company
  :hook (after-init . global-company-mode))

(use-package flycheck
  :hook (after-init . global-flycheck-mode))

(use-package ace-window
  :bind ("M-p" . ace-window))

(use-package rg
  :hook (after-init . rg-enable-default-bindings))

(use-package web-mode
  :mode ("\\.html$" . web-mode))

(use-package plantuml-mode
  :init
  (setq plantuml-default-exec-mode 'jar)
  (setq plantuml-jar-path "/usr/share/java/plantuml/plantuml.jar")
  (setq org-plantuml-jar-path plantuml-jar-path)
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t))))

(use-package lsp-mode
  :hook ((python-mode . lsp)
	 (rust-mode . lsp))
  :commands lsp)

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  (setq
   lsp-ui-sideline-enable nil
   lsp-rust-server 'rust-analyzer))

(use-package rust-mode
  :mode ("\\.rs\\$" . rust-mode))

(use-package cargo-mode
  :hook (rust-mode . cargo-minor-mode))

(provide '.emacs)
;;; .emacs ends here
