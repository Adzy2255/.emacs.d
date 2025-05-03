 ;; init.el --- Converted from Doom Emacs to Vanilla Emacs with Evil mode

(setq user-full-name "Adam Johnson"
       user-mail-address "adam.johnson@akips.com")

;; Initialize package sources
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
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


;; Window
(set-frame-parameter (selected-frame) 'alpha '(85 . 85)) (add-to-list 'default-frame-alist '(alpha . (85 . 85)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))


;; EXWM Window Manager
(require 'exwm)
;; Set the initial workspace number.
(setq exwm-workspace-number 4)
;; Make class name the buffer name.
(add-hook 'exwm-update-class-hook
  (lambda () (exwm-workspace-rename-buffer exwm-class-name)))
;; Global keybindings.
(setq exwm-input-global-keys
      `(([?\s-r] . exwm-reset) ;; s-r: Reset (to line-mode).
        ([?\s-w] . exwm-workspace-switch) ;; s-w: Switch workspace.
        ([?\s-&] . (lambda (cmd) ;; s-&: Launch application.
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command cmd nil cmd)))
        ;; s-N: Switch to certain workspace.
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))
;; Enable EXWM
(exwm-enable)



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

;; Font
;; You will most likely need to adjust this font size for your system!
(defvar default-font-size 140)
(set-face-attribute 'default nil :font "Fira Code Retina" :height default-font-size)


;; Theme
(use-package doom-themes
  :config
  (load-theme 'doom-one t))

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
;(use-package doom-modeline
;  :init (doom-modeline-mode 1)
;  :custom
;  (doom-modeline-height 25))

;; Which-key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(unless (package-installed-p 'llama)
  (package-refresh-contents)
  (package-install 'llama))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package counsel
  :ensure t)

(use-package counsel-projectile
  :ensure t
  :after (counsel projectile)
  :config
  (counsel-projectile-mode))

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

(use-package all-the-icons);; Magit

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Org mode
(use-package org
  :config
  (setq org-directory "~/org/"
        org-agenda-files (list org-directory)))

;; Line numbers
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

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


;; Parentheses
(electric-pair-mode 1)
(show-paren-mode 1)

;; Improve scrolling
(setq scroll-margin 5
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; Better minibuffer completion with vertico
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom (completion-styles '(orderless)))

(use-package marginalia
  :init (marginalia-mode))

;; (use-package consult)
;; (use-package embark)
;; (use-package embark-consult)

;; Move-duo
(use-package move-dup)


(use-package ivy-file-preview
  :ensure t)
(ivy-file-preview-mode 1)
(global-move-dup-mode 1)

;; Cursor options.
(blink-cursor-mode 1)
(setq blink-cursor-blinks 0) ;; Blink forever instead of only for 10 seconds.

;; Calendar
(require 'calfw)
(require 'calfw-org)

;; Beacon
(use-package beacon
  :ensure t)
(beacon-mode 1)
(global-set-key (kbd "C-s-b") 'beacon-blink)


;; SNMP
(defun snmpv2-hook ()
  (cond ((string-match "^/Volumes/Sensitive/akips/mib/" buffer-file-name)
         (snmpv2-mode 1))))
(add-hook 'fundamental 'snmpv2-hook)


;; Perl
(setq-default eglot-workspace-configuration
                '((:perlnavigator . (:perlPath
                              "/usr/bin/perl"
                              :enableWarnings t))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((cperl -mode perl-mode) . ("/Users/atj/perlnavigator/server/bin/perlnavigator", "--stdio"))))

(add-hook 'cperl-mode-hook 'eglot-ensure)
(add-hook 'cperl-mode-hook
   (setq-default indent-tabs-mode nil)
   (setq-default tab-width 3)
   (setq indent-line-function 'insert-tab))

(add-hook 'perl-mode-hook 'eglot-ensure)

;(add-to-list 'load-path "~/plsense") ; Adjust path if necessary
;(require 'plsense)
;(plsense-config-default)


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
  (org-roam-setup))

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

;; Org Themes
(setq org-todo-keyword-faces
    '(("NEXT" . "tomato")
    ("START" . "cornflowerblue")
    ("WAITING" . "palegoldenrod")
    ("HOLD" . "lightsalmon")
    ("BLOCKED" . "red")))

(let* ((variable-tuple (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                ((x-list-fonts "Verdana")         '(:font "Verdana"))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1 :foreground "mediumpurple"))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.1 :foreground "salmon"))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.2 :foreground "cornflowerblue"))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
     '(variable-pitch ((t (:family "ETBembo" :height 150 :weight thin))))
     '(fixed-pitch ((t ( :family "Fira Code Retina" :height 130))))
     '(org-block ((t (:inherit fixed-pitch))))
     '(org-code ((t (:inherit (shadow fixed-pitch)))))
     '(org-document-info ((t (:foreground "dark orange"))))
     '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
     '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
     '(org-link ((t (:foreground "royal blue" :underline t))))
     '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
     '(org-property-value ((t (:inherit fixed-pitch))) t)
     '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
     '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
     '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
     '(org-verbatim ((t (:inherit (shadow fixed-pitch)))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))


;; Performance
(setq gc-cons-threshold (* 50 1000 1000))

;; Keybindingd
(global-unset-key (kbd "ESC ESC ESC"))

(global-set-key (kbd "C-<backspace>") 'delete-forward-char)
(global-set-key (kbd "C-/") 'comment-line)
;(global-set-key (kbd "S-s-<up>") 'move-text-up)
;(global-set-key (kbd "S-s-<down>") 'move-text-down)
(global-set-key (kbd "C-<escape>") 'doom/escape)
(global-set-key (kbd "C-x p") 'counsel-projectile)
(global-set-key (kbd "C-x f") 'counsel-find-file)
(global-set-key (kbd "C-s-<return>") 'counsel-switch-buffer)

(global-set-key (kbd "C-x f") ' project-find-file)
(global-set-key (kbd "s-u") 'undo)
(global-set-key (kbd "C-x d") 'dired)

;; Org
(global-set-key (kbd "C-c a") #'org-agenda)



;;; Editor ************************************
;(global-set-key (kbd "C-s") 'consult-grep)
;(global-set-key (kbd "C-M-s") 'consult-ripgrep)
(global-set-key (kbd "C-s") 'isearch-forward)
;; (global-unset-key (kbd "s-f"))
(global-set-key (kbd "C-M-s") 'swiper-thing-at-point)
(global-set-key (kbd "C-S-s") 'isearch-backward)
(global-set-key (kbd "s-f") 'swiper)
(global-set-key (kbd "s-F") 'counsel-ag)
(global-set-key (kbd "M-s-<right>") '+workspace:switch-next)
(global-set-key (kbd "M-s-<left>") '+workspace:switch-previous)
(global-set-key (kbd "M-s-<return>") '+workspace:new)
(global-set-key (kbd "M-s-<b>") '+workspace:delete)

(global-set-key (kbd "C-;") 'recenter-top-bottom)
;
;; LSP **************************************
(global-set-key (kbd "C-s-.") 'xref-find-definitions-other-window)
(global-set-key (kbd "C-,") 'xref-go-back)
(global-set-key (kbd "C-.") 'xref-find-definitions)
;; (global-set-key (kbd "C-m") 'set-mark-command)


(global-unset-key (kbd "C-t"))
(global-set-key (kbd "C-s-t") '+vterm/toggle)
(global-set-key (kbd "C-t") '+vterm/toggle)
(global-set-key (kbd "C-s-n") '+vterm/here)
;(map! :after vterm
;      :map vterm-mode-map
;      "C-\]" #'my-vterm/split-right )


(global-unset-key (kbd "C-e"))
(global-set-key (kbd "M-<up>") 'move-dup-move-lines-up)
(global-set-key (kbd "M-<down>") 'move-dup-move-lines-down)
(global-set-key (kbd "C-M-<up>") 'move-dup-duplicate-up)
(global-set-key (kbd "C-M-<down>") 'move-dup-duplicate-down)


;; Multi-cursor
(require 'multiple-cursors)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)



(global-set-key [C-q] 'keyboard-quit)

;; Window management
(global-set-key (kbd "C-s-]" ) 'split-window-right)
(global-set-key (kbd "C-s-[" ) 'split-window-below)
(global-set-key (kbd "C-s-<left>" ) 'windmove-left)
(global-set-key (kbd "C-s-<right>" ) 'windmove-right)
(global-set-key (kbd "C-s-<up>" ) 'windmove-up)
(global-set-key (kbd "C-s-<down>" ) 'windmove-down)
(global-set-key (kbd "C-}" ) 'enlarge-window-horizontally)
(global-set-key (kbd "C-{" ) 'shrink-window-horizontally)
(global-set-key (kbd "C-s-<return>" ) 'counsel-switch-buffer)


;; Evil Mode keybindings ****************************************

(global-set-key (kbd "C-s-h" ) 'windmove-left)
(global-set-key (kbd "C-s-l" ) 'windmove-right)
(global-set-key (kbd "C-s-k" ) 'windmove-up)
(global-set-key (kbd "C-s-j" ) 'windmove-down)

;; ***************************************************************



;; (global-set-key (kbd "C-s-<return>" ) 'consult-buffer)
;; (global-set-key (kbd "C-s-k" ) 'delete-window)
(global-set-key (kbd "C-s-<backspace>" ) 'delete-window)
(global-set-key (kbd "C-q" ) 'kill-buffer)
;(global-set-key (kbd "C-x-<right>" ) 'next-buffer)
;(global-set-key (kbd "C-x-<left>" ) 'prev-buffer)

(global-set-key (kbd "s-1") '+treemacs/toggle)


(provide 'init)
;;; init.el ends here
