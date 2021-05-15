(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(defvar my-vendor-directory (concat user-emacs-directory "vendor/"))
(add-to-list 'load-path my-vendor-directory)

(setq custom-theme-directory (concat user-emacs-directory "themes/"))

(cond ((eq system-type 'darwin)
       (setq delete-by-moving-to-trash t
             trash-directory "~/.Trash/")
       ;; BSD ls does not support --dired. Use GNU core-utils: brew install coreutils
       (when (executable-find "gls")
         (setq insert-directory-program "gls"))
       ;; Point Org to LibreOffice executable
       (when (file-exists-p "/Applications/LibreOffice.app/Contents/MacOS/soffice")
         (setq org-export-odt-convert-processes '(("LibreOffice" "/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to %f%x --outdir %d %i"))))))

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq-default make-backup-files nil)

(defvar my-private-file (expand-file-name "private.el" user-emacs-directory))
(load my-private-file 'noerror)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

(use-package powerline
      :ensure t
  :config
  (progn
    (setq-default powerline-default-separator
                  (if (display-graphic-p) 'wave 'utf-8))
    (powerline-default-theme)))

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(load-theme 'enox t)

(defadvice load-theme (before theme-dont-propagate activate)
 (mapc #'disable-theme custom-enabled-themes))

(cond
 ((find-font (font-spec :name "Fira Mono"))
  (set-frame-font "Fira Mono-14" t t)
  (setq-default line-spacing 4))
 ((find-font (font-spec :name "Source Code Pro"))
  (set-frame-font "Source Code Pro-14" t t))
 ((find-font (font-spec :name "Panic Sans"))
  (set-frame-font "Panic Sans-14" t t))
 ((find-font (font-spec :name "courier"))
  (set-frame-font "courier-14" t t)))

(global-hl-line-mode)

(setq ring-bell-function 'ignore)

(setq inhibit-startup-screen t)

(setq initial-scratch-message nil)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(defalias 'yes-or-no-p 'y-or-n-p)

(use-package popwin
  :ensure t
  :commands popwin-mode
  :defer 2
  :config
  (progn
    (popwin-mode 1)
    (push '("*Org Agenda*" :width 82 :position right :dedicated t :stick t) popwin:special-display-config)
    (push '("*helm*" :height 20) popwin:special-display-config)
    (push '("^\*helm .+\*$" :regexp t :height 20) popwin:special-display-config)
    (push '("*Compile-Log*" :height 20 :noselect t) popwin:special-display-config)))

(use-package rainbow-delimiters
  :ensure t
  :commands rainbow-delimiters-mode
  :init
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))

(show-paren-mode t)

(use-package rainbow-mode
  :ensure t
  :commands rainbow-turn-on
  :init
  (add-hook 'prog-mode-hook 'rainbow-turn-on)
  :config
  (setq rainbow-x-colors nil))

(setq echo-keystrokes 0.02)

(global-set-key (kbd "RET") 'newline-and-indent)

(use-package evil
  :ensure t
  :init
  (progn
    (setq evil-want-C-w-in-emacs-state t)
    (use-package evil-leader
      :ensure t
      :config
      (progn
        (evil-leader/set-leader "<SPC>")
        (global-evil-leader-mode 1)

        (defun my-declare-prefix (prefix name)
          "Declare a prefix PREFIX. PREFIX is a string describing
a key sequence. NAME is a symbol name used as the prefix command."
          (let ((command (intern (concat "group:" name))))
            ;; Define the prefix command only if it does not already exist
            (unless (lookup-key evil-leader--default-map prefix)
              (define-prefix-command command)
              (evil-leader/set-key prefix command))))

        ;; Define prefix commands for the sake of guide-key
        (setq my-key-binding-prefixes '(("g" . "git")
                                         ("m" . "mode")
                                         ("o" . "toggle")
                                         ("r" . "org")))

        (mapc (lambda (x) (my-declare-prefix (car x) (cdr x)))
              my-key-binding-prefixes)

        (evil-leader/set-key
          "SPC" 'smex
          "m SPC" 'smex-major-mode-commands
          "=" 'my-indent-buffer
          "b" 'ido-switch-buffer
          "B" 'ibuffer
          "d" 'projectile-find-dir
          "D" 'dired
          "e" 'ido-find-file
          "f" 'projectile-find-file
          "k" 'kill-this-buffer
          "K" 'dash-at-point
          "p" 'projectile-switch-project
          "P" 'paradox-list-packages
          "s" 'ansi-term
          "T" 'my-write-timestamped-current-file-copy
          "u" 'undo-tree-visualize
          "w" 'whitespace-cleanup
          "y" 'my-yank-buffer
          "z" 'my-narrow-or-widen
          ;; Option toggle
          "o l" 'whitespace-mode
          "o n" 'linum-mode
          "o q" 'auto-fill-mode
          "o w" 'visual-line-mode)))

    (use-package evil-numbers
      :ensure t
      :config
      (progn
        (define-key evil-normal-state-map "+" 'evil-numbers/inc-at-pt)
        (define-key evil-normal-state-map "_" 'evil-numbers/dec-at-pt))))
  :config
  (progn
    (setq evil-default-cursor '("DodgerBlue1" box)
          evil-normal-state-cursor '("orange" box)
          evil-emacs-state-cursor '("pink" box)
          evil-motion-state-cursor '("SeaGreen1" box)
          evil-insert-state-cursor '("orange" bar)
          evil-visual-state-cursor '("orange" hbar)
          evil-replace-state-cursor '("orange" hbar))

    (evil-mode 1)

    ;; Override the starting state in a few major modes
    (evil-set-initial-state 'magit-mode 'emacs)
    (evil-set-initial-state 'org-agenda-mode 'emacs)
    (evil-set-initial-state 'package-menu-mode 'motion)
    (evil-set-initial-state 'paradox-menu-mode 'motion)
    (evil-set-initial-state 'mu4e-main-mode 'motion)
    (evil-set-initial-state 'mu4e-view-mode 'motion)
    (evil-set-initial-state 'mu4e-headers-mode 'motion)
    (evil-set-initial-state 'elfeed-search-mode 'motion)
    (evil-set-initial-state 'elfeed-show-mode 'motion)

    ;; Reclaim useful keys from evil-motion-state-map
    (define-key evil-motion-state-map (kbd "RET") nil)
    (define-key evil-motion-state-map (kbd "TAB") nil)

    (define-key minibuffer-local-map (kbd "C-w") 'backward-kill-word)

    (define-key evil-motion-state-map "j" 'evil-next-visual-line)
    (define-key evil-motion-state-map "k" 'evil-previous-visual-line)
    (define-key evil-normal-state-map "Y" (kbd "y$"))

    ;; Experimental alternative to C-d, C-u
    (define-key evil-normal-state-map (kbd "C-k") 'evil-scroll-up)
    (define-key evil-normal-state-map (kbd "C-j") 'evil-scroll-down)
    (define-key evil-motion-state-map (kbd "C-k") 'evil-scroll-up)
    (define-key evil-motion-state-map (kbd "C-j") 'evil-scroll-down)

    ;; Commentary.vim
    (use-package evil-operator-comment
      :config
      (global-evil-operator-comment-mode 1))

    ;; Vinegar.vim
    (autoload 'dired-jump "dired-x"
      "Jump to Dired buffer corresponding to current buffer." t)
    (define-key evil-normal-state-map "-" 'dired-jump)
    (evil-define-key 'normal dired-mode-map "-" 'dired-up-directory)

    ;; Unimpaired.vim
    (define-key evil-normal-state-map (kbd "[ SPC")
      (lambda () (interactive) (evil-insert-newline-above) (forward-line)))
    (define-key evil-normal-state-map (kbd "] SPC")
      (lambda () (interactive) (evil-insert-newline-below) (forward-line -1)))
    (define-key evil-normal-state-map (kbd "[ e") (kbd "ddkP"))
    (define-key evil-normal-state-map (kbd "] e") (kbd "ddp"))
    (define-key evil-normal-state-map (kbd "[ b") 'previous-buffer)
    (define-key evil-normal-state-map (kbd "] b") 'next-buffer)))

(defun my-minibuffer-keyboard-quit ()
  "Abort recursive edit.

In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

(define-key minibuffer-local-map [escape] 'my-minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'my-minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'my-minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'my-minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'my-minibuffer-keyboard-quit)

(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)

(defadvice ansi-term (after advise-ansi-term-coding-system)
  (set-buffer-process-coding-system 'utf-8-unix 'utf-8-unix))
(ad-activate 'ansi-term)

(use-package evil-surround
  :ensure t
  :commands global-evil-surround-mode
  :config (global-evil-surround-mode 1)
  :defer 2)

(use-package smartparens-config
  :ensure smartparens
  :diminish smartparens-mode
  :commands smartparens-global-mode
  :defer 2
  :config
  (progn
    (smartparens-global-mode t)
    ;; Smartparens manipulations
    ;; See all of them here:
    ;; https://github.com/Fuco1/smartparens/wiki/Working-with-expressions
    (evil-define-key 'normal emacs-lisp-mode-map
      (kbd "C-S-k") 'sp-split-sexp
      (kbd "C-S-j") 'sp-join-sexp
      (kbd "C-S-l") 'sp-forward-slurp-sexp
      (kbd "C-S-h") 'sp-backward-slurp-sexp
      (kbd "C-M-l") 'sp-forward-barf-sexp
      (kbd "C-M-h") 'sp-backward-barf-sexp)

    ;; Fix handling of {} and [] when hitting RET inside
    (defun my-sp/pair-on-newline (id action context)
      "Put trailing pair on newline and return to point."
      (save-excursion
        (newline)
        (indent-according-to-mode)))

    (defun my-sp/pair-on-newline-and-indent (id action context)
      "Open a new brace or bracket expression, with relevant newlines and indent."
      (my-sp/pair-on-newline id action context)
      (indent-according-to-mode))

    (sp-pair "{" nil :post-handlers
             '(:add ((lambda (id action context)
                       (my-sp/pair-on-newline-and-indent id action context)) "RET")))
    (sp-pair "[" nil :post-handlers
             '(:add ((lambda (id action context)
                       (my-sp/pair-on-newline-and-indent id action context)) "RET")))))

(defun my-yank-buffer ()
  "Copy entire buffer to clipboard."
  (interactive)
  (clipboard-kill-ring-save (point-min) (point-max)))

(defun my-delete-current-file ()
  "Delete the file associated with the current buffer and close the
buffer. When no file is associated with the buffer, the buffer is
closed only."
  (interactive)
  (let ((current (buffer-file-name)))
    (kill-buffer (current-buffer))
    (when current
      (delete-file current))))


(with-eval-after-load 'evil
  (evil-ex-define-cmd "R[emove]" 'my-delete-current-file))

(setq scroll-conservatively 999        ; Never recenter the window on the cursor
      mouse-wheel-scroll-amount '(1))  ; Slower mouse wheel/trackpad scrolling

(use-package move-border
  :commands (move-border-left
             move-border-right
             move-border-up
             move-border-down)
  :init
  (progn
    (define-key evil-normal-state-map (kbd "<left>") 'move-border-left)
    (define-key evil-normal-state-map (kbd "<right>") 'move-border-right)
    (define-key evil-normal-state-map (kbd "<up>") 'move-border-up)
    (define-key evil-normal-state-map (kbd "<down>") 'move-border-down)))

(defun my-narrow-or-widen (p)
  "If the buffer is narrowed, it widens. Otherwise, it narrows intelligently.
Intelligently means: region, org-src-block, org-subtree, or defun,
whichever applies first.
Narrowing to org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is already
narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p))
         (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((and (boundp 'org-src-mode) org-src-mode (not p))
         (org-edit-src-exit))
        ((derived-mode-p 'org-mode)
         (cond ((org-in-src-block-p)
                (org-edit-src-code))
               ((org-at-block-p)
                (org-narrow-to-block))
               (t (org-narrow-to-subtree))))
        (t (narrow-to-defun))))

(setq-default indent-tabs-mode nil)

(defun my-indent-use-tabs ()
  (setq indent-tabs-mode t))
(add-hook 'markdown-mode-hook 'my-indent-use-tabs)
(add-hook 'web-mode-hook 'my-indent-use-tabs)

(use-package dtrt-indent
  :ensure t
  :config (dtrt-indent-mode 1))

(setq require-final-newline t) ; auto-insert final newlines in all files

(use-package whitespace
  :ensure t
  :commands (whitespace-cleanup
             whitespace-mode)
  :config
  (progn
    (setq whitespace-line-column nil) ; Use value of fill-column
    (setq whitespace-style '(face
                             tabs
                             spaces
                             trailing
                             lines-tail
                             space-before-tab
                             newline
                             indentation
                             empty
                             space-after-tab
                             space-mark
                             tab-mark
                             newline-mark))))

(defun my-indent-buffer ()
        (interactive)
        (save-excursion
                (indent-region (point-min) (point-max) nil)))

(defun my-show-trailing-whitespace ()
        (interactive)
        (setq show-trailing-whitespace t))

(add-hook 'prog-mode-hook
          'my-show-trailing-whitespace)

(setq comment-auto-fill-only-comments t)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'prog-mode-hook 'turn-on-auto-fill)

(use-package flycheck
  :ensure t
  :commands global-flycheck-mode
  :defer 2
  :config
  (progn
    (global-flycheck-mode 1)
    (setq-default flycheck-disabled-checkers '(html-tidy emacs-lisp-checkdoc))))

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :config
  (setq undo-tree-visualizer-diff t
        undo-tree-visualizer-timestamps t))

(use-package magit
  :ensure t
  :commands (magit-status magit-diff magit-log magit-blame-mode)
  :init
  (evil-leader/set-key
    "g s" 'magit-status
    "g b" 'magit-blame-mode
    "g l" 'magit-log
    "g d" 'magit-diff
    "g r" 'vc-revert)
  :config
  (progn
    (evil-make-overriding-map magit-mode-map 'emacs)
    (define-key magit-mode-map "\C-w" 'evil-window-map)
    (evil-define-key 'emacs magit-mode-map "j" 'magit-goto-next-section)
    (evil-define-key 'emacs magit-mode-map "k" 'magit-goto-previous-section)
    (evil-define-key 'emacs magit-mode-map "K" 'magit-discard-item))) ; k

(use-package git-gutter-fringe
  :ensure t
  :diminish git-gutter-mode
  :config
  (progn
    (global-git-gutter-mode t)

    (evil-leader/set-key "g u u" 'global-git-gutter-mode)))

(use-package emacs-lisp-mode
  :init
  (progn
    (evil-leader/set-key-for-mode 'emacs-lisp-mode
      "m C" 'byte-compile-file
      "m e" 'eval-defun
      "m E" 'eval-buffer
      "m x" 'eval-last-sexp
      "m X" 'eval-print-last-sexp)

    (use-package eldoc
      :commands turn-on-eldoc-mode
      :init (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)))
  :mode ("Cask" . emacs-lisp-mode))

(defun my-byte-recompile ()
  "`byte-compile' every .el file under `user-emacs-directory' recursively"
  (interactive)
  (byte-recompile-directory user-emacs-directory 0)
  (when (fboundp 'sauron-add-event)
    (sauron-add-event 'editor 2 "Byte compiled Emacs directory")))

(defun my-byte-compile-current-buffer ()
  "`byte-compile' current buffer in emacs-lisp-mode if compiled file exists."
  (interactive)
  (when (and (eq major-mode 'emacs-lisp-mode)
             (file-exists-p (byte-compile-dest-file buffer-file-name)))
    (byte-compile-file buffer-file-name)
    (when (fboundp 'sauron-add-event)
      (sauron-add-event 'editor 2 "Byte compiled buffer"))))

(add-hook 'after-save-hook 'my-byte-compile-current-buffer)

(use-package restclient
  :ensure t
  :mode ("\\.http\\'" . restclient-mode)
  :config
  (progn
    (evil-leader/set-key-for-mode 'restclient-mode
      "m m" 'restclient-http-send-current-stay-in-window
      "m s" 'restclient-http-send-current-stay-in-window
      "m S" 'restclient-http-send-current)))

(use-package web-mode
  :ensure t
  :mode (("\\.html?\\'" . web-mode)
         ("\\.php\\'" . web-mode)
         ("\\.css\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.erb\\'" . web-mode))
  :init
  (add-hook 'web-mode-hook (lambda ()
                             (set-fill-column 120))))

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(use-package haskell-mode
  :ensure t
  :mode "\\.hs\\'")
(use-package hindent
  :ensure t)
(org-babel-do-load-languages
 'org-babel-load-languages '((haskell . t)))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :defer 2
  :config
  (progn
    ;; Suppress excessive log messages
    (setq yas-verbosity 1
          yas-prompt-functions '(yas-ido-prompt)
          yas-snippet-dir (expand-file-name "snippets" user-emacs-directory))
    (yas-global-mode t)))

(global-set-key (kbd "M-/") 'hippie-expand)

(save-place-mode 1) ; requires emacs 25+

(use-package ido
  :config
  (progn
    (ido-mode t)
    (ido-everywhere t)

    (use-package ido-completing-read+
      :ensure t
      :config (ido-ubiquitous-mode t)))

    (setq ido-enable-flex-matching t
          ido-use-virtual-buffers t
          ido-create-new-buffer 'always) ; Do not prompt when creating new file
    (add-to-list 'ido-ignore-files "\\.DS_Store")

    (add-hook 'ido-setup-hook 'my-ido-setup)

    (defun my-ido-setup ()
      "Add Evil-mode-like key bindings for ido."
      (define-key ido-completion-map (kbd "C-j") 'ido-next-match)
      (define-key ido-completion-map (kbd "C-k") 'ido-prev-match)
      (define-key ido-buffer-completion-map (kbd "C-d") 'ido-kill-buffer-at-head) ; Originally C-k
      (define-key ido-file-completion-map (kbd "C-d") 'ido-delete-file-at-head)
      (define-key ido-file-completion-map (kbd "C--") 'ido-enter-dired)) ; Originally C-d

    (use-package ido-vertical-mode
      :ensure t
      :config
      (ido-vertical-mode)))

(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands))
  :config
  (progn
    (setq smex-history-length 10)
    (setq smex-flex-matching t)
    (smex-initialize)))

(use-package guide-key
  :disabled t
  :ensure t
  :diminish guide-key-mode
  :commands guide-key-mode
  :defer 2
  :config
  (progn
    (setq guide-key/recursive-key-sequence-flag t
          guide-key/align-command-by-space-flag t
          guide-key/popup-window-position 'bottom)

    (setq guide-key/highlight-command-regexp
          '("group:" . guide-key/prefix-command-face))

    ;; Sequences of interest globally
    (setq guide-key/guide-key-sequence '("SPC"     ; Evil leader key
                                         "\["
                                         "\]"
                                         "g"
                                         "z"
                                         "C-h"     ; Help commands
                                         "C-x r"   ; Register commands
                                         "C-x 4"   ; Other window commands
                                         "C-x 5"   ; Other frame commands
                                         "C-x c"   ; Helm prefix
                                         "C-c"))   ; Mode commands

    ;; Sequences of interest for specific modes
    (defun guide-key/my-hook-function-for-org-mode ()
      (guide-key/add-local-highlight-command-regexp "org-"))
    (add-hook 'org-mode-hook #'guide-key/my-hook-function-for-org-mode)

    (defun guide-key/my-hook-function-for-markdown-mode ()
      (guide-key/add-local-highlight-command-regexp "markdown-\\|outline-"))
    (add-hook 'markdown-mode-hook #'guide-key/my-hook-function-for-markdown-mode)

    (defun guide-key/my-hook-function-for-mail-modes ()
      (guide-key/add-local-highlight-command-regexp "message-\\|mail-\\|mml-"))
    (add-hook 'mu4e-compose-mode-hook #'guide-key/my-hook-function-for-mail-modes)
    (add-hook 'mu4e-headers-mode-hook #'guide-key/my-hook-function-for-mail-modes)
    (add-hook 'mu4e-view-mode-hook #'guide-key/my-hook-function-for-mail-modes)

    (guide-key-mode 1)))

(use-package org
  :ensure org-plus-contrib
  :config
  (progn
    (use-package evil-org
      :diminish evil-org-mode)
    (use-package org-mac-link
      :commands org-mac-grab-link)

    ;; Track habits
    (add-to-list 'org-modules 'org-habit)
    (use-package org-habit
      :config
      (setq org-habit-show-habits-only-for-today t
            org-habit-show-done-always-green t))

    (setq org-directory "~/org"
          org-default-notes-file (expand-file-name "inbox.org" org-directory))
    (use-package org-tempo)
    (use-package org-contacts
      :config
      (setq org-contacts-files `(,(expand-file-name "contacts.org" org-directory))
            org-contacts-icon-use-gravatar nil))

    (defun my-ledger-org-read-date ()
      "Read date in an Org mode capture template in the format that
Ledger expects. Includes a custom prompt string."
      (let ((org-read-date-prefer-future nil))
        (replace-regexp-in-string "-" "/"
                                  (org-read-date nil nil nil "Transaction"))))

    (defun my-ledger-org-read-account ()
      "Read account name using `ido-completing-read'"
      (ido-completing-read "Account: "
                           (split-string
                            (with-output-to-string
                              (shell-command "ledger --permissive accounts" standard-output))
                            "\n" t)))

    (defun my-ledger-org-read-payee ()
      "Read payee name using `ido-completing-read'"
      (ido-completing-read "Payee: "
                           (split-string
                            (with-output-to-string
                              (shell-command "ledger --permissive payees" standard-output))
                            "\n" t)))

    (setq org-capture-templates
          '(("t" "☑️ To-do" entry
             (file+headline "" "Tasks")
             "* TODO %?\nSCHEDULED: %t"
             :clock-keep t :kill-buffer t)
            ("n" "📔 Note" entry
             (file+headline "" "Notes")
             "* Note taken on %U\n%?"
             :clock-keep t :kill-buffer t :jump-to-captured t)
            ("j" "📆 Journal entry" entry
             (file+olp+datetree "diary.org")
             "* %?\n%U\n"
             :time-prompt t :clock-keep t :kill-buffer t)
            ("e" "🗓️ Calendar event" entry
             (file+olp+datetree "diary.org")
             "* %^{Event name}%^{Location}p\n%T\n%?"
             :time-prompt t :clock-keep t :kill-buffer t)
            ("f" "🛫️ Flight" entry
             (file+olp+datetree "diary.org")
             "* %^{From} ✈ %^{To}  :flight:\n%T\n%?"
             :time-prompt t :clock-keep t :kill-buffer t)
            ("p" "📓 Phrase" entry
             (file+headline "vocabulary.org" "Phrases")
             "* %?"
             :clock-keep t :kill-buffer t :jump-to-captured t)
            ("c" "👤 Contact" entry
             (file+headline "contacts.org" "People")
             "* %(org-contacts-template-name)\n:PROPERTIES:\n:EMAIL: %(org-contacts-template-email)\n:END:"
             :clock-keep t :kill-buffer t)
            ("r" "🍲 Recipe" entry
             (file+headline "food.org" "Recipes")
             "* %^{Recipe Name}%^{source}p%^{serves}p%^{time}p\n\n** Ingredients\n\n** Preparation"
             :clock-keep t :empty-lines 1 :kill-buffer t)
            ("R" "🍴 Restaurant" entry
             (file+headline "food.org" "Restaurants")
             "* %^{Restaurant Name}\n%u\n"
             :clock-keep t :empty-lines 1 :kill-buffer t)
            ("k" "🔠 Keyboards" entry
             (file+headline "keyboards.org" "Keyboard Gallery")
             "* %^{Title}%^{source}p\n#+CAPTION: %^{Caption text}\n%?"
             :clock-keep t :jump-to-captured t)))

    (setq org-goto-interface 'outline-path-completion
          org-log-done 'time
          org-log-into-drawer t
          org-treat-S-cursor-todo-selection-as-state-change nil ; Cycle through TODO states with S-Left/Right skipping logging
          org-deadline-warning-days 1
          org-refile-targets '((org-agenda-files :maxlevel . 2))
          org-refile-target-verify-function 'my-verify-refile-target
          org-refile-allow-creating-parent-nodes 'confirm
          org-refile-use-outline-path t
          org-outline-path-complete-in-steps nil
          org-completion-use-ido t
          org-indirect-buffer-display 'current-window
          org-return-follows-link t
          org-catch-invisible-edits 'show-and-error)

    (setq org-todo-keywords '((sequence
                               "TODO(t)"
                               "FOCUS(f)"
                               "STARTED(s!)"
                               "WAITING(w@/!)"
                               "|"
                               "CANCELED(c@)"
                               "DONE(d!)"
                               )))

    (defun my-verify-refile-target ()
      "Exclude TODO keywords with a done state from refile targets"
      (not (member (nth 2 (org-heading-components)) org-done-keywords)))

    (setq org-startup-indented t)

    (use-package ob-restclient
      :ensure t)

    ;; Code blocks
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       (ledger . t)
       (restclient . t)
       (ruby . t)
       (python . t)
       (shell . t)))
    (setq org-src-fontify-natively t
          org-edit-src-content-indentation 0
          org-src-tab-acts-natively t
          org-confirm-babel-evaluate nil)))

(with-eval-after-load 'org-capture
  (define-key org-capture-mode-map [remap evil-save-and-close]          'org-capture-finalize)
  (define-key org-capture-mode-map [remap evil-save-modified-and-close] 'org-capture-finalize)
  (define-key org-capture-mode-map [remap evil-quit]                    'org-capture-kill))

(use-package org-autolist
  :ensure t
  :diminish org-autolist-mode
  :commands org-autolist-mode
  :init
  (progn
    (add-hook 'org-mode-hook #'org-autolist-mode)))

(setq org-tag-alist '((:startgroup)
                      ("@work" . ?W)     ; Contexts
                      ("@home" . ?H)
                      ("@school" . ?S)
                      ("@errand" . ?E)
                      (:endgroup)
                      ("build" . ?b)     ; Task types
                      ("earn" . ?e)
                      ("learn" . ?l)
                      ("focus" . ?f)     ; Task statuses
                      ("someday" . ?s)
                      ("delegate" . ?d)))

(setq org-hide-emphasis-markers t
      org-export-with-section-numbers nil
      org-export-with-tags 'not-in-toc
      org-export-with-toc 1
      org-export-backends '(html
                            latex
                            md
                            icalendar)
      org-html-htmlize-output-type nil
      org-html-doctype "html5"
      org-html-preamble nil
      org-html-postamble t
      org-html-postamble-format '(("en" "<time>%T</time>"))
      org-html-head-include-default-style nil
      org-html-head-include-scripts nil
      org-html-head nil
      org-html-text-markup-alist '((bold . "<strong>%s</strong>")
                                   (code . "<code>%s</code>")
                                   (italic . "<em>%s</em>")
                                   (strike-through . "<del>%s</del>")
                                   (underline . "<dfn>%s</dfn>") ; Somewhat arbitrary
                                   (verbatim . "<kbd>%s</kbd>")))

(setq org-latex-toc-command "\\pagebreak \\tableofcontents \\clearpage")

;; Org mode - http://orgmode.org/guide/Activation.html#Activation
(evil-leader/set-key
  "a"   'org-agenda
  "c"   'org-capture
  "r b" 'org-iswitchb
  "r c" 'my-open-org-calendar
  "r l" 'org-store-link)

(evil-leader/set-key-for-mode 'org-mode
  "m A" 'org-archive-subtree-default
  "m a" 'org-archive-subtree-default-with-confirmation
  "m d" 'org-deadline
  "m e" 'org-export-dispatch
  "m g" 'org-goto
  "m m" 'org-ctrl-c-ctrl-c
  "m P" 'org-set-property-and-value
  "m p" 'org-set-property
  "m q" 'org-set-tags-command
  "m r" 'org-refile
  "m s" 'org-schedule
  "m t" 'org-todo)

(with-eval-after-load 'org-agenda
  ;; Use the standard Org agenda bindings as a base
  (evil-make-overriding-map org-agenda-mode-map 'emacs t)
  (evil-define-key 'emacs org-agenda-mode-map "j" 'org-agenda-next-line)
  (evil-define-key 'emacs org-agenda-mode-map "k" 'org-agenda-previous-line)
  (evil-define-key 'emacs org-agenda-mode-map (kbd "C-j") 'org-agenda-goto-date) ; "j"
  (evil-define-key 'emacs org-agenda-mode-map "n" 'org-agenda-capture))          ; "k"

;; Enable word wrap in org-mode
(add-hook 'org-mode-hook #'(lambda ()
                             (toggle-word-wrap)
                             (visual-line-mode)))

(use-package org-clock
  :config
  (progn
    (setq org-clock-persist t
          ;; Do not prompt to resume an active clock
          ;org-clock-persist-query-resume nil
          ;; Resume clocking task on clock-in if the clock line is open
          org-clock-in-resume t
          org-clock-in-switch-to-state "STARTED"
          org-clock-out-remove-zero-time-clocks t
          org-clock-out-when-done t
          org-clock-idle-time 20
          ;; Include current clocking task in clock reports
          org-clock-report-include-clocking-task t)

    ;; Resume clocking tasks when emacs is restarted
    (org-clock-persistence-insinuate)))

(use-package org-agenda
  :commands (org-agenda org-agenda-list)
  :config
  (setq org-agenda-files `(,org-directory)
        org-agenda-skip-unavailable-files t
        org-agenda-skip-deadline-if-done nil
        org-agenda-skip-scheduled-if-done nil
        org-agenda-restore-windows-after-quit t
        org-agenda-window-setup 'current-window
        org-agenda-show-all-dates t
        org-agenda-show-log t
        org-agenda-diary-file (expand-file-name "diary.org" org-directory)
        org-agenda-include-diary t))

(setq holiday-bahai-holidays nil
      holiday-islamic-holidays nil
      holiday-oriental-holidays nil)

(use-package calfw
  :ensure t
  :config
  (setq cfw:fchar-junction ?╋
        cfw:fchar-vertical-line ?┃
        cfw:fchar-horizontal-line ?━
        cfw:fchar-left-junction ?┣
        cfw:fchar-right-junction ?┫
        cfw:fchar-top-junction ?┳
        cfw:fchar-top-left-corner ?┏
        cfw:fchar-top-right-corner ?┓))

(use-package calfw-org
  :ensure t)

(defun my-open-org-calendar ()
  "Open an org schedule calendar in a new buffer.

This function is adapted from cfw:open-org-calendar."
  (interactive)
  (save-excursion
    (let* ((source1 (cfw:org-create-source "SkyBlue"))
           (cp (cfw:create-calendar-component-buffer
                :view 'month
                :contents-sources (list source1)
                :custom-map cfw:org-schedule-map
                :sorter 'cfw:org-schedule-sorter)))
      (switch-to-buffer (cfw:cp-get-buffer cp)))))

(use-package org-ref
  :ensure t)
(use-package org-ref-pdf)
(use-package org-ref-url-utils)
