;;; emacs-config --- My emacs config

;;; Commentary:
;;; This is my (currently often changing) Emacs config

;;; Code:

(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package '(use-package sly corfu org))
  (unless (package-installed-p package)
    (package-install package)))

(scroll-bar-mode -1)
(load-theme 'leuven) ;; light theme
(setq pixel-scroll-precision-mode 1)
(xterm-mouse-mode 1)

(setq standard-indent 2)
(setq create-lockfiles nil)
(setq delete-old-versions -1)
(setq make-backup-files nil) ; stop creating ~ files
(setq version-control t)
(setq coding-system-for-write 'utf-8)
(setq-default indent-tabs-mode nil) ;; use spaces, not tabs
(setq show-paren-delay 0)
(show-paren-mode)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; general purpose emacs settings
(use-package emacs
  :init

  ;; do not allow cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; support opening new minibuffers from inside existing minibuffers
  (setq enable-recursive-minibuffers t)

  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode. Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; org-mode
(use-package org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;; =============== plugins ==================

;; Corfu - COmpletion in Region FUnction
;; https://github.com/minad/corfu
(declare-function global-corfu-mode "proced")
(declare-function corfu-history-mode "proced")
(declare-function corfu-mode "proced")
(defvar corfu-map)
(use-package corfu
  :custom
  (corfu-cycle-tab t)
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-quit-at-boundary 'separator)
  (corfu-echo-documentation 0.5)
  (corfu-preview-current 'insert)
  (corfu-preselect 'prompt)
  :bind (:map corfu-map
              ("M-SPC" . corfu-insert-separator)
              ("RET" . nil)
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous)
              ("S-<return>" . corfu-insert))
  :init
  (global-corfu-mode)
  (corfu-history-mode)

  :config
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-quit-at-boundary t
                          corfu-quit-no-match t
                          corfu-auto nil)
              (corfu-mode))))

;; Marginalia - Marginalia in the minibuffer
;; https://github.com/minad/marginalia
(declare-function marginalia-mode "proced")
(use-package marginalia
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

;; == Fancy icons ==
;; all-the-icons
;; https://github.com/domtronn/all-the-icons.el
(use-package all-the-icons
  :if (display-graphic-p))

;; ... also in completions
(declare-function all-the-icons-completion-mode "proced")
(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia . all-the-icons-completion-marginalia-setup)
  :init (all-the-icons-completion-mode))

;; vectico.el - VERTical Interactive COmpletion
;; https://github.com/minad/vertico
(declare-function vertico-mode "proced")
(use-package vertico
  :init (vertico-mode)
  :custom (vertico-count 13)
  (vertico-resize t)
  (vertico-cycle nil)
  :config (vertico-mode))

;; orderless - completion
;; This allows searching for space separated terms in any order
;; https://github.com/oantolin/orderless
(use-package orderless
  :init (setq completion-styles '(orderless basic)
              completion-category-defaults nil
              completion-category-overrides '((file (styles partial-completion)))))
              

;; markdown mode
;; https://jblevins.org/projects/markdown-mode/
(defvar markdown-command)
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;; Minibuffer with help when waiting too long
;; In emacs per default with Emacs v30
(declare-function which-key-mode "proced")
(defvar which-key-idle-delay)
(defvar which-key-idle-secondary-delay)
(use-package which-key
  :ensure t
  :config
  (setq which-key-idle-delay 0.1)
  (setq which-key-idle-secondary-delay 0.1)
  (which-key-mode))

;; flycheck - Syntax checking for GNU Emacs¶
;; https://www.flycheck.org/en/latest/
(declare-function global-flycheck-mode "proced")
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; allow the deletion of selected text (don't know why this isn't implemented by default)
(use-package delsel
  :ensure nil ; no need to install it as it is built-in, but needs to be activated
  :hook (after-init . delete-selection-mode))

;; Configure the Lisp program for SLY
(add-to-list 'exec-path "/Users/emile/.nix-profile/bin")
(defvar inferior-lisp-program "sbcl")

;; configure parinfer to be enabled as a mode when the major lisp mode is enabled
(add-to-list 'load-path "/Users/emile/parinfer-rust")
(add-hook 'emacs-lisp-mode 'parinfer-rust-mode)
(declare-function lispy-mode "proced")
(add-hook 'emacs-lisp-mods (lambda () (lispy-mode 1)))

;; pixel perfect ultra precise low latency scrolling
(declare-function ultra-scroll-mode "proced")
(use-package ultra-scroll
     ; if you git clone'd instead of package-vc-install
     ;:load-path "~/code/emacs/ultra-scroll"

     :init
     (setq scroll-conservatively 101 ; important!
         scroll-margin 0)
     :config
     (ultra-scroll-mode 1))

(use-package breadcrumb
     :ensure t)

(provide '.emacs)
;;; emacs_config.el ends here
