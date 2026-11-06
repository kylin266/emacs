;;; my-ai.el --- LLM on demand, never in the way -*- lexical-binding: t -*-
;;
;; Two doors:
;;  - claude-code-ide: Claude Code in a vterm side window, connected to Emacs
;;    as an IDE over MCP (SPC o c).  Claude sees the current file, selection
;;    and flymake diagnostics, opens its edits as ediff diffs you accept or
;;    reject, and can call a few Emacs tools (xref, imenu, project).  Uses the
;;    existing subscription, no API key.  bin/claude sources an optional
;;    bin/claude-env.local (git-ignored) so a client workspace can get its own
;;    CLAUDE_CONFIG_DIR, like the shell function in ~/.zshrc.
;;  - gptel: chat/rewrite in any buffer (SPC o g).  Needs an API key in
;;    ~/.authinfo.gpg: `machine api.anthropic.com login apikey password sk-...'.
;;    A LiteLLM backend for client work can be added in lisp/local.el.

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :commands (claude-code-ide claude-code-ide-toggle claude-code-ide-menu
             claude-code-ide-send-prompt claude-code-ide-continue claude-code-ide-resume
             claude-code-ide-stop claude-code-ide-stop-all claude-code-ide-list-sessions
             claude-code-ide-insert-at-mentioned claude-code-ide-switch-to-buffer
             claude-code-ide-send-escape claude-code-ide-check-status)
  :custom
  (claude-code-ide-cli-path (expand-file-name "bin/claude" user-emacs-directory))
  (claude-code-ide-terminal-backend 'vterm)
  (claude-code-ide-use-side-window t)
  (claude-code-ide-window-side 'right)
  (claude-code-ide-window-width 100)
  (claude-code-ide-focus-on-open t)
  (claude-code-ide-use-ide-diff t)
  (claude-code-ide-show-claude-window-in-ediff t)
  (claude-code-ide-diagnostics-backend 'flymake)
  (claude-code-ide-vterm-anti-flicker t)
  (claude-code-ide-enable-execute-code nil)   ; Claude may read Emacs state, not eval elisp
  :config
  (require 'web-server)   ; the Emacs-tools MCP server needs it loaded first
  ;; Expose xref / imenu / project lookups to Claude as MCP tools.
  (claude-code-ide-emacs-tools-setup))

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
