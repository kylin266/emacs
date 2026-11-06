;;; my-evil.el --- vim keys -*- lexical-binding: t -*-

(use-package evil
  :pin melpa
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-want-Y-yank-to-eol t
        evil-undo-system 'undo-redo
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-respect-visual-line-mode t
        evil-search-module 'evil-search
        evil-ex-search-vim-style-regexp t
        evil-symbol-word-search t
        evil-kill-on-visual-paste nil)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'eshell-mode 'insert)
  (evil-define-key 'normal 'global (kbd "C-h") #'evil-window-left)
  (evil-define-key 'normal 'global (kbd "C-l") #'evil-window-right)
  (evil-define-key 'normal 'global (kbd "C-j") #'evil-window-down)
  (evil-define-key 'normal 'global (kbd "C-k") #'evil-window-up))

(use-package evil-collection
  :after evil
  :demand t
  :config
  (setq evil-collection-setup-minibuffer nil)
  (evil-collection-init))

(use-package evil-surround :after evil :demand t :config (global-evil-surround-mode 1))
(use-package evil-commentary :after evil :demand t :config (evil-commentary-mode 1))
(use-package evil-numbers
  :after evil
  :config
  (evil-define-key '(normal visual) 'global (kbd "g +") #'evil-numbers/inc-at-pt)
  (evil-define-key '(normal visual) 'global (kbd "g -") #'evil-numbers/dec-at-pt))

(use-package vundo
  :commands vundo
  :config (setq vundo-glyph-alist vundo-unicode-symbols))

;; Leader infrastructure; the actual map lives in my-keys.el.
(use-package general
  :demand t
  :config
  (general-evil-setup)
  (general-create-definer my/leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")
  (general-create-definer my/local-leader
    :states '(normal visual motion)
    :prefix ","))

(provide 'my-evil)
;;; my-evil.el ends here
