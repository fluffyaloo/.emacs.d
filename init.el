;; Emacs Configuration for Python, C/C++, and Org-mode Development
;; Place this in ~/.emacs.d/init.el (or %APPDATA%\.emacs.d\init.el on Windows)

;;; Package Management
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; Basic Emacs Settings
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(column-number-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq-default buffer-file-coding-system 'utf-8-unix)
;; Better defaults
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;; Backup directories are now set up by my/setup-backup-dirs function
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode 1)

;; Cross-platform settings
(cond
 ;; Windows-specific settings
 ((eq system-type 'windows-nt)
  (setq w32-pass-lwindow-to-system nil)
  (setq w32-lwindow-modifier 'super)
  ;; Set default directory and other Windows-specific paths
  (setq default-directory "K:/")
  ;; Improve performance on Windows
  (setq w32-pipe-read-delay 0)
  (setq inhibit-compacting-font-caches t))
 
 ;; macOS-specific settings
 ((eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super)
  ;; Use GNU ls if available (for dired)
  (when (executable-find "gls")
    (setq insert-directory-program "gls")))
 
 ;; Linux-specific settings  
 ((eq system-type 'gnu/linux)
  ;; Linux-specific optimizations
  (setq x-gtk-use-system-tooltips nil)))


(defun my/set-font ()
  "Set FiraCode Nerd Font as DEFAULT (for code), FantasqueSansM for variable-pitch."
  (when (display-graphic-p)
    (cond
     ;; Set DEFAULT font to a CODE font (this affects programming modes)
     ((member "FiraCode Nerd Font" (font-family-list))
      (set-face-attribute 'default nil :font "FiraCode Nerd Font-12"))
     ((member "FiraCode NF" (font-family-list))
      (set-face-attribute 'default nil :font "FiraCode NF-12"))
     ((member "FiraMono Nerd Font" (font-family-list))
      (set-face-attribute 'default nil :font "FiraMono Nerd Font-12"))
     ((member "Fira Code" (font-family-list))
      (set-face-attribute 'default nil :font "Fira Code-12"))
     ;; Fallback fonts
     ((member "Consolas" (font-family-list))
      (set-face-attribute 'default nil :font "Consolas-12"))
     ((member "Monaco" (font-family-list))
      (set-face-attribute 'default nil :font "Monaco-12"))
     (t
      (message "No preferred monospace font found, using default")))))

;; Set font after frame creation (handles daemon mode)
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (my/set-font))))
  (my/set-font))

;; Cross-platform org directory configuration
(defun my/get-org-directory ()
  "Get the appropriate org directory based on the operating system."
  (cond
   ((eq system-type 'windows-nt) "K:/org/")
   (t "~/org/")))

;; Cross-platform backup and auto-save directories
(defun my/setup-backup-dirs ()
  "Set up backup and auto-save directories."
  (let ((backup-dir (expand-file-name "backups" user-emacs-directory))
        (auto-save-dir (expand-file-name "auto-save-list" user-emacs-directory)))
    (unless (file-exists-p backup-dir)
      (make-directory backup-dir t))
    (unless (file-exists-p auto-save-dir)
      (make-directory auto-save-dir t))
    (setq backup-directory-alist `(("." . ,backup-dir)))
    (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t)))))

(my/setup-backup-dirs)

;;; Theme and Appearance
(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'frappe) ;; Use Frappé variant
  (load-theme 'catppuccin t)
  
  ;; Optional: Customize specific faces for better appearance
  (catppuccin-reload))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25)
  ;; Customize modeline colors to match Catppuccin
  (setq doom-modeline-bar-width 3))

;;; Completion Framework
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package consult
  :bind (("C-s" . consult-line)
         ("M-y" . consult-yank-pop)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x r b" . consult-bookmark)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("C-c f" . consult-find)
         ("C-c r" . consult-ripgrep)))

;;; Project Management
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired)
  (setq projectile-completion-system 'default))

;;; Git Integration
(use-package magit
  :bind ("C-x g" . magit-status))

;;; Tree-sitter for better syntax highlighting
(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs)

;;; LSP Mode for Language Server Protocol
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; Python
         (python-mode . lsp)
         ;; C/C++
         (c-mode . lsp)
         (c++-mode . lsp)
         ;; Enable which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :config
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-modeline-code-actions-enable nil))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-sideline-enable nil))

;;; Company for auto-completion
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;;; Flycheck for syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;;; Python Development
(use-package python-mode
  :mode "\\.py\\'"
  :config
  (setq python-indent-offset 4))

(use-package pyvenv
  :config
  (pyvenv-mode 1))

;; Black for Python formatting
(use-package python-black
  :demand t
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

;;; C/C++ Development
(use-package cc-mode
  :config
  (setq c-default-style "linux"
        c-basic-offset 4)
  ;; Bind common commands
  :bind (:map c-mode-base-map
         ("C-c C-c" . compile)))

;; Modern C++ font-lock
(use-package modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode))

;;; Org Mode Configuration
(use-package org
  :hook ((org-mode . (lambda () (display-line-numbers-mode -1))))
  :config
  (setq org-directory (my/get-org-directory))
  (setq org-default-notes-file (concat org-directory "notes.org"))
  (setq org-agenda-files (list org-directory))
  
  ;; Ensure org directory exists
  (unless (file-exists-p org-directory)
    (make-directory org-directory t))
  
  ;; Org-mode key bindings
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  
  ;; Better org-mode appearance
  (setq org-hide-emphasis-markers t)
  (setq org-startup-indented t)
  (setq org-pretty-entities t)
  (setq org-startup-with-inline-images t)
  
  ;; Org-babel languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (C . t)
     (shell . t)
     (emacs-lisp . t)))
  
  ;; Don't ask before evaluating code blocks
  (setq org-confirm-babel-evaluate nil)
  
  ;; Cross-platform capture templates
  (setq org-capture-templates
        `(("t" "Todo" entry (file+headline ,(concat org-directory "tasks.org") "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("n" "Note" entry (file+datetree ,(concat org-directory "notes.org"))
           "* %?\nEntered on %U\n  %i\n  %a")
          ("j" "Journal" entry (file+datetree ,(concat org-directory "journal.org"))
           "* %?\nEntered on %U\n  %i\n  %a"))))

;; Mixed typography support for org-mode (from StackOverflow)
;; This preserves colors for org src blocks and tables while making them monospaced
(defun my-adjoin-to-list-or-symbol (element list-or-symbol)
  (let ((list (if (not (listp list-or-symbol))
                  (list list-or-symbol)
                list-or-symbol)))
    (require 'cl-lib)
    (cl-adjoin element list)))

(eval-after-load "org"
  '(mapc
    (lambda (face)
      (set-face-attribute
       face nil
       :inherit
       (my-adjoin-to-list-or-symbol
        'fixed-pitch
        (face-attribute face :inherit))))
    (list 'org-code 'org-block 'org-table 'org-block-begin-line 'org-block-end-line)))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

;; Olivetti for distraction-free writing in org-mode
(use-package olivetti
  :hook (org-mode . olivetti-mode))

;;; File Management
;; Cross-platform dired configuration
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :config
  (cond
   ;; Use GNU ls options on Linux/macOS
   ((or (eq system-type 'gnu/linux) (eq system-type 'darwin))
    (setq dired-listing-switches "-agho --group-directories-first"))
   ;; Windows doesn't have GNU ls by default
   ((eq system-type 'windows-nt)
    (setq dired-listing-switches "-alh")))
  
  ;; Built-in dired enhancements instead of dired-single
  (setq dired-kill-when-opening-new-dired-buffer t) ;; Only keep one dired buffer
  (setq dired-dwim-target t) ;; Guess target directory for operations
  
  ;; Reuse same buffer when navigating directories
  (put 'dired-find-alternate-file 'disabled nil)
  :bind (:map dired-mode-map
         ("RET" . dired-find-alternate-file)
         ("^" . (lambda () (interactive) (find-alternate-file "..")))))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;;; Terminal (cross-platform)
(use-package vterm
  :if (not (eq system-type 'windows-nt))
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

;; Alternative terminal for Windows
(when (eq system-type 'windows-nt)
  (use-package powershell
    :ensure t)
  (defun my/open-terminal ()
    "Open appropriate terminal for the platform."
    (interactive)
    (cond
     ((eq system-type 'windows-nt)
      (powershell))
     (t
      (vterm))))
  (global-set-key (kbd "C-c t") 'my/open-terminal))

;;; Which Key - Shows available keybindings
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

;;; Multiple Cursors
(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

;;; Smart Parentheses
(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;;; Ace Window - Quick window switching
(use-package ace-window
  :bind ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

;;; Dashboard
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5))))

;;; Custom Functions
(defun my/open-config-file ()
  "Open the init.el file."
  (interactive)
  (find-file user-init-file))

(defun my/show-cheat-sheet ()
  "Display a comprehensive cheat sheet for all configured features."
  (interactive)
  (let ((buffer-name "*Emacs Cheat Sheet*"))
    (with-output-to-temp-buffer buffer-name
      (princ "
╔══════════════════════════════════════════════════════════════════════════════╗
║                           EMACS CONFIGURATION CHEAT SHEET                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

📁 FILE & BUFFER MANAGEMENT
────────────────────────────
C-x C-f         Find/open file
C-x C-s         Save file
C-x C-w         Save as
C-x C-j         Jump to dired (current directory)
C-x b           Switch buffer (consult-buffer)
C-x k           Kill current buffer
C-x C-c         Exit Emacs

🔍 SEARCH & NAVIGATION
──────────────────────
C-s             Search in buffer (consult-line)
M-y             Yank/paste from kill ring (consult-yank-pop)
M-g g           Go to line (consult-goto-line)
C-c f           Find files (consult-find)
C-c r           Search in project (consult-ripgrep)
M-o             Switch windows (ace-window)

📋 EDITING & SELECTION
──────────────────────
C->             Mark next like this (multiple-cursors)
C-<             Mark previous like this (multiple-cursors)
C-c C-<         Mark all like this (multiple-cursors)
M-w             Copy
C-w             Cut
C-y             Paste
C-/             Undo
C-g             Cancel/quit

🚀 PROJECT MANAGEMENT (Projectile)
──────────────────────────────────
C-c p p         Switch project
C-c p f         Find file in project
C-c p s g       Search in project (grep)
C-c p c         Compile project
C-c p !         Run shell command in project root
C-c p d         Open project directory

🌿 GIT (Magit)
──────────────
C-x g           Open Magit status
In Magit status:
  s             Stage file/hunk
  u             Unstage file/hunk
  c c           Commit
  P P           Push
  F F           Pull
  b b           Switch branch
  b c           Create branch

💻 CODE DEVELOPMENT (LSP)
─────────────────────────
C-c l           LSP command prefix
C-c l r r       Rename symbol
C-c l g g       Go to definition
C-c l g r       Find references
C-c l a a       Code actions
C-c l f f       Format buffer
C-c l h h       Show documentation

🐍 PYTHON SPECIFIC
──────────────────
C-c C-p         Run Python interpreter
C-c C-c         Send buffer to Python
C-c C-r         Send region to Python
C-c C-l         Send line to Python

⚙️ C/C++ SPECIFIC
─────────────────
C-c C-c         Compile (in c-mode)
C-x `           Next error
M-.             Jump to definition (with LSP)
M-,             Jump back

📖 ORG MODE
───────────
C-c a           Org agenda
C-c c           Org capture
C-c l           Store link
TAB             Cycle visibility
S-TAB           Global cycle visibility
C-c C-t         Toggle TODO state
C-c C-s         Schedule item
C-c C-d         Set deadline
C-c C-e         Export dispatcher

In Org tables:
TAB             Next field
S-TAB           Previous field
RET             Next row
C-c |           Create table

Code blocks:
C-c C-c         Execute code block
C-c '           Edit code block

📁 DIRED (File Manager)
───────────────────────
RET             Open file/directory (same buffer)
^               Go up directory
+               Create directory
m               Mark file
u               Unmark file
U               Unmark all
d               Mark for deletion
x               Execute deletions
R               Rename/move file
C               Copy file
g               Refresh directory

🖥️ TERMINAL
───────────
C-c t           Open terminal (vterm/powershell)

🔧 CONFIGURATION
────────────────
C-c e           Edit configuration file
C-c h           Show this cheat sheet

🎯 COMPLETION & HELP
────────────────────
TAB             Complete (in minibuffer)
M-x             Execute command
C-h k           Describe key
C-h f           Describe function
C-h v           Describe variable
C-h m           Describe current mode

🎨 THEMES
─────────
Current: Catppuccin Frappé
- Warm, cozy colors
- Excellent for long coding sessions

⚡ QUICK TIPS
────────────
• Use which-key (appears after C-c, C-x, etc.) for command hints
• Most commands have C-g to cancel
• TAB completes almost everywhere
• Company mode provides auto-completion while typing
• LSP provides intelligent code features for Python/C/C++
• Projectile works best when you have .git directories

🔄 COMMON WORKFLOWS
───────────────────
1. Open project: C-c p p → select project
2. Find file: C-c p f → type filename
3. Search in project: C-c r → enter search term
4. Git status: C-x g → stage/commit/push
5. Code navigation: M-. (definition) → M-, (back)

Press 'q' to close this cheat sheet.
"))
    (with-current-buffer buffer-name
      (goto-char (point-min))
      (view-mode 1))))

(global-set-key (kbd "C-c e") 'my/open-config-file)
(global-set-key (kbd "C-c h") 'my/show-cheat-sheet)

;;; Performance optimizations
(setq gc-cons-threshold (* 2 1000 1000))

;;; Custom key bindings
(global-set-key (kbd "C-x k") 'kill-this-buffer)
;; Terminal key binding is set up in the terminal section based on platform
(unless (eq system-type 'windows-nt)
  (global-set-key (kbd "C-c t") 'vterm))

;; End of configuration
(message "Emacs configuration loaded successfully!")

;;; Custom Font Configuration
;; Define font tuples for org-mode headings
(let* ((variable-tuple
        (cond ((x-list-fonts "ETBembo") '(:font "ETBembo"))
              ((x-list-fonts "Source Serif Pro") '(:font "Source Serif Pro"))
              ((x-list-fonts "Lucida Bright") '(:font "Lucida Bright"))
              (t '(:font "Georgia"))))
       (headline `(:inherit default :weight bold)))

  (custom-theme-set-faces
   'user
   `(org-level-8 ((t (,@headline ,@variable-tuple))))
   `(org-level-7 ((t (,@headline ,@variable-tuple))))
   `(org-level-6 ((t (,@headline ,@variable-tuple))))
   `(org-level-5 ((t (,@headline ,@variable-tuple))))
   `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
   `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
   `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
   `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
   `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))
   ;; Set body/paragraph text to FantasqueSansM
   `(org-default ((t (:font "FantasqueSansM Nerd Font"))))
   `(variable-pitch ((t (:font "FantasqueSansM Nerd Font"))))
   ;; Set properties and headings to ETBembo, todos/dates to FiraCode
   `(org-property-value ((t (,@variable-tuple))))
   `(org-special-keyword ((t (,@variable-tuple))))
   `(org-todo ((t (:font "FiraCode Nerd Font" :foreground "#f38ba8" :weight bold))))
   `(org-done ((t (:font "FiraCode Nerd Font" :foreground "#a6e3a1" :weight bold))))
   `(org-date ((t (:font "FiraCode Nerd Font" :foreground "#89b4fa"))))
   `(org-agenda-date ((t (:font "FiraCode Nerd Font" :foreground "#89b4fa" :weight bold))))
   `(org-agenda-date-today ((t (:font "FiraCode Nerd Font" :foreground "#f9e2af" :weight bold))))
   `(org-agenda-date-weekend ((t (:font "FiraCode Nerd Font" :foreground "#cba6f7"))))
   ;; Code blocks should use FiraMono
   `(org-code ((t (:font "FiraMono Nerd Font"))))
   `(org-block ((t (:font "FiraMono Nerd Font"))))
   `(org-block-begin-line ((t (:font "FiraMono Nerd Font"))))
   `(org-block-end-line ((t (:font "FiraMono Nerd Font"))))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ace-window all-the-icons-dired catppuccin-theme company-box consult
                dashboard doom-modeline doom-themes flycheck lsp-ui
                magit marginalia modern-cpp-font-lock multiple-cursors
                olivetti orderless org-bullets powershell projectile
                python-black python-mode pyvenv smartparens
                tree-sitter-langs vertico vterm)))



;; First, let's create helper functions to check font availability
(defun my/font-available-p (font-name)
  "Check if a font is available on the system."
  (when (display-graphic-p)
    (member font-name (font-family-list))))

;; Define font variables based on availability
(defvar my/heading-font
  (cond ((my/font-available-p "ETBembo") "ETBembo")
        ((my/font-available-p "Source Serif Pro") "Source Serif Pro")
        ((my/font-available-p "Lucida Bright") "Lucida Bright")
        ((my/font-available-p "Georgia") "Georgia")
        (t nil)))

(defvar my/body-font
  (cond ((my/font-available-p "FantasqueSansM Nerd Font") "FantasqueSansM Nerd Font")
        ((my/font-available-p "FantasqueSansMono Nerd Font") "FantasqueSansMono Nerd Font")
        ((my/font-available-p "FantasqueSansM NF") "FantasqueSansM NF")
        (t nil)))

(defvar my/code-font
  (cond ((my/font-available-p "FiraCode Nerd Font") "FiraCode Nerd Font")
        ((my/font-available-p "FiraCode NF") "FiraCode NF")
        ((my/font-available-p "FiraMono Nerd Font") "FiraMono Nerd Font")
        ((my/font-available-p "Fira Code") "Fira Code")
        (t nil)))

;; Apply font configuration only if fonts are available
(when (display-graphic-p)
  (let ((faces-to-set '()))
    
    ;; Build heading faces if heading font is available
    (when my/heading-font
      (setq faces-to-set
            (append faces-to-set
                    `((org-level-1 ((t (:font ,my/heading-font :weight bold :height 1.75))))
                      (org-level-2 ((t (:font ,my/heading-font :weight bold :height 1.5))))
                      (org-level-3 ((t (:font ,my/heading-font :weight bold :height 1.25))))
                      (org-level-4 ((t (:font ,my/heading-font :weight bold :height 1.1))))
                      (org-level-5 ((t (:font ,my/heading-font :weight bold))))
                      (org-level-6 ((t (:font ,my/heading-font :weight bold))))
                      (org-level-7 ((t (:font ,my/heading-font :weight bold))))
                      (org-level-8 ((t (:font ,my/heading-font :weight bold))))
                      (org-document-title ((t (:font ,my/heading-font :weight bold :height 2.0 :underline nil))))
                      (org-property-value ((t (:font ,my/heading-font))))
                      (org-special-keyword ((t (:font ,my/heading-font))))))))
    
    ;; Build body text faces if body font is available
    ;; IMPORTANT: variable-pitch is what org-mode uses for body text when variable-pitch-mode is on
    (when my/body-font
      (setq faces-to-set
            (append faces-to-set
                    `((variable-pitch ((t (:font ,my/body-font))))))))
    
    ;; Build code faces - these should inherit from default (which is now FiraCode)
    ;; But we'll be explicit to ensure consistency
    (when my/code-font
      (setq faces-to-set
            (append faces-to-set
                    `((fixed-pitch ((t (:font ,my/code-font))))
                      (org-code ((t (:inherit fixed-pitch))))
                      (org-block ((t (:inherit fixed-pitch))))
                      (org-block-begin-line ((t (:inherit fixed-pitch))))
                      (org-block-end-line ((t (:inherit fixed-pitch))))
                      (org-todo ((t (:inherit fixed-pitch :foreground "#f38ba8" :weight bold))))
                      (org-done ((t (:inherit fixed-pitch :foreground "#a6e3a1" :weight bold))))
                      (org-date ((t (:inherit fixed-pitch :foreground "#89b4fa"))))
                      (org-agenda-date ((t (:inherit fixed-pitch :foreground "#89b4fa" :weight bold))))
                      (org-agenda-date-today ((t (:inherit fixed-pitch :foreground "#f9e2af" :weight bold))))
                      (org-agenda-date-weekend ((t (:inherit fixed-pitch :foreground "#cba6f7"))))))))
    
    ;; Apply all face customizations
    (when faces-to-set
      (apply 'custom-theme-set-faces 'user faces-to-set))
    
    ;; Debug: Print which fonts were found
    (message "Font configuration loaded:")
    (message "  Default (code) font: %s" (face-attribute 'default :font))
    (message "  Heading font: %s" (or my/heading-font "Default"))
    (message "  Body font: %s" (or my/body-font "Default"))
    (message "  Code font: %s" (or my/code-font "Default"))))

;; Hook to apply fonts after org-mode loads
(add-hook 'org-mode-hook
          (lambda ()
            (when my/body-font
              (variable-pitch-mode 1))))

;; Clean custom-set-faces
(custom-set-faces
 '(cursor ((t (:background "#f2d5cf" :foreground "black")))))


;; FORCE default font to be FiraCode for all programming modes
(when (display-graphic-p)
  (let ((code-font (cond 
                    ((my/font-available-p "FiraCode Nerd Font") "FiraCode Nerd Font")
                    ((my/font-available-p "FiraCode NF") "FiraCode NF") 
                    ((my/font-available-p "FiraMono Nerd Font") "FiraMono Nerd Font")
                    ((my/font-available-p "Fira Code") "Fira Code")
                    (t nil))))
    (when code-font
      ;; Set the default face explicitly
      (set-face-attribute 'default nil :family code-font :height 120)
      ;; Also set fixed-pitch to ensure consistency
      (set-face-attribute 'fixed-pitch nil :family code-font)
      (message "Forced default font to: %s" code-font))))

;; Also add this to your custom-set-faces to make it permanent:
(custom-set-faces
 '(cursor ((t (:background "#f2d5cf" :foreground "black"))))
 ;; Explicitly set default to FiraCode
 '(default ((t (:family "FiraCode Nerd Font" :height 120))))
 ;; Ensure fixed-pitch is also FiraCode  
 '(fixed-pitch ((t (:family "FiraCode Nerd Font")))))
