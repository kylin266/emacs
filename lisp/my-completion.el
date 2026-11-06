;;; my-completion.el --- minibuffer + in-buffer completion -*- lexical-binding: t -*-

(use-package vertico
  :demand t
  :custom (vertico-cycle t) (vertico-count 15) (vertico-resize nil)
  :config (vertico-mode 1))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia :demand t :config (marginalia-mode 1))

(use-package consult
  :demand t
  :custom
  (consult-narrow-key "<")
  (consult-preview-key '(:debounce 0.2 any))
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  :config
  (setq consult-project-function
        (lambda (_) (when-let* ((p (project-current))) (project-root p)))
        consult-ripgrep-args
        (concat consult-ripgrep-args " --hidden --glob !.git --glob !node_modules --glob !.terraform")))

(use-package embark
  :bind (("C-." . embark-act) ("C-;" . embark-dwim) ("C-h B" . embark-bindings))
  :init (setq prefix-help-command #'embark-prefix-help-command))
(use-package embark-consult :after (embark consult))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t) (corfu-auto-delay 0.15) (corfu-auto-prefix 2)
  (corfu-cycle t) (corfu-preselect 'prompt) (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("TAB" . corfu-next) ([tab] . corfu-next)
              ("S-TAB" . corfu-previous) ([backtab] . corfu-previous)
              ("RET" . corfu-insert))
  :config
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay '(0.5 . 0.2)))

(use-package cape
  :demand t
  :config
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-keyword))

(use-package yasnippet
  :demand t
  :config
  (setq yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  (yas-global-mode 1))
(use-package yasnippet-snippets
  :after yasnippet
  :config (add-to-list 'yas-snippet-dirs yasnippet-snippets-dir t) (yas-reload-all))
(use-package yasnippet-capf
  :after cape
  :config (add-hook 'completion-at-point-functions #'yasnippet-capf))

(setq tab-always-indent 'complete
      text-mode-ispell-word-completion nil
      read-extended-command-predicate #'command-completion-default-include-p)

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-key helpful-at-point helpful-command))

(provide 'my-completion)
;;; my-completion.el ends here
