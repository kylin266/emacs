;;; my-keys.el --- SPC leader map (Doom-flavoured) -*- lexical-binding: t -*-

(my/leader
  "SPC" '(execute-extended-command :wk "M-x")
  ":"   '(eval-expression :wk "eval")
  "."   '(find-file :wk "find file")
  ","   '(consult-buffer :wk "switch buffer")
  "/"   '(consult-ripgrep :wk "rg project")
  "u"   '(universal-argument :wk "C-u")
  "x"   '(scratch-buffer :wk "scratch")
  "`"   '(evil-switch-to-windows-last-buffer :wk "last buffer")

  "b"  '(:ignore t :wk "buffer")
  "bb" 'consult-buffer  "bB" 'consult-buffer-other-window
  "bd" 'kill-current-buffer "bk" 'kill-current-buffer
  "bn" 'next-buffer "bp" 'previous-buffer
  "br" 'revert-buffer-quick "bR" 'rename-buffer
  "bs" 'save-buffer "bS" 'save-some-buffers
  "bi" 'ibuffer "bu" 'vundo

  "f"  '(:ignore t :wk "file")
  "ff" 'find-file "fF" 'find-file-other-window
  "fr" 'consult-recent-file "fs" 'save-buffer "fS" 'write-file
  "fd" 'dired-jump "fD" 'my/delete-this-file
  "fR" 'my/rename-this-file "fy" 'my/copy-file-path
  "fp" '(my/find-in-emacs-dir :wk "emacs config")
  "fe" '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :wk "init.el")
  "fl" '((lambda () (interactive) (find-file (expand-file-name "lisp/local.el" user-emacs-directory))) :wk "local.el")

  "g"  '(:ignore t :wk "git")
  "gg" 'magit-status "gb" 'magit-blame-addition "gl" 'magit-log-current
  "gL" 'magit-log-buffer-file "gf" 'magit-file-dispatch "gd" 'magit-diff-buffer-file
  "gt" 'git-timemachine "gy" 'browse-at-remote-kill "go" 'browse-at-remote
  "gn" 'diff-hl-next-hunk "gp" 'diff-hl-previous-hunk "gr" 'diff-hl-revert-hunk

  "p"  '(:ignore t :wk "project")
  "pp" 'project-switch-project "pf" 'project-find-file "pd" 'project-find-dir
  "pb" 'consult-project-buffer "ps" 'consult-ripgrep "pc" 'project-compile
  "pt" 'my/terminal-project "pe" 'project-eshell "pk" 'project-kill-buffers
  "pD" 'project-dired "pm" 'magit-project-status

  "s"  '(:ignore t :wk "search")
  "ss" 'consult-line "sS" 'consult-line-multi "sp" 'consult-ripgrep
  "sd" '(my/rg-dir :wk "rg dir") "si" 'consult-imenu "sI" 'consult-imenu-multi
  "so" 'consult-outline "sm" 'consult-mark "sr" 'consult-register
  "sf" 'consult-fd "sg" 'consult-grep "sk" 'consult-kmacro "sy" 'consult-yank-pop
  "sx" 'consult-flymake "sh" 'consult-history

  "w"  '(:ignore t :wk "window")
  "wv" 'evil-window-vsplit "ws" 'evil-window-split
  "wd" 'evil-window-delete "wq" 'evil-quit "wo" 'delete-other-windows "wm" 'delete-other-windows
  "ww" 'other-window "wh" 'evil-window-left "wj" 'evil-window-down
  "wk" 'evil-window-up "wl" 'evil-window-right
  "wH" 'evil-window-move-far-left "wL" 'evil-window-move-far-right
  "wJ" 'evil-window-move-very-bottom "wK" 'evil-window-move-very-top
  "w=" 'balance-windows "wu" 'winner-undo "wr" 'winner-redo

  "o"  '(:ignore t :wk "open")
  "op" '(my/playbook :wk "playbook")
  "oP" '(my/playbook-new :wk "new playbook")
  "ok" '(kubel :wk "kubel")
  "oK" '(my/kube-use-context :wk "kube context")
  "oa" '(my/aws-use-profile :wk "aws profile")
  "od" '(docker :wk "docker")
  "ot" '(my/terminal :wk "terminal")
  "oT" '(my/terminal-project :wk "terminal (project)")
  "oe" '(eshell :wk "eshell")
  "os" '(my/ssh-shell :wk "ssh host")
  "oS" '(my/ssh-dired :wk "ssh dired")
  "oc" '(claude-code-ide :wk "claude code (ide)")
  "oC" '(claude-code-ide-continue :wk "claude: continue last")
  "og" '(gptel :wk "gptel chat")
  "oG" '(gptel-menu :wk "gptel menu")
  "o-" '(dired-jump :wk "dired here")
  "of" '(make-frame :wk "new frame")

  "k"  '(:ignore t :wk "kubectl (buffer)")
  "kd" '(my/kubectl-dry-run :wk "dry-run=server")
  "kD" '(my/kubectl-diff :wk "diff")
  "ka" '(my/kubectl-apply :wk "apply")
  "kx" '(my/kubectl-delete :wk "delete")
  "kc" '(my/kube-use-context :wk "context")

  "c"  '(:ignore t :wk "code")
  "ca" 'eglot-code-actions "cr" 'eglot-rename "cf" 'eglot-format
  "cd" 'xref-find-definitions "cD" 'xref-find-references "cb" 'xref-go-back
  "ch" 'eldoc "ci" 'eglot-find-implementation "ct" 'eglot-find-typeDefinition
  "cx" 'consult-flymake "cn" 'flymake-goto-next-error "cp" 'flymake-goto-prev-error
  "cj" 'consult-imenu "cc" 'compile "cC" 'recompile
  "cs" 'eglot "cS" 'eglot-shutdown "cR" 'eglot-reconnect
  "ce" 'eval-last-sexp "cE" 'eval-buffer

  "a"  '(:ignore t :wk "ai")
  "aa" '(claude-code-ide :wk "start / show")
  "at" '(claude-code-ide-toggle :wk "toggle window")
  "as" '(claude-code-ide-send-prompt :wk "send prompt")
  "ai" '(claude-code-ide-insert-at-mentioned :wk "insert @file ref")
  "ac" '(claude-code-ide-continue :wk "continue last")
  "ar" '(claude-code-ide-resume :wk "resume a session")
  "al" '(claude-code-ide-list-sessions :wk "sessions")
  "ab" '(claude-code-ide-switch-to-buffer :wk "claude buffer")
  "ae" '(claude-code-ide-send-escape :wk "send ESC")
  "ak" '(claude-code-ide-stop :wk "stop session")
  "aK" '(claude-code-ide-stop-all :wk "stop all")
  "am" '(claude-code-ide-menu :wk "menu")
  "a?" '(claude-code-ide-check-status :wk "status")
  "ag" '(gptel :wk "gptel chat") "aG" '(gptel-menu :wk "gptel menu") "aR" '(gptel-rewrite :wk "gptel rewrite")

  "h"  '(:ignore t :wk "help")
  "hf" 'helpful-callable "hv" 'helpful-variable "hk" 'helpful-key
  "hx" 'helpful-command "hp" 'helpful-at-point "hm" 'describe-mode
  "hi" 'info "hb" 'embark-bindings "hF" 'describe-face "ho" 'describe-symbol
  "hP" 'describe-package "hM" 'man

  "t"  '(:ignore t :wk "toggle")
  "tl" 'display-line-numbers-mode "tw" 'visual-line-mode "tW" 'toggle-truncate-lines
  "tt" 'consult-theme "tf" 'flymake-mode "th" 'hl-line-mode
  "ts" 'flyspell-mode "tz" 'toggle-frame-fullscreen "tr" 'read-only-mode

  "q"  '(:ignore t :wk "quit")
  "qq" 'save-buffers-kill-terminal "qr" 'restart-emacs "qf" 'delete-frame

  "n"  '(:ignore t :wk "notes")
  "nn" '((lambda () (interactive) (find-file (expand-file-name "inbox.org" org-directory))) :wk "inbox")
  "nf" '((lambda () (interactive) (consult-find org-directory)) :wk "find note")
  "ns" '((lambda () (interactive) (consult-ripgrep org-directory)) :wk "search notes")
  "nc" 'org-capture "na" 'org-agenda)

