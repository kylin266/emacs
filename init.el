;;; init.el --- kylin266's DevOps Emacs -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'my-core)        ; package.el, use-package, PATH, sane defaults
(require 'my-ui)          ; theme, font, modeline, icons
(require 'my-evil)        ; evil + leader key infra
(require 'my-completion)  ; vertico, consult, corfu, snippets
(require 'my-git)         ; magit, diff-hl
(require 'my-lang)        ; tree-sitter, eglot, yaml/terraform/go/sh/docker/ansible
(require 'my-devops)      ; kubel, docker, tramp, eshell/eat, kube/aws context
(require 'my-org)         ; org + babel
(require 'my-playbooks)   ; runnable org playbooks
(require 'my-ai)          ; claude-code + gptel
(require 'my-keys)        ; SPC leader map

;; Machine-local, never committed (see .gitignore).
(let ((local (expand-file-name "lisp/local.el" user-emacs-directory)))
  (when (file-exists-p local) (load local nil t)))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file nil t))

;;; init.el ends here
