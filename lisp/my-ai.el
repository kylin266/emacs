;;; my-ai.el --- LLM on demand, never in the way -*- lexical-binding: t -*-
;;
;; Two doors:
;;  - claude-code: the Claude Code CLI in an eat terminal next to the code
;;    (SPC o c).  Uses the existing subscription, no API key.  bin/claude
;;    sources an optional bin/claude-env.local (git-ignored) so a client
;;    workspace can get its own CLAUDE_CONFIG_DIR, like the shell function in ~/.zshrc.
;;  - gptel: chat/rewrite in any buffer (SPC o g).  Needs an API key in
;;    ~/.authinfo.gpg: `machine api.anthropic.com login apikey password sk-...'.
;;    A LiteLLM backend for client work can be added in lisp/local.el.

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :commands (claude-code claude-code-toggle claude-code-send-command claude-code-send-region claude-code-fix-error-at-point)
  :custom
  (claude-code-terminal-backend (if (require 'vterm nil t) 'vterm 'eat))
  (claude-code-program (expand-file-name "bin/claude" user-emacs-directory))
  :config
  (claude-code-mode 1))

(use-package gptel
  :commands (gptel gptel-send gptel-menu gptel-rewrite gptel-add)
  :custom
  (gptel-default-mode 'org-mode)
  (gptel-org-branching-context t)
  :config
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key #'gptel-api-key-from-auth-source
          :models '(claude-fable-5-1 claude-opus-5-5 claude-sonnet-5-5 claude-haiku-5-5))
        gptel-model 'claude-sonnet-5-5)
  (setf (alist-get 'devops gptel-directives)
        "You are a senior DevOps/SRE pair. Answer tersely with exact commands and file paths. Assume Kubernetes, Terraform, AWS, Ansible and GitLab CI unless told otherwise. Never invent resource names."))

(provide 'my-ai)
;;; my-ai.el ends here