;; Local leader "," inside org: playbook actions.
(my/local-leader
  :keymaps 'org-mode-map
  "e" '(my/playbook-run-block :wk "run block")
  "a" '(my/playbook-run-all :wk "run all")
  "s" '(my/playbook-run-subtree :wk "run subtree")
  "c" '(my/playbook-clear-results :wk "clear results")
  "y" '(my/playbook-copy-block :wk "copy block")
  "'" '(org-edit-special :wk "edit block")
  "t" '(org-todo :wk "todo")
  "l" '(org-insert-link :wk "link")
  "n" '(org-babel-next-src-block :wk "next block")
  "p" '(org-babel-previous-src-block :wk "prev block"))

(my/local-leader
  :keymaps 'yaml-mode-map
  "d" '(my/kubectl-dry-run :wk "kubectl dry-run")
  "D" '(my/kubectl-diff :wk "kubectl diff")
  "a" '(my/kubectl-apply :wk "kubectl apply"))

(my/local-leader
  :keymaps 'terraform-mode-map
  "f" '(terraform-format-buffer :wk "fmt")
  "i" '((lambda () (interactive) (compile "terraform init")) :wk "init")
  "v" '((lambda () (interactive) (compile "terraform validate")) :wk "validate")
  "p" '((lambda () (interactive) (compile "terraform plan -lock=false")) :wk "plan (no lock)"))

(my/local-leader
  :keymaps '(markdown-mode-map gfm-mode-map)
  "l" '(markdown-live-preview-mode :wk "live preview")
  "p" '(markdown-preview :wk "preview in browser")
  "e" '(markdown-export :wk "export html")
  "v" '(markdown-export-and-preview :wk "export + open")
  "o" '(markdown-open :wk "open in browser")
  "t" '(markdown-toc :wk "table of contents")
  "i" '(markdown-insert-link :wk "insert link")
  "c" '(markdown-insert-gfm-code-block :wk "code block"))

(my/local-leader
  :keymaps '(html-mode-map html-ts-mode-map mhtml-mode-map)
  "p" '(browse-url-of-buffer :wk "open in browser")
  "e" '((lambda () (interactive) (eww-open-file buffer-file-name)) :wk "render in eww"))

;; Small helpers the map refers to.
(defun my/find-in-emacs-dir ()
  (interactive)
  (let ((default-directory user-emacs-directory)) (project-find-file)))
(defun my/rg-dir (dir)
  (interactive "DDirectory: ")
  (consult-ripgrep dir))
(defun my/copy-file-path ()
  (interactive)
  (if buffer-file-name
      (progn (kill-new (abbreviate-file-name buffer-file-name)) (message "%s" (abbreviate-file-name buffer-file-name)))
    (user-error "No file")))
(defun my/delete-this-file ()
  (interactive)
  (let ((f buffer-file-name))
    (unless f (user-error "No file"))
    (when (yes-or-no-p (format "Delete %s? " f))
      (delete-file f t) (kill-current-buffer))))
(defun my/rename-this-file (new)
  (interactive (list (read-file-name "Rename to: " nil buffer-file-name)))
  (let ((old buffer-file-name))
    (rename-file old new 1)
    (set-visited-file-name new t t)))

(winner-mode 1)

;; macOS muscle memory.
(global-set-key (kbd "s-s") #'save-buffer)
(global-set-key (kbd "s-w") #'kill-current-buffer)
(global-set-key (kbd "s-=") #'text-scale-increase)
(global-set-key (kbd "s--") #'text-scale-decrease)
(global-set-key (kbd "s-0") (lambda () (interactive) (text-scale-set 0)))
(global-set-key (kbd "s-p") #'project-find-file)
(global-set-key (kbd "s-P") #'execute-extended-command)
(global-set-key (kbd "s-F") #'consult-ripgrep)
(global-set-key (kbd "s-b") #'consult-buffer)
(global-set-key (kbd "s-`") #'other-frame)
(global-set-key (kbd "s-o") #'other-window)   ; works inside terminal panes too
(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

(provide 'my-keys)
;;; my-keys.el ends here
