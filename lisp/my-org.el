;;; my-org.el --- org-mode and babel -*- lexical-binding: t -*-

(use-package org
  :ensure nil
  :defer t
  :custom
  (org-directory "~/org/")
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis " …")
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-src-preserve-indentation t)
  (org-src-window-setup 'current-window)
  (org-edit-src-content-indentation 0)
  (org-log-done 'time)
  (org-return-follows-link t)
  (org-babel-results-keyword "results")
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "DROP(x)")))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t) (emacs-lisp . t) (python . t) (sql . t) (js . t)))
  (add-to-list 'org-src-lang-modes '("sh" . sh))
  (add-to-list 'org-src-lang-modes '("yaml" . yaml))
  (add-to-list 'org-src-lang-modes '("hcl" . terraform))
  (add-to-list 'org-src-lang-modes '("tf" . terraform))
  (add-to-list 'org-src-lang-modes '("dockerfile" . dockerfile-ts))
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("y" . "src yaml"))
  (add-to-list 'org-structure-template-alist '("tf" . "src hcl"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom (org-modern-table nil) (org-modern-block-fringe nil))

(use-package ob-async :after org)

(provide 'my-org)
;;; my-org.el ends here
