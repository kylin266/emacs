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

(defun my/playbook--no-pty (orig &rest args)
  "Start babel shell sessions over a pipe, not a pty: no echoed input in
results, and tools see no terminal so they never page."
  (let ((process-connection-type nil)) (apply orig args)))
(with-eval-after-load 'ob-shell
  (advice-add 'org-babel-sh-initiate-session :around #'my/playbook--no-pty))

(defun my/playbook-ingest-libs ()
  "Make named blocks from `_*.org' files in this playbook's folder available to <<noweb>> references."
  (when (my/playbook-in-playbook-dir-p)
    (dolist (lib (directory-files (file-name-directory buffer-file-name) t "\\`_.*\\.org\\'"))
      (org-babel-lob-ingest lib))))
(add-hook 'org-mode-hook #'my/playbook-ingest-libs)

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

(defun my/playbook-kill-session ()
  "Kill the background shell a playbook runs in (stops a runaway block)."
  (interactive)
  (let* ((info (org-babel-get-src-block-info t))
         (session (and info (cdr (assq :session (nth 2 info)))))
         (killed 0))
    (dolist (b (buffer-list))
      (when (and (string-match-p "playbook" (buffer-name b))
                 (or (null session) (string= session "none") (string= (buffer-name b) session))
                 (get-buffer-process b))
        (delete-process (get-buffer-process b))
        (kill-buffer b)
        (setq killed (1+ killed))))
    (message "killed %d playbook session(s); the next block starts a fresh one" killed)))

(defun my/playbook--result-text (res-pos)
  "Return the result text that starts at RES-POS, or nil."
  (when res-pos
    (save-excursion
      (goto-char res-pos)
      (forward-line 1)
      (let ((r (ignore-errors (org-babel-read-result))))
        (cond ((null r) nil)
              ((stringp r) r)
              (t (format "%S" r)))))))

(defun my/playbook-report ()
  "Gather every block's result in this playbook into a dated report and open it beside.
Report goes to runs/<date>-<playbook>.org next to the playbook (never committed)."
  (interactive)
  (unless (derived-mode-p 'org-mode) (user-error "Not in a playbook"))
  (let* ((src buffer-file-name)
         (name (file-name-base src))
         (dir (expand-file-name "runs" (file-name-directory src)))
         (stamp (format-time-string "%Y-%m-%d-%H%M"))
         (out (expand-file-name (format "%s-%s.org" (format-time-string "%Y-%m-%d") name) dir))
         (findings 0) (ok 0) (running 0) (missing 0) sections)
    (org-babel-map-src-blocks nil
      (let* ((heading (string-join (append (org-get-outline-path) (list (org-get-heading t t t t))) " / "))
             (res (my/playbook--result-text (org-babel-where-is-src-block-result)))
             (lines (and res (seq-remove #'string-empty-p (split-string (string-trim res) "\n"))))
             (status (cond ((null res) (cl-incf missing) 'missing)
                           ((and (= (length lines) 1) (string-match-p "\\`[0-9a-f-]\\{32,36\\}\\'" (car lines))) (cl-incf running) 'running)
                           ((seq-every-p (lambda (l) (or (string-prefix-p "(" l) (string-prefix-p "==" l))) lines) (cl-incf ok) 'ok)
                           (t (cl-incf findings) 'finding))))
        (push (list heading status res) sections)))
    (setq sections (nreverse sections))
    (make-directory dir t)
    (with-temp-file out
      (insert (format "#+TITLE: %s · %s\n#+STARTUP: showall\n\n" name stamp))
      (insert (format "Findings: %d   OK: %d   still running: %d   not run: %d\n" findings ok running missing))
      (when (getenv "AWS_PROFILE") (insert (format "AWS_PROFILE=%s  " (getenv "AWS_PROFILE"))))
      (when my/kube-context-cache (insert (format "kube=%s" my/kube-context-cache)))
      (insert "\n\n")
      (dolist (sec sections)
        (pcase-let ((`(,heading ,status ,res) sec))
          (when (eq status 'finding)
            (insert (format "* %s\n#+begin_example\n%s\n#+end_example\n\n" heading (string-trim res))))))
      (insert "* Passed\n")
      (dolist (sec sections)
        (pcase-let ((`(,heading ,status ,res) sec))
          (when (eq status 'ok) (insert (format "- %s  %s\n" heading (string-trim (or res "")))))))
      (when (> (+ running missing) 0)
        (insert "\n* Not finished\n")
        (dolist (sec sections)
          (pcase-let ((`(,heading ,status ,_) sec))
            (when (memq status '(running missing)) (insert (format "- %s  (%s)\n" heading status)))))))
    (let ((buf (find-file-noselect out)))
      (with-current-buffer buf (revert-buffer t t t))
      (pop-to-buffer buf '((display-buffer-in-side-window) (side . right) (window-width . 0.5)))
      (message "report: %s  (%d findings, %d ok)" (abbreviate-file-name out) findings ok))))

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
  (define-key org-mode-map (kbd "C-c p y") #'my/playbook-copy-block)
  (define-key org-mode-map (kbd "C-c p k") #'my/playbook-kill-session)
  (define-key org-mode-map (kbd "C-c p r") #'my/playbook-report))

(provide 'my-playbooks)
;;; my-playbooks.el ends here
