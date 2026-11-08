;;; my-ui.el --- look and feel -*- lexical-binding: t -*-

(defvar my/font-family "JetBrainsMono Nerd Font")
(defvar my/font-height 130)

(defun my/apply-font (&optional frame)
  (when (and (display-graphic-p frame)
             (member my/font-family (font-family-list frame)))
    (set-face-attribute 'default frame :family my/font-family :height my/font-height)
    (set-face-attribute 'fixed-pitch frame :family my/font-family)))
(my/apply-font)
(add-hook 'after-make-frame-functions #'my/apply-font)

(use-package doom-themes
  :demand t
  :config
  (setq doom-themes-enable-bold t doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-org-config))

(use-package nerd-icons :demand t)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  (doom-modeline-buffer-encoding 'nondefault)
  (doom-modeline-vcs-max-length 24)
  (doom-modeline-env-version nil)
  (doom-modeline-modal-icon t))

(use-package which-key
  :ensure nil
  :demand t
  :config
  (setq which-key-idle-delay 0.4
        which-key-sort-order 'which-key-key-order-alpha
        which-key-add-column-padding 1)
  (which-key-mode 1))

(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package hl-todo :demand t :config (global-hl-todo-mode 1))
(use-package nerd-icons-dired :hook (dired-mode . nerd-icons-dired-mode))
(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup))
(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(setq display-line-numbers-type t
      display-line-numbers-width 3
      frame-title-format '("%b" (:eval (when buffer-file-name (concat "  ·  " (abbreviate-file-name default-directory)))))
      window-divider-default-right-width 4   ; wide enough to grab with the trackpad (drag to resize)
      split-width-threshold 160)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'yaml-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(window-divider-mode 1)
;; Trackpad: plain line-based wheel scrolling. pixel-scroll-precision-mode
;; stutters on the macOS build, so it stays off.
(pixel-scroll-precision-mode 0)
(setq mouse-wheel-scroll-amount '(2 ((shift) . 8) ((control) . nil))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t
      mouse-wheel-tilt-scroll t         ; sideways swipe scrolls truncated lines
      mouse-wheel-flip-direction t      ; natural direction, like macOS
      scroll-step 1
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      fast-but-imprecise-scrolling t
      jit-lock-defer-time 0)
(blink-cursor-mode 0)

;; Trailing whitespace visible in code, cleaned on save for files I own.
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))
(add-hook 'yaml-mode-hook (lambda () (setq show-trailing-whitespace t)))
(add-hook 'before-save-hook #'delete-trailing-whitespace)

(provide 'my-ui)
;;; my-ui.el ends here
