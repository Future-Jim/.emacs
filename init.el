7;; Do not show the startup screen.
(setq inhibit-startup-message t)

;; Disable tool bar, menu bar, scroll bar.
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;;enable visual wordwrap in all text-modes
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

;; Highlight current line.
(global-hl-line-mode t)

;; Do not use `init.el` for `custom-*` code - use `custom-file.el`.
(setq custom-file "~/.emacs.d/custom-file.el")

;;dont make backup files
(setq make-backup-files nil)

;; Assuming that the code in custom-file is execute before the code
;; ahead of this line is not a safe assumption. So load this file
;; proactively.
(load-file custom-file)

;; Require and initialize `package`.
(require 'package)
(package-initialize)

;; Add `melpa` to `package-archives`.
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))


;;wrap text globally in all modes
(setq-default global-visual-line-mode t)
(setq column-number-mode t)

;; Additional packages and their configurations
(use-package spacemacs-theme
  :defer t
  ;; Do not use a different background color for comments.
  :init
  ;; Comments should appear in italics.
  (setq spacemacs-theme-comment-italic t)
  ;; Comments background are the same color as the rest of the field
  (setq spacemacs-theme-comment-bg nil)
  ;; Use the `spacemacs-dark` theme.
  (load-theme 'spacemacs-dark))


(use-package company
  ;; Navigate in completion minibuffer with `C-n` and `C-p`.
  :bind (:map company-active-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous))
  :config
  ;; Provide instant autocompletion.
  (setq company-idle-delay 0.3)

  ;; Use company mode everywhere.
  (global-company-mode t))

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; ivy mode - ivy comes with counsel and swiper
;; ivy provides an interface to list, search, filter and perform actions on a collection of things
(use-package ivy :demand
  :config
  (ivy-mode 1)
      (setq ivy-use-virtual-buffers t
            ivy-count-format "%d/%d "))

;; swiper is installed with ivy, the below is the config for swiper
;; it might be able to go under ivy, but im not sure

(use-package swiper :ensure
  :config
(global-set-key (kbd "C-s") 'swiper)
(setq ivy-display-style 'fancy))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  (setq org-roam-db-location "~/.database/org-roam.db")
  :custom
  (org-roam-directory "~/sync/org/roam")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
         ("C-c n g" . org-roam-graph)
         ("C-M-i"    . completion-at-point)
  :config
  (org-roam-db-autosync-mode))

(use-package org-journal
  :ensure t
  :defer t
  :config
  (setq org-journal-dir "~/sync/org/journal"

        org-journal-date-format "%A, %d %B %Y"
        org-journal-time-format "%I:%M %p")
  :bind* ("C-c C-j" . org-journal-new-entry))

(setq org-agenda-files "~/sync/org/agenda/personal.org")

;; Nice bullets in Org-Mode
(use-package org-superstar
      :config
      (setq org-superstar-special-todo-items t)
      (add-hook 'org-mode-hook (lambda ()
                                 (org-superstar-mode 1))))

;; Image size scaling in Org-Mode
(setq org-image-actual-width nil)

;; need to fix these tempaltes as they are ugly
(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
         (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
         :unnarrowed t)

        ("r" "running" plain "*** ${title}\n :date:%<%Y%m%d%H%M%S>\n :distance:\n :pace:\n  :tod:\n :course:\n :notes:\n"
         :target (file+olp "running.org" ("runs")
			   ))

        ("m" "movie" plain "*** ${title}\n :PROPERTIES:\n :ID: %(org-id-uuid)\n :RATING:\n  :END:\n%t\n"
         :target (file+olp "movies.org" ("Watched")
			   ))
	("b" "book" plain "*** ${title}\n :PROPERTIES:\n :readID: d0fbe901-291f-42d6-81f8-39f93c186163 :ID: %(org-id-uuid)\n :author:\n :notes:\n :rating:\n :END:\n%t\n"
         :target (file+olp "books.org" ("Read")
			   ))))


(setq org-directory "~/sync/org/agenda")
(setq org-agenda-files '("personal.org" "professional.org"))

;; If you only want to see the agenda for today
;; (setq org-agenda-span 'day)

(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)

(put 'erase-buffer 'disabled nil)

;;rust TBF
(use-package rust-mode)

;;this should enable lsp mode in order for rust-analyzer (~/.local/bin/rust-analyzer) to be enabled
(add-hook 'rust-mode-hook 'lsp-deferred)

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(add-to-list 'exec-path "/usr/local/go/bin")
(add-hook 'before-save-hook 'gofmt-before-save)

(defun auto-complete-for-go ()
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-theme 'vscode)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))


(require 'lsp-mode)
(add-hook 'go-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(lsp-register-custom-settings
 '(("gopls.completeUnimported" t t)
   ("gopls.staticcheck" t t)))

(setq lsp-go-analyses '((shadow . t)
                        (simplifycompositelit . :json-false)))


;; python
(use-package lsp-jedi
  :ensure t)

(package-install 'flycheck)

(global-flycheck-mode)
