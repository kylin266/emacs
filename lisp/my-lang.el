;;; my-lang.el --- tree-sitter, eglot, DevOps file types -*- lexical-binding: t -*-

;; Tree-sitter grammars: install on first open, use *-ts-mode where available.
(use-package treesit-auto
  :demand t
  :custom (treesit-auto-install 'prompt)
  :config
  (setq treesit-auto-langs '(bash dockerfile go gomod json toml python markdown javascript typescript tsx css html))
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode 1))
(setq treesit-font-lock-level 4)

(defun my/install-treesit-grammars ()
  "Install every grammar in `treesit-auto-langs' that is missing."
  (interactive)
  (require 'treesit-auto)
  (let ((treesit-language-source-alist (treesit-auto--build-treesit-source-alist)))
    (dolist (lang treesit-auto-langs)
      (unless (treesit-language-available-p lang)
        (message "Installing tree-sitter grammar: %s" lang)
        (treesit-install-language-grammar lang)))))

;; YAML: yaml-mode indents better than yaml-ts-mode for k8s/helm/ansible.
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" "\\.ya?ml\\.j2\\'" "\\.ya?ml\\.tpl\\'")
  :hook (yaml-mode . (lambda () (setq-local tab-width 2))))

(use-package terraform-mode
  :mode ("\\.tf\\'" "\\.tfvars\\'" "\\.hcl\\'")
  :custom (terraform-indent-level 2) (terraform-format-on-save t))

(use-package ansible
  :commands ansible
  :init
  (defun my/ansible-maybe ()
    "Turn on `ansible' minor mode for YAML that lives in an Ansible tree."
    (when (and buffer-file-name
               (string-match-p "/\\(roles\\|playbooks\\|tasks\\|handlers\\|group_vars\\|host_vars\\|ansible\\)/\\|playbook[^/]*\\.ya?ml\\'"
                               buffer-file-name))
      (ansible 1)))
  :hook (yaml-mode . my/ansible-maybe))
(use-package ansible-doc :after ansible :hook (ansible . ansible-doc-mode))
(use-package jinja2-mode :mode ("\\.j2\\'" "\\.jinja2?\\'"))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode) ("\\.md\\'" . markdown-mode))
  :custom (markdown-fontify-code-blocks-natively t) (markdown-command "pandoc"))

(use-package markdown-toc :after markdown-mode :commands markdown-toc)

(use-package nginx-mode :mode ("nginx.*\\.conf\\'" "/nginx/.*\\.conf\\'" "/sites-\\(available\\|enabled\\)/"))
(use-package ssh-config-mode :mode ("/\\.ssh/config\\'" "/sshd?_config\\'" "known_hosts\\'" "authorized_keys\\'"))
(use-package systemd :mode ("\\.service\\'" "\\.timer\\'" "\\.socket\\'" "\\.target\\'"))
(use-package groovy-mode :mode ("Jenkinsfile\\'" "\\.groovy\\'"))
(add-to-list 'auto-mode-alist '("\\.env\\(\\..*\\)?\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.envrc\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("Dockerfile\\(\\..*\\)?\\'" . dockerfile-ts-mode))
(add-to-list 'auto-mode-alist '("\\.gitlab-ci\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.sum\\'" . conf-mode))

;; Shell: Emacs 30+ sh-mode runs shellcheck through flymake on its own.
(setq sh-shellcheck-program "shellcheck" sh-basic-offset 2)
(add-hook 'sh-mode-hook #'flymake-mode)

;; Eglot (built-in LSP client).
(defun my/yaml-lsp-contact (&rest _)
  "Pick ansible-language-server inside Ansible trees, yaml-language-server elsewhere."
  (if (and buffer-file-name (bound-and-true-p ansible))
      '("ansible-language-server" "--stdio")
    '("yaml-language-server" "--stdio")))

(defvar my/yaml-schemas
  (let ((h (make-hash-table :test 'equal)))
    (puthash "kubernetes"
             ["/k8s/**/*.y*ml" "/kubernetes/**/*.y*ml" "/manifests/**/*.y*ml" "/*.k8s.y*ml"
              "/*deploy*.y*ml" "/*deployment*.y*ml" "/*service*.y*ml" "/*ingress*.y*ml"
              "/*configmap*.y*ml" "/*secret*.y*ml" "/*statefulset*.y*ml" "/*daemonset*.y*ml"
              "/*cronjob*.y*ml" "/*pvc*.y*ml" "/*namespace*.y*ml"] h)
    (puthash "https://json.schemastore.org/github-workflow.json" ["/.github/workflows/*.y*ml"] h)
    (puthash "https://json.schemastore.org/github-action.json" ["/action.y*ml"] h)
    (puthash "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json" ["/.gitlab-ci.y*ml"] h)
    (puthash "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" ["/docker-compose*.y*ml" "/compose*.y*ml"] h)
    (puthash "https://json.schemastore.org/chart.json" ["/Chart.yaml"] h)
    (puthash "https://json.schemastore.org/kustomization.json" ["/kustomization.y*ml"] h)
    h)
  "yaml-language-server schema map: schema (or `kubernetes') -> file globs.")

(use-package eglot
  :ensure nil
  :hook ((yaml-mode terraform-mode go-ts-mode go-mod-ts-mode sh-mode bash-ts-mode
                    dockerfile-ts-mode json-ts-mode python-ts-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-report-progress nil)
  :config
  (add-to-list 'eglot-server-programs '(yaml-mode . my/yaml-lsp-contact))
  (add-to-list 'eglot-server-programs '(terraform-mode . ("terraform-ls" "serve")))
  (add-to-list 'eglot-server-programs '((dockerfile-ts-mode dockerfile-mode) . ("docker-langserver" "--stdio")))
  (setq-default eglot-workspace-configuration
                `(:yaml (:schemaStore (:enable t)
                         :validate t :hover t :completion t
                         :format (:enable t :singleQuote :json-false)
                         :keyOrdering :json-false
                         :schemas ,my/yaml-schemas)
                  :gopls (:usePlaceholders t :staticcheck t :gofumpt t)
                  :terraform-ls (:experimentalFeatures (:prefillRequiredFields t)))))

(use-package flymake
  :ensure nil
  :custom (flymake-no-changes-timeout 0.8) (flymake-fringe-indicator-position 'right-fringe))

(use-package apheleia
  :demand t
  :config
  (setf (alist-get 'terraform-mode apheleia-mode-alist) 'terraform)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'sh-mode apheleia-mode-alist) 'shfmt)
  (apheleia-global-mode 1))

(use-package yaml-pro :hook (yaml-mode . yaml-pro-mode))

(provide 'my-lang)
;;; my-lang.el ends here
