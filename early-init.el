;;; early-init.el --- startup tuning -*- lexical-binding: t -*-

(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

(setq package-enable-at-startup nil
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      frame-inhibit-implied-resize t
      native-comp-async-report-warnings-errors 'silent
      load-prefer-newer t)

(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(width . 160) default-frame-alist)
(push '(height . 50) default-frame-alist)
(push '(ns-transparent-titlebar . t) default-frame-alist)

;;; early-init.el ends here
