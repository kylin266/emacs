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
          (unless (or (string-prefix-p "_" (file-name-nondirectory f))
                      (string-match-p "/runs/" f))   ; reports are not playbooks
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
      (when (and (or (and session (not (string= session "none")) (string= (buffer-name b) session))
                     (string-match-p "\\`\\*\\(playbook\\)" (buffer-name b)))
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

(defun my/playbook--vars-line ()
  "The :var part of the file's #+PROPERTY line, or nil."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^#\\+PROPERTY: header-args[^\n]*:var \\(.*\\)$" nil t)
      (match-string-no-properties 1))))

(defun my/playbook--classify (body res)
  "Classify a block from its BODY and result RES.
A block whose body prints an \"(empty = ...)\" or \"(... )\" pass line is a check:
pass when the result is only such lines, finding otherwise. A block without one
is information. Return one of finding info pass running missing."
  (let* ((lines (and res (seq-remove #'string-empty-p (mapcar #'string-trim (split-string res "\n")))))
         (sentinel (string-match-p "echo \"(" body)))
    (cond ((null res) 'missing)
          ((and (= (length lines) 1) (string-match-p "\\`[0-9a-f-]\\{32,36\\}\\'" (car lines))) 'running)
          ((null lines) (if sentinel 'pass 'info))
          ((and sentinel (seq-every-p (lambda (l) (or (string-prefix-p "(" l) (string-prefix-p "==" l))) lines)) 'pass)
          (sentinel 'finding)
          (t 'info))))

(defun my/playbook-report (&optional quiet)
  "Gather every block's result in this playbook into a dated report and open it beside.
Report goes to runs/<date>-<playbook>.org next to the playbook (never committed).
With QUIET, refresh the report buffer without changing windows or focus."
  (interactive)
  (unless (derived-mode-p 'org-mode) (user-error "Not in a playbook"))
  (let* ((src buffer-file-name)
         (name (file-name-base src))
         (dir (expand-file-name "runs" (file-name-directory src)))
         (out (expand-file-name (format "%s-%s.org" (format-time-string "%Y-%m-%d") name) dir))
         (vars (my/playbook--vars-line))
         sections)
    (org-babel-map-src-blocks nil
      (let* ((area (or (car (org-get-outline-path)) (org-get-heading t t t t)))
             (check (if (org-get-outline-path) (org-get-heading t t t t) ""))
             (res (my/playbook--result-text (org-babel-where-is-src-block-result)))
             (status (my/playbook--classify body res))
             (n (if res (length (seq-remove #'string-empty-p (split-string (string-trim res) "\n"))) 0)))
        (push (list area check status res n) sections)))
    (setq sections (nreverse sections))
    (let ((count (lambda (st) (seq-count (lambda (x) (eq (nth 2 x) st)) sections))))
      (make-directory dir t)
      (with-temp-file out
        (insert (format "#+TITLE: %s report\n#+STARTUP: showall\n#+OPTIONS: ^:nil\n\n" name))
        (insert (format "Run of =%s= at %s" name (format-time-string "%Y-%m-%d %H:%M")))
        (when vars (insert (format " with =%s=" vars)))
        (insert ".\n\n")
        (insert (format "| Findings | Information | Passed | Running | Not run |\n|---|---|---|---|---|\n| %d | %d | %d | %d | %d |\n\n"
                        (funcall count 'finding) (funcall count 'info) (funcall count 'pass) (funcall count 'running) (funcall count 'missing)))
        (insert "| Area | Check | Status | Lines |\n|---|---|---|---|\n")
        (dolist (sec sections)
          (pcase-let ((`(,area ,check ,status ,_ ,n) sec))
            (insert (format "| %s | %s | %s | %d |\n" area check
                            (pcase status ('finding "FINDING") ('info "info") ('pass "ok") ('running "running") ('missing "not run")) n))))
        (insert "\n")
        (when (> (funcall count 'finding) 0)
          (insert "* Findings\n")
          (dolist (sec sections)
            (pcase-let ((`(,area ,check ,status ,res ,_) sec))
              (when (eq status 'finding)
                (insert (format "** %s: %s\n#+begin_example\n%s\n#+end_example\n\n" area check (string-trim res)))))))
        (when (> (funcall count 'info) 0)
          (insert "* Information\n")
          (dolist (sec sections)
            (pcase-let ((`(,area ,check ,status ,res ,_) sec))
              (when (eq status 'info)
                (insert (format "** %s: %s\n#+begin_example\n%s\n#+end_example\n\n" area check (string-trim res)))))))
        (when (> (funcall count 'pass) 0)
          (insert "* Passed\n")
          (dolist (sec sections)
            (pcase-let ((`(,area ,check ,status ,res ,_) sec))
              (when (eq status 'pass)
                (insert (format "- %s: %s  %s\n" area check (string-trim (or res ""))))))))
        (when (> (+ (funcall count 'running) (funcall count 'missing)) 0)
          (insert "\n* Not finished\n")
          (dolist (sec sections)
            (pcase-let ((`(,area ,check ,status ,_ ,_) sec))
              (when (memq status '(running missing))
                (insert (format "- %s: %s  (%s)\n" area check (if (eq status 'running) "still running" "not run"))))))))
      (let ((buf (find-file-noselect out)))
        (with-current-buffer buf (revert-buffer t t t) (setq-local my/playbook--report-source src) (goto-char (point-min)))
        (if quiet
            (message "report refreshed: %d findings, %d info, %d ok" (funcall count 'finding) (funcall count 'info) (funcall count 'pass))
          (pop-to-buffer buf '((display-buffer-in-side-window) (side . right) (window-width . 0.5)))
          (message "report: %s  (%d findings, %d info, %d ok)" (abbreviate-file-name out) (funcall count 'finding) (funcall count 'info) (funcall count 'pass)))))))
(defvar-local my/playbook--report-source nil "Playbook file this report was built from.")
(defun my/playbook--refresh-open-reports ()
  "Rebuild every report buffer that is currently open, from its playbook."
  (dolist (b (buffer-list))
    (let ((src (buffer-local-value (quote my/playbook--report-source) b)))
      (when (and src (get-buffer-window b t) (get-file-buffer src))
        (with-current-buffer (get-file-buffer src) (my/playbook-report t))))))

;;; Progress in the modeline while blocks run in the background.
(defvar my/playbook--timer nil)
(defvar my/playbook--progress "" "Modeline text, e.g. \" ▶ s5-domain 5/16\".")
(defun my/playbook--counts (buf)
  "Return (DONE . PENDING) result counts for playbook buffer BUF."
  (with-current-buffer buf
    (save-excursion
      (goto-char (point-min))
      (let ((done 0) (pending 0))
        (while (re-search-forward "^#\\+results:\n\\(?:: \\([0-9a-f-]\\{32,36\\}\\)$\\|\\(: \\|\\[\\[file:\\|#\\+begin_example\\)\\)" nil t)
          (if (match-string 1) (setq pending (1+ pending)) (setq done (1+ done))))
        (cons done pending)))))
(defun my/playbook--refresh-progress ()
  (let (parts (any-pending nil))
    (dolist (b (buffer-list))
      (when (buffer-live-p b)
        (with-current-buffer b
          (when (and buffer-file-name (derived-mode-p 'org-mode) (my/playbook-in-playbook-dir-p))
            (let* ((c (my/playbook--counts b)) (done (car c)) (pending (cdr c)))
              (when (> pending 0)
                (setq any-pending t)
                (push (format "▶ %s %d/%d" (file-name-base buffer-file-name) done (+ done pending)) parts)))))))
    (setq my/playbook--progress (if parts (concat " " (string-join (nreverse parts) " ")) ""))
    (force-mode-line-update t)
    (unless any-pending
      (when my/playbook--timer (cancel-timer my/playbook--timer) (setq my/playbook--timer nil))
      (my/playbook--refresh-open-reports)
      (message "playbook: all blocks finished (, r for the report)"))))
(defun my/playbook--start-progress (&rest _)
  (when (and buffer-file-name (my/playbook-in-playbook-dir-p) (not my/playbook--timer))
    (setq my/playbook--timer (run-at-time 1 2 #'my/playbook--refresh-progress))))
(advice-add 'org-babel-execute-src-block :after #'my/playbook--start-progress)
(add-to-list 'global-mode-string '(:eval my/playbook--progress) t)

;;; Set a playbook variable (account, region, group ...) with completion.
(defun my/playbook--var-candidates (var)
  (pcase var
    ((or "P" "P1" "P2" "AWS") (my/aws-profiles))
    ((or "R" "REGION") '("ap-southeast-1" "ap-southeast-2" "ap-southeast-5" "us-east-1" "eu-central-1" "eu-west-3"))
    (_ nil)))
(defun my/playbook--source-buffer ()
  "The playbook buffer for the current context: this buffer, or the playbook a report was built from."
  (cond ((and (boundp 'my/playbook--report-source) my/playbook--report-source)
         (or (get-file-buffer my/playbook--report-source) (find-file-noselect my/playbook--report-source)))
        (t (current-buffer))))

(defun my/playbook-set-var (var value)
  "Change VAR to VALUE in this playbook's #+PROPERTY :var line.
Prompts with the file's own variables; P/P1/P2 complete from ~/.aws/config profiles.
Works from the playbook or from its report page."
  (interactive
   (let* ((line (with-current-buffer (my/playbook--source-buffer)
                  (or (my/playbook--vars-line) (user-error "No :var line in this playbook (are you in a playbook or its report?)"))))
          (pairs (let (acc (start 0)) (while (string-match "\\([A-Za-z_][A-Za-z0-9_]*\\)=\"\\([^\"]*\\)\"" line start) (push (cons (match-string 1 line) (match-string 2 line)) acc) (setq start (match-end 0))) (nreverse acc)))
          (var (completing-read "Variable: " (mapcar (lambda (p) (format "%s=%s" (car p) (cdr p))) pairs) nil t))
          (var (car (split-string var "="))))
     (list var (completing-read (format "%s = " var) (my/playbook--var-candidates var) nil nil (alist-get var pairs nil nil #'string=)))))
  (with-current-buffer (my/playbook--source-buffer)
    (save-excursion
      (goto-char (point-min))
      (unless (re-search-forward (format "^#\\+PROPERTY: header-args[^\n]*:var [^\n]*\\b%s=\"[^\"]*\"" (regexp-quote var)) nil t)
        (user-error "Variable %s not in the :var line" var))
      (re-search-backward (format "%s=\"[^\"]*\"" (regexp-quote var)))
      (replace-match (format "%s=\"%s\"" var value) t t)
      (org-set-regexps-and-options)
      (message "%s=%s in %s (rerun the playbook for new results)" var value (buffer-name)))))

(defun my/playbook-use-aws-profile ()
  "Set this playbook's account variable(s) to the AWS profile you pick (P, or P1/P2)."
  (interactive)
  (let ((line (with-current-buffer (my/playbook--source-buffer) (or (my/playbook--vars-line) (user-error "No :var line")))))
    (cond ((string-match-p "\\bP=\"" line)
           (my/playbook-set-var "P" (completing-read "AWS profile for P: " (my/aws-profiles) nil nil (getenv "AWS_PROFILE"))))
          ((string-match-p "\\bP1=\"" line)
           (my/playbook-set-var "P1" (completing-read "AWS profile for P1: " (my/aws-profiles) nil nil "s5-t1"))
           (my/playbook-set-var "P2" (completing-read "AWS profile for P2: " (my/aws-profiles) nil nil "s5-t2")))
          (t (user-error "This playbook has no account variable")))))

(defun my/playbook-report-html ()
  "Export today's report of this playbook to HTML and open it in the browser."
  (interactive)
  (let* ((src (or my/playbook--report-source buffer-file-name))
         (name (file-name-base src))
         (dir (expand-file-name "runs" (file-name-directory src)))
         (org (expand-file-name (format "%s-%s.org" (format-time-string "%Y-%m-%d") name) dir))
         (html (concat (file-name-sans-extension org) ".html")))
    (unless (file-exists-p org) (user-error "No report yet; press , r first"))
    (unless (executable-find "pandoc") (user-error "pandoc not found"))
    (call-process "pandoc" nil nil nil "-s" "--metadata" (format "title=%s report" name)
                  "-c" "https://cdn.jsdelivr.net/npm/water.css@2/out/water.css" org "-o" html)
    (browse-url (concat "file://" html))))

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
  (define-key org-mode-map (kbd "C-c p r") #'my/playbook-report)
  (define-key org-mode-map (kbd "C-c p v") #'my/playbook-set-var)
  (define-key org-mode-map (kbd "C-c p A") #'my/playbook-use-aws-profile)
  (define-key org-mode-map (kbd "C-c p R") #'my/playbook-report-html))

(provide 'my-playbooks)
;;; my-playbooks.el ends here
