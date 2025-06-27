;; -*- lexical-binding: t; -*-
   
 (setq user-full-name "Adam Johnson"
      user-mail-address "adam.johnson@akips.com")
;; Declaring functions
(declare-function my/leader-keys nil)
(declare-function vterm "vterm")
(declare-function vterm-send-string "vterm")
(declare-function vterm-send-return "vterm")
(declare-function persp-list-buffers "perspective")

;; Font
;; You will most likely need to adjust this font size for your system!
(defvar default-font-size 140)
(set-face-attribute 'default nil :font "Fira Code Retina" :height default-font-size)


;; Theme
(use-package doom-themes
  :config
  (load-theme 'doom-nord-aurora t))


;; Dashboard
(setq inhibit-startup-screen t)
(use-package dashboard
  :ensure t
  :config
  (setq dashboard-startup-banner 'official) ;; or a custom path
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (agenda . 5)))
  (dashboard-setup-startup-hook))

;; Modeline
(unless (package-installed-p 'doom-modeline)
  (package-install 'doom-modeline))

;; Initialize package sources
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("gnu" . "https://elpa.gnu.org/packages/")))
;; (package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Keep custom variables in a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)            ; Disable the menu bar
(visual-line-mode 1)        ; Text wrapping
(setq recentf-exclude '(".*\\.Trashes.*"))

(require 'cl-lib)

;; Window
(set-frame-parameter (selected-frame) 'alpha '(85 . 85)) (add-to-list 'default-frame-alist '(alpha . (85 . 85)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(defun my/dashboard-resize-safe (&rest _)
  (unless (active-minibuffer-window)
    (dashboard-resize-on-hook)))

(remove-hook 'window-size-change-functions #'dashboard-resize-on-hook)
(add-hook 'window-size-change-functions #'my/dashboard-resize-safe)

;; Resizing windows
(defun my/enlarge-window-horizontally ()
  "Enlarge window horizontally by 10 columns."
  (interactive)
  (enlarge-window-horizontally 20))

(defun my/shrink-window-horizontally ()
  "Shrink window horizontally by 10 columns."
  (interactive)
  (shrink-window-horizontally 20))

;; Load Evil mode
(use-package evil
  :init (setq evil-want-integration t
              evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-file-name-style 'auto))

;; Which-key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(unless (package-installed-p 'llama)
  (package-refresh-contents)
  (package-install 'llama))

;; Conpletion Stack

;; Init basics
(setq inhibit-startup-message t)
(set-face-attribute 'default nil :font "Menlo" :height 140)
(setq ring-bell-function 'ignore)

;; Package setup
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-ensure t)

;; Save minibuffer history
(savehist-mode 1)

;; 1. VERTICO — vertical completion UI
(use-package vertico
  :init (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil  ;; because it's bundled with vertico
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :config
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))

;; 2. ORDERLESS — smarter completion style
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; 3. MARGINALIA — minibuffer annotations
(use-package marginalia
  :init (marginalia-mode))

;; 4. CONSULT — searching and navigation
(use-package consult
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("M-y" . consult-yank-pop)
   ("C-c k" . consult-ripgrep)
   ("C-c m" . consult-mode-command)))

;; 5. EMBARK — context menu for minibuffer
(use-package embark
  :bind
  (("C-." . embark-act)         ;; like right-click
   ("C-;" . embark-dwim)        ;; smart default action
   ("C-h B" . embark-bindings)) ;; all current keybindings
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; 6. EMBARK-CONSULT — preview actions with consult
(use-package embark-consult
  :after (embark consult))

;; 7. CORFU — popup completions in buffers (vs minibuffer)
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator))

;; OPTIONAL: add pretty icons to corfu (requires Nerd Font or similar)
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Enable TAB in completion-at-point
(setq tab-always-indent 'complete)

;; Use dabbrev with corfu
(use-package dabbrev
  :bind (("M-/" . dabbrev-expand)))

;; 🧼 General Emacs UX polish
(setq completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t)
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))
(with-eval-after-load 'evil
  (define-key evil-insert-state-map (kbd "ESC") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-[") 'evil-normal-state))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; (use-package ivy
;;   :diminish
;;   :bind (("C-s" . swiper)
;;          :map ivy-minibuffer-map
;;          ("TAB" . ivy-alt-done)
;;          ("C-l" . ivy-alt-done)
;;          ("C-j" . ivy-next-line)
;;          ("C-k" . ivy-previous-line)
;;          :map ivy-switch-buffer-map
;;          ("C-k" . ivy-previous-line)
;;          ("C-l" .; ivy-done)
;;          ("C-d" . ivy-switch-buffer-kill)
;;          :map ivy-reverse-i-search-map
;;          ("C-k" . ivy-previous-line)
;;          ("C-d" . ivy-reverse-i-search-kill))
;;   :config
;;   (ivy-mode 1))

;(use-package counsel
;  :ensure t)

;(use-package counsel-projectile
;  :ensure t
;  :after (counsel projectile)
;  :config
;  (counsel-projectile-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

;; (add-hook 'emacs-startup-hook
;;           (lambda ()
;;             (projectile-mode +1)
;;             (run-with-idle-timer
;;              2 nil
;;              (lambda ()
;;                (when (fboundp 'persp-state-load)
;;                  (persp-state-load))))))


(use-package all-the-icons);; Magit

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Org mode
(use-package org
  :config
  (setq org-directory "~/org/"
        org-agenda-files (list org-directory)))

;; Enable org-indent-mode when opening Org buffers
(add-hook 'org-mode-hook #'org-indent-mode)

(declare-function url-handler-file-remote-p "url-handlers" (filename))

(use-package org-download
  :after org
  :config
  (setq org-download-image-dir "Images"
        org-download-heading-lvl nil
        org-download-backend "pngpaste"
        org-download-screenshot-method "pngpaste %s"
        org-download-link-format "[[file:%s]]")

  (add-hook 'org-download-after-download-hook #'org-display-inline-images)
  (add-hook 'org-mode-hook #'org-download-enable))

;; Paste from clipboard if it's an image
(defun my/org-smart-paste ()
  "Paste image from clipboard if available, else yank."
  (interactive)
  (if (and (eq major-mode 'org-mode)
           (= 0 (call-process "pngpaste" nil nil nil "-b")))
      (progn
        (org-download-clipboard)
        (org-display-inline-images))
    (yank)))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "s-v") #'my/org-smart-paste))

;; Show images at Org buffer startup
(setq org-startup-with-inline-images t)

(add-hook 'org-mode-hook #'org-display-inline-images)

(defun my/org-maybe-delete-image (_beg _end _len)
  "Delete image file if a file link to it was just removed."
  (when (and (eq major-mode 'org-mode)
             (not undo-in-progress))
    (save-excursion
      ;; Look back one line in case it was just deleted
      (forward-line -1)
      (let ((line (thing-at-point 'line t)))
        (when (and line (string-match "\\[\\[file:\\(.*?\\)\\]\\]" line))
          (let ((filepath (expand-file-name (match-string 1 line)
                                            (file-name-directory (buffer-file-name)))))
            (when (and (file-exists-p filepath)
                       (string-match-p "\\(png\\|jpg\\|jpeg\\|gif\\)$" filepath))
              (delete-file filepath)
              (message "Deleted image file: %s" filepath))))))))

(add-hook 'after-change-functions #'my/org-maybe-delete-image)
   
;; Line numbers
(global-display-line-numbers-mode t)
;; (setq display-line-numbers-type 'relative)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Backups
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Recentf
(use-package recentf
  :config
  (setq recentf-max-menu-items 25)
  (recentf-mode 1))

;; Savehist
(use-package savehist
  :init (savehist-mode))

;; Dired config
(setq dired-listing-switches "-alh")
(add-hook 'dired-mode-hook
  (lambda ()
  (dired-hide-details-mode 1)))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))  ; Shift-TAB

(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "<left>") 'dired-up-directory
    (kbd "<right>") 'dired-find-file
    (kbd "<up>") 'previous-line
    (kbd "<down>") 'next-line
    (kbd "h") 'dired-up-directory
    (kbd "l") 'dired-find-file))
   
(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package diredfl
  :ensure t
  :hook (dired-mode . diredfl-mode))
   
(add-hook 'dired-mode-hook #'turn-on-font-lock)
   
;; Avy
(use-package avy)

;; Parentheses
(electric-pair-mode 1)
(show-paren-mode 1)

;; Improve scrolling
(setq scroll-margin 5
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; Move-duo
(use-package move-dup)


;; (use-package ivy-file-preview
;;   :ensure t)
;; (ivy-file-preview-mode 1)
(global-move-dup-mode 1)

;; Cursor options.
(blink-cursor-mode 1)
(setq blink-cursor-blinks 0) ;; Blink forever instead of only for 10 seconds.

(use-package multiple-cursors
  :ensure t)

(with-eval-after-load 'evil
   (define-key evil-insert-state-map [escape]
     (lambda ()
       (interactive)
       (when (bound-and-true-p multiple-cursors-mode)
         (multiple-cursors-mode 0))  ;; turn off multiple cursors if active
       (evil-normal-state))))

(defun my/mc-evil-integration ()
  "Make multiple-cursors play nice with evil-mode."
  (when (bound-and-true-p evil-mode)
    (evil-emacs-state)))
    (add-hook 'multiple-cursors-mode-enabled-hook #'my/mc-evil-integration)
    (add-hook 'multiple-cursors-mode-disabled-hook #'evil-normal-state)

(defun my/evil-mc-escape ()
  "Exit multiple-cursors mode when pressing ESC in evil."
  (interactive)
  (when multiple-cursors-mode
    (mc/keyboard-quit))
  ;; Always return to normal mode (even if mc wasn't active)
  (evil-force-normal-state))
;; Replace ESC in emacs and insert states while mc is active
(with-eval-after-load 'evil
  (define-key evil-emacs-state-map [escape] #'my/evil-mc-escape)
  (define-key evil-insert-state-map [escape] #'my/evil-mc-escape))

;; Calendar
(require 'calfw)
(require 'calfw-org)

;; Beacon
(use-package beacon
  :ensure t)
(beacon-mode 1)
(global-set-key (kbd "C-s-b") 'beacon-blink)

;; Auto compile Emacs config on save.
(defun my/auto-byte-compile ()
  "Automatically byte-compile Emacs Lisp files on save."
  (when (and (eq major-mode 'emacs-lisp-mode)
             (buffer-file-name)
             (file-writable-p (buffer-file-name)))
    (byte-compile-file (buffer-file-name))))

(add-hook 'after-save-hook #'my/auto-byte-compile)

;; SNMP
(defun snmpv2-hook ()
  (cond ((string-match "^/Volumes/Sensitive/akips/mib/" buffer-file-name)
         (snmpv2-mode))))
(add-hook 'fundamental 'snmpv2-hook)


;; Perl
;; (setq-default eglot-workspace-configuration
;;                 '((:perlnavigator . (:perlPath
;;                               "/usr/bin/perl"
;;                               :enableWarnings t))))

;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs
;;                `((cperl -mode perl-mode) . ("/Users/atj/perlnavigator/server/bin/perlnavigator", "--stdio"))))
;; (remove-hook 'perl-mode-hook #'eglot-ensure)
;; (add-hook 'cperl-mode-hook 'eglot-ensure)
(add-hook 'cperl-mode-hook
   (setq-default indent-tabs-mode nil)
   (setq-default tab-width 3)
   (setq indent-line-function 'insert-tab))

;; (add-hook 'perl-mode-hook 'eglot-ensure)

;(add-to-list 'load-path "~/plsense") ; Adjust path if necessary
;(require 'plsense)
;(plsense-config-default)

(use-package persp-mode
  :init
  (setq persp-keymap-prefix (kbd "C-c w")) ;; Optional: change keybinding prefix

  :config
  (persp-mode 1)
  :bind (:map persp-mode-map
              ("C-c w s" . persp-switch)          ;; Switch workspace
              ("C-c w n" . persp-next)            ;; Next workspace
              ("C-c w p" . persp-prev)            ;; Previous workspace
              ("C-c w r" . persp-rename)          ;; Rename workspace
              ("C-c w k" . persp-kill)            ;; Kill workspace
              ("C-c w a" . persp-add-buffer)      ;; Add buffer to workspace
              ("C-c w b" . persp-switch-to-buffer)))
(setq persp-save-dir (expand-file-name "persp-confs/" user-emacs-directory))
(setq persp-auto-save-opt 1) ;; autosave when switching or quitting
(add-hook 'kill-emacs-hook
          (lambda ()
            (dolist (persp (persp-names-current-frame-fast-ordered))
              (persp-switch persp)
              (persp-save-state-to-file
               (expand-file-name (format "%s.perps" persp) persp-save-dir)))))

;; Markdown
(custom-set-faces
 '(markdown-header-delimiter-face ((t (:foreground "#616161" :height 0.9))))
 '(markdown-header-face-1 ((t (:height 1.8 :foreground "#A3BE8C" :weight extra-bold))) )
 '(markdown-header-face-2 ((t (:height 1.4 :foreground "#EBCB8B" :weight extra-bold))) )
 '(markdown-header-face-3 ((t (:height 1.2 :foreground "#D08770" :weight extra-bold))) )
 '(markdown-header-face-4 ((t (:height 1.15 :foreground "#BF616A" :weight bold))) )
 '(markdown-header-face-5 ((t (:height 1.1 :foreground "#b48ead" :weight bold))) )
 '(markdown-header-face-6 ((t (:height 1.05 :foreground "#5e81ac" :weight semi-bold))) ))

(defvar nb/current-line '(0 . 0)
   "(start . end) of current line in current buffer")
 (make-variable-buffer-local 'nb/current-line)

 (defun nb/unhide-current-line (limit)
   "Font-lock function"
   (let ((start (max (point) (car nb/current-line)))
         (end (min limit (cdr nb/current-line))))
     (when (< start end)
       (remove-text-properties start end
                       '(invisible t display "" composition ""))
       (goto-char limit)
       t)))

 (defun nb/refontify-on-linemove ()
   "Post-command-hook"
   (let* ((start (line-beginning-position))
          (end (line-beginning-position 2))
          (needs-update (not (equal start (car nb/current-line)))))
     (setq nb/current-line (cons start end))
     (when needs-update
       (font-lock-fontify-block 3))))

 (defun nb/markdown-unhighlight ()
   "Enable markdown concealling"
   (interactive)
   (markdown-toggle-markup-hiding 'toggle)
   (font-lock-add-keywords nil '((nb/unhide-current-line)) t)
   (add-hook 'post-command-hook #'nb/refontify-on-linemove nil t))

(add-hook 'markdown-mode-hook #'nb/markdown-unhighlight)

   
;; Org Mode
(use-package org
  :ensure t)

;(require 'org-roam-dailies) ;; Ensure the keymap is available
;(setq org-roam-dailies-capture-templates
;      '(("d" "default" entry "** %<%I:%M %p>: %?"
;         :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "/Users/atj/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n n" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i"    . completion-at-point))
    ;     :map org-roam-dailies-map
  ;       ("Y" . org-roam-dailies-capture-yesterday)
   ;      ("T" . org-roam-dailies-capture-tomorrow))
 ; :bind-keymap
 ; ("C-c n d" . org-roam-dailies-map)
  :config
  (org-roam-db-autosync-enable))

(evil-define-key* 'normal 'global
(kbd "SPC j") #'org-roam-node-find
(kbd "SPC a") #'org-agenda
(kbd "SPC k") #'kill-current-buffer)
;(kbd "SPC d") #'org-roam-dailies-map)


(use-package org-modern
   :ensure t)
(with-eval-after-load 'org (global-org-modern-mode))

;; Elegant Agenda Mode *************************************
(use-package elegant-agenda-mode
  :ensure t)
  (with-eval-after-load 'org-agenda)
  ;;(add-hook 'org-agenda-mode-hook))
(setq org-agenda-custom-commands
      '(("d" "Today"
         ((tags-todo "SCHEDULED<\"<+1d>\"&PRIORITY=\"A\""
                     ((org-agenda-skip-function
                       '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (agenda "" ((org-agenda-span 'day)
                      (org-scheduled-delay-days -14)
                      (org-agenda-overriding-header "Schedule")))
          (tags-todo "SCHEDULED<\"<+1d>\""
                     ((org-agenda-skip-function
                       '(or (org-agenda-skip-entry-if 'done)
                            (air-org-skip-subtree-if-priority ?A)))
                      (org-agenda-overriding-header "Tasks:")))))))
(setq org-agenda-files
      '("/Users/atj/RoamNotes/"))


;; Org Themes
(setq org-todo-keyword-faces
    '(("NEXT" . "tomato")
    ("START" . "cornflowerblue")
    ("WAITING" . "palegoldenrod")
    ("HOLD" . "lightsalmon")
    ("BLOCKED" . "red")))
(defun my/org-mode-headline-faces ()
  (let* ((font (cond ((x-list-fonts "Lucida Grande") "Lucida Grande")
                     ((x-list-fonts "Source Sans Pro") "Source Sans Pro")
                     (t "Sans Serif")))
         (headline `(:inherit default :family ,font :weight bold)))
    (custom-theme-set-faces
     'user
     `(org-level-1 ((t (,@headline :height 1.5 :foreground "#BF616A"))))
     `(org-level-2 ((t (,@headline :height 1.2  :foreground "#D08770"))))
     `(org-level-3 ((t (,@headline :height 1.1  :foreground "#EBCB8B"))))
     `(org-level-4 ((t (,@headline :height 1.1  :foreground "#A3BE8C"))))
     `(org-level-5 ((t (,@headline :height 1.1  :foreground "#88C0D0"))))
     `(org-level-6 ((t (,@headline :height 1.0  :foreground "#B48EAD"))))
     `(org-level-7 ((t (,@headline :height 1.0  :foreground "#5E81AC"))))
     `(org-level-8 ((t (,@headline :height 1.0  :foreground "#4C566A"))))
     `(org-document-title ((t (,@headline :height 2.0 :foreground "#8FBCBB" :underline nil)))))))

(remove-hook 'after-load-theme-hook #'my/org-mode-headline-faces) ; remove if added before
(add-hook 'doom-load-theme-hook #'my/org-mode-headline-faces)     ; use Doom's hook instead

(defun my/org-override-faces ()
  (when (derived-mode-p 'org-mode)
    (my/org-mode-headline-faces)))

(add-hook 'org-mode-hook #'my/org-override-faces)

(eval-when-compile
  (require 'flyspell))

;; LSP Setups
;; 🧠 Base LSP config
(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-enable-symbol-highlighting t
        lsp-enable-on-type-formatting nil
        lsp-headerline-breadcrumb-enable nil
        lsp-file-watch-threshold 2000)
  :hook (
         (cperl-mode . lsp)
         (c-mode    . lsp)
         (c++-mode  . lsp)
         (js-mode   . lsp)
         (typescript-ts-mode . lsp))
  :commands lsp
  :config
  (setq lsp-idle-delay 0.3))

;; 💡 LSP UI (docs, sideline, peek)
;; (use-package lsp-ui
;;   :after lsp-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :config
;;   (setq lsp-ui-doc-enable t
;;         lsp-ui-doc-show-with-cursor t
;;         lsp-ui-doc-delay 0.2
;;         lsp-ui-sideline-enable t
;;         lsp-ui-sideline-show-code-actions t
;;         lsp-ui-sideline-show-hover t))
(use-package lsp-ui
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-peek-enable t
        lsp-ui-peek-always-show t
        lsp-ui-peek-fontify 'on-demand
        lsp-ui-peek-list-width 60
        lsp-ui-peek-peek-height 25))
;; (use-package lsp-ui
;;   :ensure t
;;   :after lsp-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :custom
;;   (lsp-ui-doc-enable t)
;;   (lsp-ui-doc-position 'at-point)
;;   (lsp-ui-sideline-enable t)
;;   (lsp-ui-sideline-show-code-actions t))

 (with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration '(perl-mode . "perl"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("perl-navigator"))
    :major-modes '(perl-mode)
    :server-id 'perl-navigator)))
;; (use-package lsp-mode
;;   :ensure t
;;   :init
;;   ;; Performance tuning
;;   (setq lsp-keymap-prefix "C-c l") ;; LSP command map
;;   (setq lsp-enable-file-watchers nil)
;;   :hook ((perl-mode . lsp)
;;          (js-mode . lsp)
;;          (typescript-mode . lsp)
;;          (c-mode . lsp)
;;          (c++-mode . lsp))
;;   :commands lsp)

;; (use-package lsp-ui
;;   :ensure t
;;   :commands lsp-ui-mode
;;   :after lsp-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :custom
;;   (lsp-ui-doc-enable t)
;;   (lsp-ui-doc-show-with-cursor t)
;;   (lsp-ui-doc-delay 0.2)
;;   (lsp-ui-sideline-enable t))

;; (defun my/lsp-server-id ()
;;   "Get the current LSP server ID, or nil if none."
;;   (when (bound-and-true-p lsp-mode)
;;     (let ((workspace (lsp--workspace-for-buffer)))
;;       (when (lsp--workspace? workspace)
;;         (lsp--client-server-id (lsp--workspace-client workspace))))))

;; 1. Set this FIRST
;; (setq treesit-language-source-alist
;;       '((c          . ("https://github.com/tree-sitter/tree-sitter-c"))
;;         (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
;;         (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src"))))


(setq treesit-language-source-alist
      '((typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "typescript"))
        (tsx        . ("https://github.com/tree-sitter/tree-sitter-typescript" "tsx"))
        (c          . ("https://github.com/tree-sitter/tree-sitter-c"))))

   
   
;; 2. Set install path (optional but safer)
(setq treesit-extra-load-path '("~/.config/emacs/tree-sitter/"))

;; 3. Install grammars manually
(unless (treesit-language-available-p 'typescript)
  (treesit-install-language-grammar 'typescript))

(unless (treesit-language-available-p 'c)
  (treesit-install-language-grammar 'c))
  ;; Safe wrapper to get the LSP server ID (optional if you need it)
(use-package tree-sitter
  :ensure t
  :hook ((typescript-mode . tree-sitter-mode)
         (tree-sitter-mode)
         ;; Add other modes if needed
         )
  :config
  (use-package tree-sitter-langs
    :ensure t))
;; Remove tsx remapping from mode remap alist
;; (setq major-mode-remap-alist
;;       (cl-remove-if
;;        (lambda (pair)
;;          (memq (cdr pair) '(tsx-ts-mode)))
;;        major-mode-remap-alist))

;; ;; Remove tsx-ts-mode remapping from major-mode remap list
;; (setq major-mode-remap-alist
;;       (cl-remove-if (lambda (pair)
;;                       (eq (cdr pair) 'tsx-ts-mode))
;;                     major-mode-remap-alist))

;; ;; Optional: Remove TSX language source if set
;; (setq treesit-language-source-alist
;;       (assq-delete-all 'tsx treesit-language-source-alist))

(require 'treesit)
(require 'tree-sitter)
(require 'tree-sitter-langs)

;; install only once
;; (treesit-install-language-grammar 'typescript)
;; (treesit-install-language-grammar 'tsx)
;; (treesit-install-language-grammar 'c)
;; (treesit-install-language-grammar 'javascript)


;; (require 'treesit-auto)
;; (setq treesit-auto-install 'prompt) ;; or 'always to auto-install without prompt
;; (global-treesit-auto-mode)

;; (setq treesit-auto-install 'prompt) ; or 'always
;; (global-treesit-auto-mode)

;; (setq treesit-language-source-alist
;;       '((typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
;;         (tsx       . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
;;         ;; (c         . ("https://github.com/tree-sitter/tree-sitter-c"))
;;         (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
;;         ;; add more if needed
;;         ))

;; (setq treesit-auto-install 'prompt) ;; Default — asks every time

;; Change it to this to automatically install without prompting:
;;(setq treesit-auto-install 'always)
(setq treesit-font-lock-settings
      (treesit-font-lock-rules
       :language 'c
       :feature 'keyword
       '((keyword) @font-lock-keyword-face)))

(setq treesit-font-lock-settings
      (treesit-font-lock-rules
       :language 'typescript
       :feature 'keyword
       '((keyword) @font-lock-keyword-face)))

(setq major-mode-remap-alist
      '((typescript-ts-mode . typescript-mode)))

;; ;; Example: change tree-sitter face mappings
;; (setq treesit-font-lock-settings
;;       (treesit-font-lock-rules
;;        :language 'typescript
;;        :feature 'function
;;        '((function_declaration
;;           name: (identifier) @font-lock-function-name-face))

;;        :feature 'keyword
;;        '((keyword) @font-lock-keyword-face)

;;        ;; Add more customizations as needed
;;        ))

(add-hook 'typescript-ts-mode-hook
          (lambda ()
            (setq-local treesit-font-lock-feature-list
                        '((comment definition keyword string type)
                          (function variable operator)))))


(defun my/lsp-server-id ()
  "Return the server ID for the current LSP workspace, or nil if unavailable."
  (when-let ((workspace (car (lsp-workspaces)))
             (client (lsp--workspace-client workspace)))
    (plist-get (lsp--client-initialization-options client) :name)))

(defun my/lookup-definition ()
  "Go to the definition of the symbol at point using LSP or fallback."
  (interactive)
  (cond
   ((bound-and-true-p lsp-mode)
    (call-interactively #'lsp-find-definition))
   ((fboundp 'xref-find-definitions)
    (call-interactively #'xref-find-definitions))
   ((fboundp 'dumb-jump-go)
    (call-interactively #'dumb-jump-go))
   (t
    (message "No lookup method available."))))
;; Your own safe wrapper for references
(defun my/lookup-references ()
  "Find references using LSP, fallback to xref/dumb-jump."
  (interactive)
  (cond
   ((and (bound-and-true-p lsp-mode)
         (lsp-feature? "textDocument/references"))
    (message "Using LSP references…")
    (call-interactively #'lsp-find-references))
   ((fboundp 'xref-find-references)
    (message "Falling back to xref (dumb-jump)…")
    (call-interactively #'xref-find-references))
   (t
    (message "No reference method available."))))

(defun my/remove-lsp-xref-if-no-references ()
  "Remove lsp xref backend if LSP doesn't support references."
  (when (and (bound-and-true-p lsp-mode)
             (not (lsp-feature? "textDocument/references")))
    (setq-local xref-backend-functions
                (remove #'lsp--xref-backend xref-backend-functions))))

(add-hook 'lsp-managed-mode-hook #'my/remove-lsp-xref-if-no-references)

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))
(setq dumb-jump-force-searcher 'rg) ;; or 'ag or 'grep

(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode))

(setq lsp-completion-provider :none)

;; Performance
(setq gc-cons-threshold (* 50 1000 1000))

;; Keybindingd
(global-unset-key (kbd "ESC ESC ESC"))

(defun my/revert-buffer-no-confirm ()
  "Revert the current buffer without confirmation.
Special handling for Dired and Magit buffers."
  (interactive)
  (cond
   ;; Refresh Dired
   ((derived-mode-p 'dired-mode)
    (revert-buffer))

   ;; Refresh Magit buffers
   ((string-prefix-p "magit" (format "%s" major-mode))
    (magit-refresh))

   ;; Generic revert for other buffers
   (t
    (revert-buffer :ignore-auto :noconfirm))))
   
;; Org
(global-set-key (kbd "C-c a") #'org-agenda)

;; (use-package general
;;   :config
;;   (general-create-definer my/leader-keys
;;     :keymaps '(normal visual emacs)  ; Removed insert mode
;;     :prefix "SPC"
;;     :global-prefix "C-SPC")
(use-package general
  :config
  (general-create-definer my/leader-keys
    :states '(normal visual)         ;; <-- use :states instead of :keymaps
    :keymaps 'override               ;; <-- override ensures it's global
    :prefix "SPC"
    :global-prefix "C-SPC")

  (my/leader-keys
    ;; Avy
    "SPC"  '(evil-avy-goto-char-timer :which-key "avy goto char")

    ;; Bookmarks
    "m"   '(:ignore t :which-key "bookmarks")
    ;; "mm"  '(consult-bookmark :which-key "consult bookmark") ; This is already - SPC <ENTER>
    "ms"  '(bookmark-set :which-key "set bookmark")
    "mj"  '(bookmark-jump :which-key "jump to bookmark")
    "md"  '(bookmark-delete :which-key "delete bookmark")

    ;; Export
    "E"   '(:ignore t :which-key "export")
    "Eo"  '(my/org-export-html-to-rtf-clipboard :whichorg-key "org to email")

    ;; File
    "f"   '(:ignore t :which-key "find")
    "ff"  '(projectile-find-file :which-key "find file in project")
    "fd"  '(dired :which-key "dired")
    "."   '(find-file :which-key "find file" )

    ;; Lookup
    "l"   '(:ignore t :which-key "lookup")
;    "ld"  '(+lookup/definition :which-key "definition")
;    "lr"  '(+lookup/references :which-key "references")
    "lb"  '(xref-go-back :which-key "back")

    ;; Help
    "h"   '(:ignore t :which-key "help/describe")
    "hk"  '(describe-key :which-key "keybinding")
    "hv"  '(describe-variable :which-key " ")

    ;; Directory
    "d"   '(:ignore t :which-key "directory")
    "dd"  '(projectile-dired :which-key "projectile dired")
    "dt"  '(treemacs :which-key "treemacs")

    ;; Project
    "fp" '(projectile-find-file :which-key "projectile find file")
    "p"   '(:ignore t :which-key "projectile")
    "pp"  '(counsel-projectile-switch-project :which-key "switch project")

    ;; Terminal
    "t"   '(:ignore t :which-key "vterm")
    ;; "tt"  '(vterm-other-window :which-key "vterm (other window)")
    "tt"  '(my/vterm-toggle :which-key "vterm")
    "th"  '(vterm :which-key "vterm (here)")

    ;; Calendar
    "C"   '(cfw:open-org-calendar :which-key "calendar")

    ;; Refresh
    "r"   '(revert-buffer :which-key "refresh")

    ;; Workspaces
    "w"   '(:ignore t :which-key "workspaces")
    "wr"  '(persp-rename :which-key "rename workspace")

    ;; Buffers
    "b"   '(:ignore t :which-key "buffer")
    "bk"  '(kill-buffer :which-key "kill buffer")
    "br"  '(my/revert-buffer-no-confirm :which-key "revert buffer")
    "be"  '(eval-buffer :which-key "eval buffer")
    ;; "bo"  '(eval-buffer :which-key "buffer org2html")
    "bo"  '(my/org-export-html-to-rtf-clipboard :whichorg-key "org to email")


    ;; Search
    "s"   '(:ignore t :which-key "search")
    "ss"  '(consult-line :which-key "buffer")
    "sp"  '(consult-ripgrep :which-key "project")
    "sP"  '(consult-ripgrep-args :which-key "project ex")
    "sl"  '(goto-line :which-key "line number")
    ;; "SS"  '(counsel-grep-or-swiper :which-key "swiper")
    ;; "SD"  '(swiper-thing-at-point :which-key "swiper thing at point")
    ;; "SA"  '(counsel-ag  :which-key "ag global")

    "e"   '(:ignore t :which-key "embark")
    "el"  '(embark-live  :which-key "live")

    ;; Git
    "g"   '(:ignore t :which-key "magit")
    "gg"  '(magit :which-key "magit")
    "gd"  '(magit-diff-range :which-key "diff branch")
    "gb"  '(magit-blame :which-key "blame")))

;; Remap existing keybindings that general.el cannot.
;; (map! :leader
;;       :desc "Avy goto char timer"
;;       "SPC" #'avy-goto-char-timer
;;       :desc "Find file"
;;       "fd" #'find-file
;;       :desc "Projectile find file"
;;       "ff" #'projectile-find-file)

   ;; Thi iss a ttest spell

;; SNMP
(define-derived-mode snmpv2-mode prog-mode "SNMPv2"
  "Major mode for SNMP MIB files with no extension.")(defvar my/snmpv2-dir "/Volumes/work/akips/mib/")
(defvar my/snmpv2-dir "/Volumes/work/akips/mib/")


(defun my/maybe-enable-snmpv2-mode ()
  "Enable `snmpv2-mode` if the file is under MIBs path and has no extension."
  (let ((filename (buffer-file-name)))
    (when (and filename
               (string-prefix-p (expand-file-name my/snmpv2-dir)
                                (expand-file-name filename)))
      (when (my/snmpv2-file-p filename)
        (snmpv2-mode)))))

(defun my/snmpv2-file-p (filename)
  "Return non-nil if FILENAME is a regular file under
    `my/snmpv2-dir` and has no extension."
  ;; (message "Checking filename: %s" filename)
  (and filename
       (not (file-directory-p filename))
       (string-prefix-p (expand-file-name my/snmpv2-dir)
                        (expand-file-name filename))
       (not (file-name-extension filename))))

(add-hook 'find-file-hook #'my/maybe-enable-snmpv2-mode)



(set-face-attribute 'default nil :height 140)

(global-unset-key (kbd "ESC ESC ESC"))

;; (customize-variable 'magit-log-infix-arguments)
(setq magit-log-arguments '("--graph" "--decorate" "--color"))
;; (setq magit-log-arguments '("--graph" "--color" "--decorate" "-n256"))

;; (defun my/magit-log-oneline ()
;;   "Show a compact Git log similar to VS Code Git Graph."
;;   (interactive)
;;   (let ((default-directory (magit-toplevel))) ; set working directory to Git repo root
;;     (magit-log-setup-buffer
;;      '("--all") ; or '("HEAD") if you prefer
;;      nil
;;      '("--graph" "--oneline" "--decorate" "--color" "-n256")
;;      t)))


(defun my/git-graph ()
  "Run a Git Graph log in vterm."
  (interactive)
  (vterm)
  (vterm-send-string "git log --oneline --graph --all --decorate --color")
  (vterm-send-return))

;; Vterm Toggle
(defun my/vterm-toggle ()
  "Toggle a full-width vterm at the bottom of the frame."
  (interactive)
  (let ((buffer (get-buffer "*vterm*")))
    (if buffer
        (if (get-buffer-window buffer)
            (delete-window (get-buffer-window buffer))
          (progn
            (select-window (split-window (frame-root-window) -15 'below))
            (switch-to-buffer buffer)))
      (progn
        (select-window (split-window (frame-root-window) -15 'below))
        (vterm)))))


;; Dired config
(setq insert-directory-program (executable-find "gls"))
;; Set human-readable listing switches
(which-function-mode 1)
(setq-default header-line-format
   '((which-func-mode (""
   which-func-format " "))))

;; Automatically hide details in dired
(defun my/dired-hide-details ()
  "Ensure dired details are hidden by default."
  (dired-hide-details-mode 1))

  ;; Your custom global keybindings
  (global-set-key (kbd "C-x C-b") #'persp-list-buffers)
  (global-set-key (kbd "M-s-<backspace>") #'persp-kill)
  (global-set-key (kbd "M-s-<return>") #'persp-switch)
  (global-set-key (kbd "M-s-<right>") #'persp-next)
  (global-set-key (kbd "M-s-<left>") #'persp-prev)


;;
;;
 ;; Keybindings ******************************
(global-set-key (kbd "C-<backspace>") 'delete-forward-char)
(global-set-key (kbd "s-/") 'comment-line)
;; (global-set-key (kbd "C-<escape>") 'doom/escape)

(global-set-key (kbd "C-x f") ' project-find-file)
(global-set-key (kbd "s-u") 'undo)
(global-set-key (kbd "C-x d") 'dired)

;; Org
(global-set-key (kbd "C-c a") #'org-agenda)



;;; Editor ************************************
(global-set-key (kbd "C-s") 'isearch-forward)
(global-set-key (kbd "C-M-s") 'swiper-thing-at-point)
(global-set-key (kbd "C-S-s") 'isearch-backward)
;; (global-set-key (kbd "C-s-<return>") 'counsel-switch-buffer)
(global-set-key (kbd "C-s-<return>") 'consult-buffer)
;; (global-set-key (kbd "s-f") 'swiper)
(global-set-key (kbd "s-f") 'consult-line)
;; (global-set-key (kbd "s-F") 'counsel-ag)
(global-set-key (kbd "s-F") 'consult-ripgrep)
;; (global-set-key (kbd "C-s-.") 'xref-find-definitions-other-window)
(global-set-key (kbd "C-,") 'xref-go-back)
(global-set-key (kbd "C-s-.") 'perl-end-of-function)
(global-set-key (kbd "C-s-,") 'perl-beginning-of-function)
;; (global-set-key (kbd "C-.") 'xref-find-definitions)
;; (global-unset-key  (kbd "C-/") 'comment-line)
;; (global-set-key (kbd "C-<escape>") 'doom/escape)
;; (global-set-key (kbd "C-x p") 'counsel-projectile)
;; (global-set-key (kbd "C-s-<return>") 'counsel-switch-buffer)
(global-set-key (kbd "C-s-<return>") 'consult-buffer)

(global-set-key (kbd "C-x f") ' project-find-file)
(global-set-key (kbd "s-u") 'undo)
(global-set-key (kbd "C-x d") 'dired)

;; Org
(global-set-key (kbd "C-c a") #'org-agenda)

(define-key evil-normal-state-map (kbd "C-.") #'my/lookup-definition)
(global-unset-key (kbd "C-."))
;; (global-set-key (kbd "C-s-.") 'xref-find-definitions-other-window)
(global-set-key (kbd "C-,") 'xref-go-back)
;; (global-set-key (kbd "C-.") 'xref-find-definitions)
(global-unset-key  (kbd "C-."))
(global-set-key (kbd "C-.") 'my/lookup-definition)
;; (global-set-key (kbd "C-/") 'my/lookup-references)
(global-set-key (kbd "C-/") #'lsp-ui-peek-find-references)
(global-set-key (kbd "C-;") 'recenter-top-bottom)

(global-set-key (kbd "C-s-t") 'my/vterm-toggle)
(global-set-key (kbd "C-s-n") '+vterm/here)

(global-unset-key (kbd "C-e"))
(global-set-key (kbd "M-<up>") 'move-dup-move-lines-up)
(global-set-key (kbd "M-<down>") 'move-dup-move-lines-down)
(global-set-key (kbd "C-M-<up>") 'move-dup-duplicate-up)
(global-set-key (kbd "C-M-<down>") 'move-dup-duplicate-down)


;; Multi-cursor
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)



(global-set-key [C-q] 'keyboard-quit)

;; Window management
(global-set-key (kbd "C-}" ) 'split-window-right)
(global-set-key (kbd "C-{" ) 'split-window-below)
(global-set-key (kbd "C-s-<left>" ) 'windmove-left)
(global-set-key (kbd "C-s-<right>" ) 'windmove-right)
(global-set-key (kbd "C-s-<up>" ) 'windmove-up)
(global-set-key (kbd "C-s-<down>" ) 'windmove-down)
;; (global-set-key (kbd "C-}" ) 'enlarge-window-horizontally)
(global-set-key (kbd "C-s-]" ) 'my/enlarge-window-horizontally)
;; (global-set-key (kbd "C-{" ) 'shrink-window-horizontally)
(global-set-key (kbd "C-s-[" ) 'my/shrink-window-horizontally)


;; Evil Mode keybindings ****************************************

(global-set-key (kbd "C-s-h" ) 'windmove-left)
(global-set-key (kbd "C-s-l" ) 'windmove-right)
(global-set-key (kbd "C-s-k" ) 'windmove-up)
(global-set-key (kbd "C-s-j" ) 'windmove-down)

;; ***************************************************************

(global-set-key (kbd "C-s-<backspace>" ) 'delete-window)
(global-set-key (kbd "C-q" ) 'kill-buffer)


;; ;;; Editor ************************************
;; ;(global-set-key (kbd "C-s") 'consult-grep)
;; ;(global-set-key (kbd "C-M-s") 'consult-ripgrep)
;; (global-set-key (kbd "C-s") 'isearch-forward)
;; ;; (global-unset-key (kbd "s-f"))
;; ;; (global-set-key (kbd "C-M-s") 'swiper-thing-at-point)
;; (global-set-key (kbd "C-S-s") 'isearch-backward)
;; ;; (global-set-key (kbd "s-f") 'swiper)
;; (global-set-key (kbd "s-F") 'counsel-ag)
;; (global-set-key (kbd "M-s-<right>") '+workspace:switch-next)
;; (global-set-key (kbd "M-s-<left>") '+workspace:switch-previous)
;; (global-set-key (kbd "M-s-<return>") '+workspace:new)
;; (global-set-key (kbd "M-s-<b>") '+workspace:delete)

;; (global-set-key (kbd "C-;") 'recenter-top-bottom)
;; ;
;; ;; LSP **************************************
;; (global-set-key (kbd "C-s-.") 'xref-find-definitions-other-window)
;; (global-set-key (kbd "C-,") 'xref-go-back)
;; (global-set-key (kbd "C-.") 'xref-find-definitions)
;; ;; (global-set-key (kbd "C-m") 'set-mark-command)


;; (global-unset-key (kbd "C-t"))
;; (global-set-key (kbd "C-s-t") '+vterm/toggle)
;; (global-set-key (kbd "C-t") '+vterm/toggle)
;; (global-set-key (kbd "C-s-n") '+vterm/here)
;; ;(map! :after vterm
;; ;      :map vterm-mode-map
;; ;      "C-\]" #'my-vterm/split-right )


;; (global-unset-key (kbd "C-e"))
;; (global-set-key (kbd "M-<up>") 'move-dup-move-lines-up)
;; (global-set-key (kbd "M-<down>") 'move-dup-move-lines-down)
;; (global-set-key (kbd "C-M-<up>") 'move-dup-duplicate-up)
;; (global-set-key (kbd "C-M-<down>") 'move-dup-duplicate-down)


;; ;; Multi-cursor
;; (require 'multiple-cursors)
;; (global-set-key (kbd "C->") 'mc/mark-next-like-this)
;; (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)



;; (global-set-key [C-q] 'keyboard-quit)

;; ;; Window management
;; (global-set-key (kbd "C-s-]" ) 'split-window-right)
;; (global-set-key (kbd "C-s-[" ) 'split-window-below)
;; (global-set-key (kbd "C-s-<left>" ) 'windmove-left)
;; (global-set-key (kbd "C-s-<right>" ) 'windmove-right)
;; (global-set-key (kbd "C-s-<up>" ) 'windmove-up)
;; (global-set-key (kbd "C-s-<down>" ) 'windmove-down)
;; (global-set-key (kbd "C-}" ) 'enlarge-window-horizontally)
;; (global-set-key (kbd "C-{" ) 'shrink-window-horizontally)
;; (global-set-key (kbd "C-s-<return>" ) 'counsel-switch-buffer)


;; ;; Evil Mode keybindings ****************************************

;; (global-set-key (kbd "C-s-h" ) 'windmove-left)
;; (global-set-key (kbd "C-s-l" ) 'windmove-right)
;; (global-set-key (kbd "C-s-k" ) 'windmove-up)
;; (global-set-key (kbd "C-s-j" ) 'windmove-down)

;; ;; ***************************************************************



;; ;; (global-set-key (kbd "C-s-<return>" ) 'consult-buffer)
;; ;; (global-set-key (kbd "C-s-k" ) 'delete-window)
;; (global-set-key (kbd "C-s-<backspace>" ) 'delete-window)
;; (global-set-key (kbd "C-q" ) 'kill-buffer)
;; ;(global-set-key (kbd "C-x-<right>" ) 'next-buffer)
;; ;(global-set-key (kbd "C-x-<left>" ) 'prev-buffer)

;; (global-set-key (kbd "s-1") '+treemacs/toggle)


(provide 'init)
;;; init.el ends here
(run-with-idle-timer
 3 nil
 (lambda ()
   (require 'projectile)
   (require 'persp-mode)
   (require 'lsp-mode)
   (projectile-mode 1)
   ;; Optionally preload projects if you use a known folder structure
   (setq projectile-project-search-path '("/Volumes/work/"))
   (projectile-discover-projects-in-search-path)

   ;; Wait even longer if needed
   (run-with-idle-timer
    1 nil
    (lambda ()
      (when (fboundp 'persp-state-load)
        (message "Loading perspectives now...")
        (persp-state-load))))))
