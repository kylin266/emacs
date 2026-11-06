;;; my-playbooks.el --- runnable org playbooks for day-to-day checks -*- lexical-binding: t -*-
;;
;; A playbook is an org file whose `sh' source blocks are the checks you'd
;; otherwise type by hand.  Open one with SPC o p, put point on a block and
;; press , e (or C-c C-c) to run it, , a to run the whole file.  Results land
;; under each block, so the file is both the runbook and the latest reading.
;;
;; Playbook directories are listed in `my/playbook-dirs'.  Files under
;; `playbooks/local/' in this repo and anything outside it are never committed,
;; so client names and account ids stay on this machine.

(require 'org)

(defvar my/playbook-dirs
  (list (expand-file-name "playbooks" user-emacs-directory))
  "Directories searched (recursively) for *.org playbooks.
Add client workspaces from lisp/local.el, never here.")

(defvar my/playbook-template
  (expand-file-name "playbooks/_template.org" user-emacs-directory))

(defun my/playbook-files ()
  (let (files)
    (dolist (dir my/playbook-dirs)
      (when (file-directory-p dir)
        (dolist (f (directory-files-recursively dir "\\.org\\'"))
          (unless (string-prefix-p "_" (file-name-nondirectory f))
            (push f files)))))
    (sort files #'string<)))

(defun my/playbook--label (file)
  (let ((dir (seq-find (lambda (d) (string-prefix-p (expand-file-name d) file)) my/playbook-dirs)))
    (file-relative-name file (or dir "~"))))

(defun my/playbook (file)
  "Open a playbook chosen from `my/playbook-dirs'."
  (interactive
   (let* ((files (my/playbook-files))
          (alist (mapcar (lambda (f) (cons (my/playbook--label f) f)) files))
          (pick (completing-read "Playbook: " alist nil t)))
     (list (alist-get pick alist nil nil #'equal))))
  (find-file file))

(defun my/playbook-in-playbook-dir-p (&optional file)
  (let ((f (or file buffer-file-name)))
    (and f (seq-some (lambda (d) (string-prefix-p (expand-file-name d) (expand-file-name f)))
                     my/playbook-dirs))))

(defun my/playbook-confirm (lang _body)
  "Ask before evaluating unless this is a shell block inside a playbook."
  (not (and (member lang '("sh" "shell" "bash"))
            (my/playbook-in-playbook-dir-p))))
(setq org-confirm-babel-evaluate #'my/playbook-confirm)

(defun my/playbook-run-block ()
  "Run the source block at point."
  (interactive)
  (org-babel-execute-src-block))

(defun my/playbook-run-all ()
  "Run every block in the buffer, top to bottom."
  (interactive)
  (when (yes-or-no-p (format "Run every block in %s? " (buffer-name)))
    (org-babel-execute-buffer)))

(defun my/playbook-run-subtree ()
  "Run every block in the current heading."
  (interactive)
  (org-babel-execute-subtree))

(defun my/playbook-clear-results ()
  "Remove all results from the buffer."
  (interactive)
  (org-babel-remove-result-one-or-many t))

(defun my/playbook-new (name &optional dir)
  "Create a playbook NAME from the template in DIR (default: first playbook dir)."
  (interactive
   (list (read-string "Playbook name (kebab-case): ")
         (completing-read "Directory: " (seq-filter #'file-directory-p my/playbook-dirs) nil t)))
  (let* ((dir (or dir (car my/playbook-dirs)))
         (file (expand-file-name (concat name ".org") dir)))
    (make-directory dir t)
    (when (file-exists-p file) (user-error "%s exists" file))
    (copy-file my/playbook-template file)
    (find-file file)
    (goto-char (point-min))
    (while (search-forward "{{name}}" nil t) (replace-match name))
    (goto-char (point-min))
    (while (search-forward "{{date}}" nil t) (replace-match (format-time-string "%Y-%m-%d")))
    (goto-char (point-min))))

(defun my/playbook-copy-block ()
  "Copy the shell command of the block at point, to paste in a terminal or chat."
  (interactive)
  (let ((info (org-babel-get-src-block-info)))
    (unless info (user-error "Not on a source block"))
    (kill-new (nth 1 info))
    (message "Copied block body")))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c p e") #'my/playbook-run-block)
  (define-key org-mode-map (kbd "C-c p a") #'my/playbook-run-all)
  (define-key org-mode-map (kbd "C-c p s") #'my/playbook-run-subtree)
  (define-key org-mode-map (kbd "C-c p c") #'my/playbook-clear-results)
  (define-key org-mode-map (kbd "C-c p y") #'my/playbook-copy-block))

(provide 'my-playbooks)
;;; my-playbooks.el ends here
