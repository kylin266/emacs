;;; my-devops.el --- kubernetes, docker, aws, remote hosts, terminals -*- lexical-binding: t -*-

;;;; Kubernetes
(use-package kubel
  :commands kubel
  :custom (kubel-use-namespace-list 'on) (kubel-log-tail-n 500))

(defvar my/kube-context-cache nil)
(defun my/kube-contexts ()
  (split-string (shell-command-to-string "kubectl config get-contexts -o name 2>/dev/null") "\n" t))
(defun my/kube-current-context ()
  (let ((c (string-trim (shell-command-to-string "kubectl config current-context 2>/dev/null"))))
    (setq my/kube-context-cache (unless (string-empty-p c) c))))
(defun my/kube-use-context (ctx)
  "Switch the global kubectl context (same effect as in the shell)."
  (interactive (list (completing-read "kube context: " (my/kube-contexts) nil t)))
  (shell-command (format "kubectl config use-context %s" (shell-quote-argument ctx)))
  (my/kube-current-context)
  (force-mode-line-update t))

(defun my/kubectl-buffer (args)
  "Run kubectl ARGS with the current buffer's file as -f, show output."
  (unless buffer-file-name (user-error "Buffer has no file"))
  (save-buffer)
  (let ((cmd (format "kubectl %s -f %s" args (shell-quote-argument buffer-file-name))))
    (compilation-start cmd nil (lambda (_) "*kubectl*"))))
(defun my/kubectl-dry-run () (interactive) (my/kubectl-buffer "apply --dry-run=server"))
(defun my/kubectl-diff () (interactive) (my/kubectl-buffer "diff"))
(defun my/kubectl-apply ()
  (interactive)
  (when (yes-or-no-p (format "kubectl apply to context %s? " (or my/kube-context-cache (my/kube-current-context))))
    (my/kubectl-buffer "apply")))
(defun my/kubectl-delete ()
  (interactive)
  (when (yes-or-no-p (format "kubectl DELETE from context %s? " (or my/kube-context-cache (my/kube-current-context))))
    (my/kubectl-buffer "delete")))

;;;; AWS profile (per Emacs session; child processes and org-babel inherit it)
(defun my/aws-profiles ()
  (let ((cfg (expand-file-name "~/.aws/config")) out)
    (when (file-readable-p cfg)
      (with-temp-buffer
        (insert-file-contents cfg)
        (while (re-search-forward "^\\[\\(?:profile \\)?\\([^]]+\\)\\]" nil t)
          (push (match-string 1) out))))
    (nreverse out)))
(defun my/aws-use-profile (profile)
  "Set AWS_PROFILE for this Emacs and its subprocesses."
  (interactive (list (completing-read "AWS_PROFILE: " (my/aws-profiles) nil nil (getenv "AWS_PROFILE"))))
  (setenv "AWS_PROFILE" profile)
  (force-mode-line-update t)
  (message "AWS_PROFILE=%s" profile))

(defun my/devops-modeline ()
  (let ((aws (getenv "AWS_PROFILE")) (k8s my/kube-context-cache))
    (concat (when aws (format " ☁ %s" aws)) (when k8s (format " ⎈ %s" k8s)))))
(add-to-list 'global-mode-string '(:eval (my/devops-modeline)) t)
(add-hook 'emacs-startup-hook #'my/kube-current-context)

;;;; Docker
(use-package docker :commands docker :custom (docker-show-messages nil))

;;;; Remote hosts
(use-package tramp
  :ensure nil
  :defer t
  :config
  (setq tramp-default-method "ssh"
        tramp-verbose 1
        tramp-use-connection-share t
        tramp-copy-size-limit (* 1024 1024)
        remote-file-name-inhibit-locks t
        remote-file-name-inhibit-auto-save-visited t
        tramp-persistency-file-name (no-littering-expand-var-file-name "tramp"))
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq vc-ignore-dir-regexp (format "%s\\|%s" vc-ignore-dir-regexp tramp-file-name-regexp))
  (connection-local-set-profile-variables 'remote-no-lsp '((eglot-ensure . ignore)))
  (connection-local-set-profiles '(:application tramp) 'remote-no-lsp))

(defun my/ssh-hosts ()
  (let (hosts)
    (dolist (f (list "~/.ssh/config" "~/.ssh/known_hosts"))
      (when (file-readable-p (expand-file-name f))
        (with-temp-buffer
          (insert-file-contents (expand-file-name f))
          (while (re-search-forward "^Host \\([^ *?]+\\)" nil t) (push (match-string 1) hosts)))))
    (delete-dups (nreverse hosts))))
(defun my/ssh-dired (host)
  "Open dired on HOST over TRAMP."
  (interactive (list (completing-read "ssh host: " (my/ssh-hosts))))
  (dired (format "/ssh:%s:" host)))
(defun my/ssh-shell (host)
  "Open an eat terminal running ssh HOST."
  (interactive (list (completing-read "ssh host: " (my/ssh-hosts))))
  (require 'eat)
  (let ((eat-buffer-name (format "*ssh %s*" host)))
    (eat (format "ssh %s" host) t)))

;;;; Terminals
(use-package eat
  :commands (eat eat-project eat-other-window)
  :custom (eat-kill-buffer-on-exit t) (eat-enable-mouse t)
  :hook (eshell-load . eat-eshell-mode)
  :config
  ;; C-c o leaves the terminal pane even while keys go to the shell.
  (define-key eat-semi-char-mode-map (kbd "C-c o") #'other-window)
  (define-key eat-char-mode-map (kbd "C-c o") #'other-window))

(use-package eshell
  :ensure nil
  :defer t
  :config
  (setq eshell-history-size 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-prefer-lisp-functions nil
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands '("htop" "k9s" "less" "top" "vim" "watch" "ssh" "tmux" "aws" "docker" "kubectl")))

;;;; HTTP checks
(use-package verb :after org :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;;;; Project
(setq project-vc-extra-root-markers '("Chart.yaml" "kustomization.yaml" "main.tf" "ansible.cfg" "pyproject.toml" "package.json" "go.mod" ".project"))
(setq project-switch-commands
      '((project-find-file "File" ?f) (consult-ripgrep "Grep" ?g) (project-dired "Dired" ?d)
        (magit-project-status "Magit" ?m) (eat-project "Terminal" ?t) (project-eshell "Eshell" ?e)))

(provide 'my-devops)
;;; my-devops.el ends here
