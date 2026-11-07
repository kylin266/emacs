;;; my-core.el --- packages, PATH, defaults -*- lexical-binding: t -*-

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1))
      package-install-upgrade-built-in t)
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t
      use-package-vc-prefer-newest t)

;; Keep ~/.emacs.d clean: caches under var/, generated config under etc/.
(use-package no-littering
  :demand t
  :config
  (no-littering-theme-backups)
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; GUI Emacs on macOS does not inherit the shell PATH; pull it from zsh once.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (setq exec-path-from-shell-variables
        '("PATH" "MANPATH" "KUBECONFIG" "AWS_PROFILE" "AWS_REGION" "GOPATH" "SSH_AUTH_SOCK"))
  (exec-path-from-shell-initialize))

(defun my/add-to-path (dir)
  "Prepend DIR to `exec-path' and $PATH when it exists."
  (let ((d (expand-file-name dir)))
    (when (file-directory-p d)
      (add-to-list 'exec-path d)
      (setenv "PATH" (concat d path-separator (getenv "PATH"))))))

(dolist (d (list (expand-file-name "bin" user-emacs-directory) "/usr/local/bin" "~/go/bin" "~/.bun/bin" "~/.local/bin"
                 (car (last (file-expand-wildcards "~/.nvm/versions/node/*/bin")))))
  (when d (my/add-to-path d)))

;; Identity (used by magit commit templates, snippets).
(setq user-full-name "Tuan To"
      user-mail-address "toanhtuan2662@gmail.com")

;; Editing defaults.
(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100
              truncate-lines t)
(setq ring-bell-function #'ignore
      use-short-answers t
      confirm-kill-emacs #'y-or-n-p
      confirm-kill-processes nil
      create-lockfiles nil
      make-backup-files t
      delete-old-versions t
      version-control t
      kept-new-versions 5
      require-final-newline t
      sentence-end-double-space nil
      read-process-output-max (* 4 1024 1024)
      scroll-conservatively 101
      scroll-margin 3
      enable-recursive-minibuffers t
      kill-do-not-save-duplicates t
      large-file-warning-threshold (* 100 1024 1024)
      dired-listing-switches "-alh"
      dired-use-ls-dired nil
      dired-dwim-target t
      dired-kill-when-opening-new-dired-buffer t
      vc-follow-symlinks t
      initial-scratch-message nil
      initial-major-mode 'org-mode)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t auto-revert-verbose nil)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(setq recentf-max-saved-items 300)
(electric-pair-mode 1)
(delete-selection-mode 1)
(global-so-long-mode 1)
(prefer-coding-system 'utf-8)

;; macOS keys: Command stays Super (s-c/s-v/s-s work), Option is Meta.
(when (eq system-type 'darwin)
  (setq ns-command-modifier 'super
        ns-option-modifier 'meta
        ns-right-option-modifier 'none
        ns-use-native-fullscreen t
        trash-directory "~/.Trash"
        delete-by-moving-to-trash t))

(provide 'my-core)
;;; my-core.el ends here
