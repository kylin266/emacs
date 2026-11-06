;;; my-git.el --- version control -*- lexical-binding: t -*-

(use-package magit
  :commands (magit-status magit-blame magit-log-current magit-dispatch magit-file-dispatch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-diff-refine-hunk t)
  (magit-save-repository-buffers 'dontask)
  (git-commit-summary-max-length 72))

(use-package diff-hl
  :demand t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode . diff-hl-dired-mode))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

(use-package git-timemachine :commands git-timemachine)
(use-package git-modes :mode (("\\.gitignore\\'" . gitignore-mode) ("\\.gitconfig\\'" . gitconfig-mode)))
(use-package browse-at-remote :commands (browse-at-remote browse-at-remote-kill))

(provide 'my-git)
;;; my-git.el ends here
