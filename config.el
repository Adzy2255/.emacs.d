(require 'org)
  (require 'ob-tangle)

(defun my/org-babel-tangle-config ()
    (when (string-equal (buffer-file-name)
                        (expand-file-name "config.org" user-emacs-directory))
      (org-babel-tangle)))

(setq org-confirm-babel-evaluate nil)

(add-hook 'after-save-hook #'my/org-babel-tangle-config)

;; Disable the built-in startup screen *as early as possible*
(setq inhibit-startup-screen t)

;; Tell Emacs to use the dashboard buffer as the initial buffer
(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

;; Setup package system
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Refresh packages if missing
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if missing
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq doom-font (font-spec :family "JetBrainsMonoNL Nerd Font Mono" :size 14))
(set-fontset-font t 'unicode "JetBrainsMonoNL Nerd Font Mono" nil 'prepend)

(use-package all-the-icons
  :ensure t
  :init
  ;; Install fonts if not already installed
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))

(use-package doom-themes
  :config
  ;; (load-theme 'doom-nord-aurora t)
  (load-theme 'doom-city-lights t)
)

(setq-default cursor-type 'bar)

(setq-default buffer-file-coding-system 'unix)

(add-to-list 'default-frame-alist '(alpha . (85 . 85)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq org-agenda-use-tag-inheritance t)
(setq org-agenda-inhibit-startup nil)
(setq org-agenda-inhibit-startup-visibility nil)

(setq org-agenda-sticky t) ;; allows caching
(setq org-agenda-use-tag-inheritance t)
(setq org-agenda-entry-text-maxlines 5)

;; ✅ The key line:
(setq org-agenda-caching t)

(use-package beacon
  :ensure t
  :init
  (beacon-mode 1)
  :bind
  ("C-s-b" . beacon-blink))

;; Disable splash screen early
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq initial-buffer-choice nil)
(setq org-agenda-span 1)
(setq org-agenda-start-day nil)
(setq org-agenda-files '("~/RoamNotes/"))

(use-package dashboard
  :ensure t
  :init
  ;; Appearance
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-set-init-info nil)
  (setq dashboard-set-footer nil)
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)

  ;; Dashboard content
  (setq dashboard-items
        '((recents    . 5)
          (bookmarks  . 5)
          (agenda     . 5)
          (projects   . 5)))

  :config
  ;; Enable dashboard
  (dashboard-setup-startup-hook)

  ;; Cursor and UI tweaks
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (hl-line-mode 1)
              (setq-local cursor-type 'box)
              (setq-local line-move-visual t)
              (setq-local inhibit-read-only t)
              (read-only-mode 1)
              (setq-local revert-buffer-function #'ignore)))

  ;; Strip full paths from recent files
  (defun my/dashboard-replace-paths-with-filenames (files)
    (mapcar #'file-name-nondirectory files))
  (advice-add 'dashboard-recentf-list :filter-return
              #'my/dashboard-replace-paths-with-filenames)

  ;; Strip full paths from bookmark list
  (advice-add 'dashboard-bookmarks-list :filter-return
              (lambda (bookmarks)
                (mapcar (lambda (bmk)
                          (list (car bmk)
                                (cdr bmk)))
                        bookmarks)))

  ;; Show dashboard on startup
  (add-hook 'emacs-startup-hook
            (lambda ()
              (dashboard-refresh-buffer)
              (switch-to-buffer "*dashboard*")))

  ;; Manual dashboard key
  (defun my/open-dashboard ()
    (interactive)
    (dashboard-refresh-buffer)
    (switch-to-buffer "*dashboard*"))
  (global-set-key (kbd "C-c d") #'my/open-dashboard)
)

;; Disable GUI elements
(menu-bar-mode -1)    ;; Disable the top menu bar
(tool-bar-mode -1)    ;; Disable the tool bar
(scroll-bar-mode -1)  ;; Disable scroll bars

;; Resizing windows
(defun my/enlarge-window-horizontally ()
  "Enlarge window horizontally by 10 columns."
  (interactive)
  (enlarge-window-horizontally 20))

(defun my/shrink-window-horizontally ()
  "Shrink window horizontally by 10 columns."
  (interactive)
  (shrink-window-horizontally 20))

;; Unbind M-S-RET in org-mode so it can pass through to perspective
(global-set-key (kbd "M-s-<backspace>") #'persp-kill)
(global-set-key (kbd "M-s-<return>") #'persp-switch)
(global-set-key (kbd "M-s-<right>") #'persp-next)
(global-set-key (kbd "M-s-<left>") #'persp-prev)

(use-package persp-mode
  :ensure t
  :init
  (setq
   persp-auto-save-opt 1                                  ;; auto-save on exit
   persp-auto-resume-time -1  ;; disable auto-resume
   persp-auto-save-fname "autosave"                       ;; file to save state
   persp-save-dir (expand-file-name "persp/" user-emacs-directory)
   persp-set-last-persp-for-new-frames nil
   persp-add-buffer-on-find-file t
   persp-add-buffer-on-after-change-major-mode t
   persp-autokill-buffer-on-remove 'kill-weak
   persp-save-buffer-data-hash t
   persp-is-ibc-as-resbuf t)

  :config
  (persp-mode 1)

  ;; 🚀 Save window layout for each perspective
  (defvar my/persp-window-states (make-hash-table :test #'equal)
    "Window layouts saved per perspective.")

  (defun my/persp-store-window-layout (&rest _)
    (when (bound-and-true-p persp-mode)
      (let ((name (safe-persp-name (get-current-persp))))
        (puthash name (current-window-configuration) my/persp-window-states))))

  (defun my/persp-restore-window-layout (&rest _)
    (when (bound-and-true-p persp-mode)
      (let* ((name (safe-persp-name (get-current-persp)))
             (config (gethash name my/persp-window-states)))
        (when config
          (set-window-configuration config)))))

  ;; Hook layout logic to perspective switching
  (add-hook 'persp-before-switch-functions #'my/persp-store-window-layout)
  (add-hook 'persp-activated-functions #'my/persp-restore-window-layout)

  ;; Save all layouts before Emacs exits
  (add-hook 'kill-emacs-hook #'persp-save-state-to-file)
)

(defun my/kill-buffer-no-prompt ()
  "Kill the current buffer without confirmation, even if modified."
  (interactive)
  (set-buffer-modified-p nil)  ;; Mark buffer as unmodified
  (kill-this-buffer))

(defun my/revert-buffer-no-confirm ()
  "Revert the current buffer without confirmation.
Special handling for Dired and Magit buffers."
  (interactive)
  (cond
   ;; Refresh Dired
   ((derived-mode-p 'dired-mode)
    (revert-buffer nil t)) ;; no prompt

   ;; Refresh Magit buffers
   ((derived-mode-p 'magit-mode)
    (magit-refresh))

   ;; Generic revert for other buffers
   (t
    (with-demoted-errors "Revert error: %S"
      (let ((revert-without-query '(".*")))
        (revert-buffer nil t t))))))

(use-package avy
  :ensure t)

(defun my/yank-word ()
  "Copy the word at point to the kill ring."
  (interactive)
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (if bounds
        (progn
          (kill-ring-save (car bounds) (cdr bounds))
          (message "Word yanked"))
      (message "No word at point"))))

(defun my/copy-region-or-line ()
  "Copy region if active, otherwise copy the current line."
  (interactive)
  (if (use-region-p)
      (kill-ring-save (region-beginning) (region-end))
    (kill-new (buffer-substring (line-beginning-position)
                                (line-beginning-position 2)))))

(defun my/copy-defun ()
  "Copy the entire defun at point to the kill ring."
  (interactive)
  (save-excursion
    (mark-defun)
    (kill-ring-save (region-beginning) (region-end)))
  (message "Function copied"))

(defun kill-line-or-region ()
  "Kill the active region, or the current line if no region is active."
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))

(defun my/kill-defun ()
  "Kill (cut) the entire defun at point."
  (interactive)
  (save-excursion
    (mark-defun)
    (kill-region (region-beginning) (region-end)))
  (message "Function killed"))

(defun my/escape-quit ()
  "Like `keyboard-quit`, but safer and consistent."
  (interactive)
  (cond
   ;; Quit minibuffer or prompts
   ((minibufferp)
    (abort-recursive-edit))
   ;; Quit active region
   ((use-region-p)
    (deactivate-mark))
   ;; Close popups (e.g. help, which-key, completions)
   ((get-buffer-window "*Completions*")
    (delete-window (get-buffer-window "*Completions*")))
   ;; Otherwise: fallback
   (t
    (keyboard-quit))))

;; (global-set-key (kbd "<escape>") #'my/escape-quit)

(defun my/mark-line ()
  "Mark the current line and keep region active for extending."
  (interactive)
  (push-mark (line-beginning-position) nil t)
  (goto-char (line-beginning-position 2)))

;;(defun my/set-mark-c-m ()
;;  "Bind C-m to `set-mark-command` except in the minibuffer."
 ;; (unless (minibufferp)
 ;;   (local-set-key (kbd "C-m") #'set-mark-command)))

;;(add-hook 'after-change-major-mode-hook #'my/set-mark-c-m)

(defun my/forward-to-last-non-comment-or-eol ()
  "Move point to the last non-comment, non-whitespace character on the line.
If the line is only a comment, go to the start of the comment.
If there's no comment, go to the last non-whitespace character before EOL."
  (interactive)
  (let* ((eol (line-end-position))
         (bol (line-beginning-position))
         (comment-start (save-excursion
                          (goto-char bol)
                          (let ((state nil))
                            (while (and (< (point) eol)
                                        (not (setq state (syntax-ppss (point))))
                                        (not (nth 4 state)))
                              (forward-char))
                            (when (nth 4 state)
                              (nth 8 state))))))
    (goto-char (or comment-start eol))
    (skip-chars-backward " \t" bol)))



(defun my/toggle-bol-and-indent ()
  "Toggle point between first non-whitespace char and beginning of line.
Defaults to moving to first non-whitespace char."
  (interactive)
  (let ((bol (line-beginning-position))
        (first-non-ws (save-excursion
                        (back-to-indentation)
                        (point))))
    (if (= (point) first-non-ws)
        (goto-char bol)
      (goto-char first-non-ws))))



(use-package multiple-cursors
  :ensure t)

(with-eval-after-load 'isearch
  (define-key isearch-mode-map (kbd "C-k") #'isearch-repeat-forward)
  (define-key isearch-mode-map (kbd "C-i") #'isearch-repeat-backward))

(use-package highlight-numbers
  :ensure t
  :hook (prog-mode . highlight-numbers-mode))

(global-display-line-numbers-mode 1)

(use-package move-dup
  :ensure t)

(defun indent-region-advice (&rest ignored)
  (let ((deactivate deactivate-mark))
    (if (region-active-p)
        (indent-region (region-beginning) (region-end))
      (indent-region (line-beginning-position) (line-end-position)))
    (setq deactivate-mark deactivate)))

(advice-add 'move-text-up :after 'indent-region-advice)
(advice-add 'move-text-down :after 'indent-region-advice)

(electric-pair-mode 1)
(show-paren-mode 1)

(setq scroll-margin 5
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; (use-package rainbow-delimiters
;;   :ensure t
;;   :hook (prog-mode . rainbow-delimiters-mode))

(use-package typescript-mode
  :ensure t
  :mode ("\\.ts\\'" . typescript-mode)
  :hook (typescript-mode . lsp-deferred))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode)) ;; if using `tsx` support

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook ((html-mode
          js-mode
          js-ts-mode
          typescript-mode
          typescript-ts-mode
          web-mode
          perl-mode
          cperl-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"              ;; Optional: lsp command prefix
        lsp-completion-provider :capf)         ;; Use capf with corfu/cape
  :config
  (setq lsp-enable-symbol-highlighting t
        lsp-enable-snippet t                   ;; Required for yasnippet
        lsp-headerline-breadcrumb-enable nil
        lsp-log-io nil))

  ;; Lookup definitions
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

  ;; Lookup references
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
  ;; Remove LSP xref if unsupported
  (defun my/remove-lsp-xref-if-no-references ()
    "Remove LSP xref backend if references aren't supported."
    (when (and (bound-and-true-p lsp-mode)
               (not (lsp-feature? "textDocument/references")))
      (setq-local xref-backend-functions
                  (remove #'lsp--xref-backend xref-backend-functions))))

  (add-hook 'lsp-managed-mode-hook #'my/remove-lsp-xref-if-no-references)

;; Optional LSP UI extras
(use-package lsp-ui
  :ensure t
  :init
    (setq lsp-completion-provider :capf)
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-delay 0.2
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-show-with-cursor t
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-doc-show-with-mouse nil))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package consult
  :ensure t
  :bind
  ;; (("C-s" . consult-line)
   ;; ("C-x b" . consult-buffer)))
)

(setq tab-width 3 ;; or any other preferred value
          c-basic-offset tab-width
          cperl-indent-level tab-width)
(setq cperl-indent-level 3)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 3)
(setq indent-line-function 'insert-tab)
(setq c-basic-offset 3)
(setq c-basic-indent 3)

(add-hook 'cperl-mode-hook
   (setq-default indent-tabs-mode nil)
   (setq-default tab-width 3)
   (setq indent-line-function 'insert-tab))

(use-package eglot
  :ensure t
  :hook (cperl-mode . eglot-ensure)
  :config
  ;; Register Perl Language Server for cperl-mode
  (add-to-list 'eglot-server-programs
               '(cperl-mode . ("perl" "-MPerl::LanguageServer" "-e" "Perl::LanguageServer::run" "--" "--stdio"))))
  (add-hook 'cperl-mode-hook 'eglot-ensure)
  ;; (use-package eglot
  ;;    :config
  ;;    (add-to-list 'eglot-server-programs
  ;;                `(cperl-mode . ("PerlLanguageServer" "--stdio"))))
;;  )

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
  "Return non-nil if FILENAME is a regular file under `my/snmpv2-dir` and has no extension."
  ;; (message "Checking filename: %s" filename)
  (and filename
       (not (file-directory-p filename))
       (string-prefix-p (expand-file-name my/snmpv2-dir)
                        (expand-file-name filename))
       (not (file-name-extension filename))))

  (add-hook 'find-file-hook #'my/maybe-enable-snmpv2-mode)

(use-package magit
  :ensure t)

;; Load Copilot (from local source if not using MELPA)
(use-package copilot
  :load-path "~/copilot.el"  ;; adjust as needed
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main")
  :hook (prog-mode . copilot-mode)
  :init
  (setq copilot-max-char 5000000)  ;; or smaller for performance
  :config
  ;; Accept completion with C-TAB or customize your key
  (define-key copilot-mode-map (kbd "C-<tab>")
    (lambda ()
      (interactive)
      (or (copilot-accept-completion)
          (indent-for-tab-command))))
  ;; Optional: if you're using corfu
  ;; don't need to disable it unless you experience visual conflict
  )

(use-package cape
  :ensure t)

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :config
  ;; Ensure CAPEs are loaded
  (require 'cape)

  (setq completion-at-point-functions
        (list
         #'cape-file
         (cape-capf-buster #'cape-keyword)
         #'cape-dabbrev)))

(use-package dumb-jump
  :ensure t
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))
(setq dumb-jump-force-searcher 'rg) ;; or 'ag or 'grep

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package which-func
  :ensure nil  ;; built-in
  :init
  (which-function-mode 1)
  (setq-default header-line-format
                '((which-func-mode (" " which-func-format " ")))))

(use-package dired
  :ensure nil  ;; built-in
  :config
  ;; Hide details after window configuration is stable
  (defun my/dired-enable-hide-details ()
    "Force hide-details after Dired setup is completely done."
    (when (derived-mode-p 'dired-mode)
      (dired-hide-details-mode 1)
      (remove-hook 'window-configuration-change-hook #'my/dired-enable-hide-details)))

  (add-hook 'dired-mode-hook
            (lambda ()
              (add-hook 'window-configuration-change-hook
                        #'my/dired-enable-hide-details)))

  ;; Use GNU ls if available (e.g., coreutils on macOS)
  (when-let ((gls (executable-find "gls")))
    (setq insert-directory-program gls)))

;; Automatically hide details in dired
(defun my/dired-hide-details ()
  "Ensure Dired details are hidden by default."
  (dired-hide-details-mode 1))

(add-hook 'dired-mode-hook #'my/dired-hide-details)

(use-package dired-filter :ensure t)
(use-package dired-details :ensure t)

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))  ; Shift-TAB

(with-eval-after-load 'dired
  (general-define-key
   :keymaps 'dired-mode-map
   "<left>"  'dired-up-directory
   "<right>" 'dired-find-file
   "<up>"    'previous-line
   "<down>"  'next-line
   "j"       'dired-up-directory
   "C-j"     'dired-up-directory
   "l"       'dired-find-file
   "C-l"     'dired-find-file))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  ;; Optional: update in real-time as you type
  (diff-hl-flydiff-mode))

(setq magit-log-arguments '("--graph" "--decorate" "--color"))

(defun my/git-graph ()
  "Run a Git Graph log in vterm."
  (interactive)
  (vterm)
  (vterm-send-string "git log --oneline --graph --all --decorate --color")
  (vterm-send-return))

;; (custom-set-faces!
;; '(markdown-header-delimiter-face :foreground "#616161" :height 0.9)
;; '(markdown-header-face-1 :height 1.8 :foreground "#A3BE8C" :weight extra-bold :inherit markdown-header-face)
;; '(markdown-header-face-2 :height 1.4 :foreground "#EBCB8B" :weight extra-bold :inherit markdown-header-face)
;; '(markdown-header-face-3 :height 1.2 :foreground "#D08770" :weight extra-bold :inherit markdown-header-face)
;; '(markdown-header-face-4 :height 1.15 :foreground "#BF616A" :weight bold :inherit markdown-header-face)
;; '(markdown-header-face-5 :height 1.1 :foreground "#b48ead" :weight bold :inherit markdown-header-face)
;; '(markdown-header-face-6 :height 1.05 :foreground "#5e81ac" :weight semi-bold :inherit markdown-header-face))

(defun nb/refontify-on-linemove ()
  "Post-command-hook"
  (let* ((start (line-beginning-position))
         (end (line-beginning-position 2))
         (needs-update (not (equal start (car nb/current-line)))))
    (setq nb/current-line (cons start end))
    (when needs-update
      (font-lock-fontify-block 3))))

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

(defun nb/markdown-unhighlight ()
   "Enable markdown concealling"
   (interactive)
   (markdown-toggle-markup-hiding 'toggle)
   (font-lock-add-keywords nil '((nb/unhide-current-line)) t)
   (add-hook 'post-command-hook #'nb/refontify-on-linemove nil t))

(add-hook 'markdown-mode-hook #'nb/markdown-unhighlight)

(defun my/minibuffer-nav-keys ()
  ;; VIM
  ;; (define-key minibuffer-local-map (kbd "C-j") #'next-line)
  ;; (define-key minibuffer-local-map (kbd "C-k") #'previous-line)
  ;; (define-key minibuffer-local-map (kbd "C-h") #'backward-char)
  ;; (define-key minibuffer-local-map (kbd "C-l") #'forward-char))
  ;; WASD
  (define-key minibuffer-local-map (kbd "C-k") #'next-line)
  (define-key minibuffer-local-map [C-i-real] #'previous-line)
  (define-key minibuffer-local-map (kbd "C-j") #'backward-char)
  (define-key minibuffer-local-map (kbd "C-l") #'forward-char))

(add-hook 'minibuffer-setup-hook #'my/minibuffer-nav-keys)

(setq org-directory "~/org/")

(use-package org
  :ensure nil  ;; built-in, don't reinstall
  :hook (org-mode . org-indent-mode)
  :config
  ;; Hide leading stars
  (setq org-hide-leading-stars t)
  (set-face-attribute 'org-hide nil
                      :foreground (face-background 'default))

  ;; Smarter RET behavior
  (defun my/org-return-dwim ()
    "If point is on an Org link, open it. Otherwise, behave like `org-return`."
    (interactive)
    (let ((context (org-element-context)))
      (if (eq (org-element-type context) 'link)
          (org-open-at-point)
        (org-return))))

  (define-key org-mode-map (kbd "RET") #'my/org-return-dwim)

  ;; WASD navigation
  (define-key org-mode-map (kbd "C-k") #'next-line)
  (define-key org-mode-map (kbd "C-i") #'previous-line) ;; Use C-i instead of imaginary [C-i-real]
  (define-key org-mode-map (kbd "C-j") #'backward-char)
  (define-key org-mode-map (kbd "C-l") #'forward-char))

(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "TAB") #'org-cycle)))

(add-to-list 'exec-path "~/.local/bin")
(use-package alert
  :ensure t
  :config
  (setq alert-default-style 'notifier))

(use-package org-alert
  :ensure t
  :after (org alert)
  :config
  (setq org-alert-interval 300
        org-alert-notification-title "Org Alert"
        org-alert-notification-icon nil
        org-alert-notify-cutoff 10
        org-alert-notify-after-event-cutoff 10
        org-alert-days-to-check 1
        org-alert-using-alert t)
  (org-alert-enable))

(with-eval-after-load 'org
:defer t
  :config
  ;; Agenda display
  (setq org-agenda-time-leading-zero t)
  (setq org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " " " "))
  (setq org-agenda-prefix-format
        '((agenda . " %?-6t ")
          (todo . "  ")
          (tags . "  ")
          (search . "  ")))
  (setq org-agenda-span 1)
  (setq org-agenda-start-day nil)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-show-future-repeats nil)
  (setq org-agenda-skip-scheduled-if-not-today t)
  (setq org-agenda-skip-deadline-if-not-due t)

  ;; Disable line numbers
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0)))
  (add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode 0)))

  ;; TODO keywords
  (setq org-todo-keywords
        '((sequence "TODO" "NEXT" "START" "WAIT" "HOLD" "BLOCK" "|" "DONE" "KILL" "NOTE")))

  ;; Agenda files (recursive search)
  (setq org-agenda-files
        (directory-files-recursively "~/RoamNotes" "\\.org$"))

  ;; Tags
  (setq org-tag-alist
        '(("@MIBS" . ?m)
          ("@MIB_REPORTS" . ?r)
          ("EMAIL" . ?e)
          ("SLACK" . ?s)
          ("MEETING" . ?M)
          ("@BACKLOG" . ?b)
          ("@RELEASE" . ?R))))

(add-hook 'org-agenda-finalize-hook #'org-modern-agenda)

(defun my/org-meta-return-toggle-done ()
  "Toggle TODO state to DONE when on a heading; otherwise behave like org-meta-return.
Does not insert a new heading if toggling TODO to DONE."
  (interactive)
  (if (and (org-at-heading-p)
           (org-get-todo-state))
      (org-todo (if (string= (org-get-todo-state) "DONE") "TODO" "DONE"))
    (org-meta-return)))

(use-package elegant-agenda-mode
  :defer t
  :hook org-agenda-mode-hook)
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

(use-package calfw
  :ensure t)

(use-package calfw-org
  :ensure t
  :after calfw
  :config
  ;; Optional: open the calendar with a function
  (defun my/open-org-calendar ()
    "Open the Org-mode calendar view."
    (interactive)
    (cfw:open-org-calendar)))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-file-name-style 'auto))

(setq org-startup-with-inline-images t)

(use-package org-download
  :defer t
  :after org
  ;; Where to save images (relative to current Org file)
  :config
    (setq org-download-image-dir "Images"
        org-download-heading-lvl nil
        org-download-backend "pngpaste"
        org-download-screenshot-method "pngpaste %s"
        org-download-link-format "[[file:%s]]")

  ;; Auto-show images after download
  (add-hook 'org-download-after-download-hook #'org-display-inline-images))

(use-package org-mime
  :defer t
  :after org
  :config
  (setq org-mime-export-options
        '(:section-numbers nil
          :with-author nil
          :with-toc nil
          :with-title nil)))

(defun my/org-export-html-to-rtf-clipboard ()
  "Export Org buffer to RTF with fixed heading colors and copy to clipboard on macOS."
  (interactive)
  (require 'ox-html)
  (let* ((org-export-with-toc nil)
         (org-export-with-section-numbers nil)
         ;; Hardcoded colors (adjust as needed)
         (h1-color "#003366")   ; Dark navy
         (h2-color "#1a73e8")   ; Bright blue
         (h3-color "#BFA2DB") ; Pastel Violet
         (h4-color "#355E3B") ; Hunter Green
         (todo-color "#dc2626")  ; Red for TODO
         (html (org-export-as 'html nil nil t nil))
         (styled-html
          (format "<style>
  body { font-family: -apple-system, sans-serif; line-height: 1.4; font-size: 14px; color: #111827; }
  h1 { color: %s; margin: 1em 0 0.2em 0; }
  h2 { color: %s; margin: 0.5em 0 0.2em 0; }
  h3 { color: %s; margin: 0.5em 0 0.2em 0; }
  h4 { color: %s; margin: 0.5em 0 0.2em 0; }
  .todo { color: %s; font-weight: bold; }
  ul, ol { margin: 0.2em 0 0.2em 1em; padding-left: 1em; }
  li { margin: 0.1em 0; }
  p { margin: 0.2em 0; }
</style>\n%s"
                  h1-color h2-color h3-color h4-color todo-color html))
         (tmp-html (make-temp-file "org-export-" nil ".html"))
         (tmp-rtf (make-temp-file "org-export-" nil ".rtf")))
    (with-temp-file tmp-html
      (insert styled-html))
    (call-process "textutil" nil nil nil "-convert" "rtf" "-output" tmp-rtf tmp-html)
    (with-temp-buffer
      (insert-file-contents tmp-rtf)
      (call-process-region (point-min) (point-max) "pbcopy"))
    (delete-file tmp-html)
    (delete-file tmp-rtf)
    (message "RTF content with fixed theme copied to clipboard.")))

(defun my/org-export-to-markdown-clipboard ()
  "Export Org buffer to Markdown and copy to macOS clipboard."
  (interactive)
  (require 'ox-md)
  (let ((md (org-export-as 'md nil nil t nil)))
    (with-temp-buffer
      (insert md)
      (call-process-region (point-min) (point-max) "pbcopy"))
    (message "Markdown copied to clipboard.")))

(defun my/org-table-wrap-fix ()
  "Truncate lines inside Org tables only; wrap elsewhere."
  (when (eq major-mode 'org-mode)
    (setq-local truncate-lines (org-at-table-p))
    (setq-local word-wrap (not (org-at-table-p)))))

(add-hook 'org-mode-hook
  (lambda ()
    (visual-line-mode 1) ; enable wrapping globally
    (add-hook 'post-command-hook #'my/org-table-wrap-fix nil t)))

(use-package org-modern
  :ensure t
  :after org
  :hook (org-mode . org-modern-mode)
  :hook (org-mode . org-indent-mode)
  :config
  (setq org-modern-star nil
        org-modern-hide-stars t
        org-modern-fold-stars nil
        org-modern-fold-icons '((t . "") (nil . ""))))

(use-package olivetti
    :after org
    :config
        ;; (setq olivetti-body-width fill-column)  ;; or try '80' or 'fill-column'
)

  (add-hook 'org-agenda-mode-hook #'olivetti-mode)
  (add-hook 'org-mode-hook #'olivetti-mode)

(use-package org-roam
  :ensure t
  :after org
  :init
  (setq org-roam-directory (file-truename "~/RoamNotes"))  ;; safer
  :config
  (org-roam-setup)

  ;; Ensure Org mode for Roam files (sometimes opens in fundamental-mode)
  (defun my/org-roam-force-org-mode ()
    "Ensure Org mode is enabled in roam buffers."
    (when (and (buffer-file-name)
               (string-suffix-p ".org" (buffer-file-name))
               (eq major-mode 'fundamental-mode))
      (org-mode)))

  (add-hook 'find-file-hook #'my/org-roam-force-org-mode))

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

(defun my/org-mode-headline-faces ()
  (let* ((font (cond ((x-list-fonts "Noto Sans Symbols") "Noto Sans Symbols")
                     ((x-list-fonts "Iosevka") "Iosevka")
                     (t "Sans Serif")))
         (headline `(:inherit default :family ,font :weight bold)))
    (custom-theme-set-faces
     'user
     `(org-level-1 ((t (,@headline :height 1.5))))
     `(org-level-2 ((t (,@headline :height 1.2))))
     `(org-level-3 ((t (,@headline :height 1.1))))
     `(org-level-4 ((t (,@headline :height 1.1))))
     `(org-level-5 ((t (,@headline :height 1.1))))
     `(org-level-6 ((t (,@headline :height 1.0))))
     `(org-level-7 ((t (,@headline :height 1.0))))
     `(org-level-8 ((t (,@headline :height 1.0))))
     `(org-document-title ((t (,@headline :height 2.0 :foreground "#A0B3C5" :underline nil)))))))

(defun my/org-headlines-city-lights ()
  (let* ((font (cond ((x-list-fonts "Lucida Grande") "Lucida Grande")
                     ((x-list-fonts "Source Sans Pro") "Source Sans Pro")
                     (t "Sans Serif")))
         (colors '("#E27E8D" "#EBBF83" "#539AFC" "#8BD49C"
                   "#ab7967" "#3dcbd6" "#82aaff" "#537f5d"))
         (sizes '(1.5 1.3 1.2 1.1 1.1 1.0 1.0 1.0)))
    (cl-loop for level from 1 to 8
             for color in colors
             for size in sizes
             for face = (intern (format "org-level-%d" level))
             do (set-face-attribute face nil
                  :inherit 'default
                  :family font
                  :weight 'bold
                  :height size
                  :foreground color))
    (set-face-attribute 'org-document-title nil
                        :inherit 'default
                        :family font
                        :weight 'bold
                        :height 2.0
                        :foreground "#ffffff"
                        :underline nil)))

(defun my/apply-org-headline-theme ()
  "Apply Org heading styles based on the current theme."
  (cond
   ((equal custom-enabled-themes '(doom-city-lights))
    (my/org-headlines-city-lights))
   ;; Add more themes here if needed
   (t (my/org-mode-headline-faces))))

;; Hook into theme load and org load
(add-hook 'after-load-theme-hook #'my/apply-org-headline-theme)

(with-eval-after-load 'org
  (my/apply-org-headline-theme))

(use-package projectile
  :ensure t
  :init
  (setq projectile-completion-system 'default)
  (setq projectile-indexing-method 'alien)
  (setq projectile-auto-discover nil)

  (setq projectile-known-projects
        '("~/org/"
          "~/RoamNotes/"
          "/Volumes/work/akips/"
          "/Volumes/work/docs/"
          "/Volumes/work/wiki/"))

  :config
  (projectile-mode +1)

  ;; Clean up bad paths after projectile starts
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq projectile-known-projects
                    (cl-remove-if-not #'file-directory-p projectile-known-projects))))
)

(defun my/kill-project-buffers ()
  "Kill all buffers belonging to the current Projectile project."
  (interactive)
  (let ((project-root (projectile-project-root)))
    (when project-root
      (dolist (buf (buffer-list))
        (with-current-buffer buf
          (when (and buffer-file-name
                     (string-prefix-p project-root buffer-file-name))
            (kill-buffer buf))))
      (message "Killed all buffers in project: %s" project-root))))

(defun my/revert-project-buffers ()
  "Revert all file-visiting buffers in the current Projectile project without confirmation."
  (interactive)
  (let ((project-root (projectile-project-root)))
    (when project-root
      (dolist (buf (buffer-list))
        (with-current-buffer buf
          (when (and buffer-file-name
                     (string-prefix-p project-root buffer-file-name)
                     (file-exists-p buffer-file-name))
            (revert-buffer :ignore-auto :noconfirm))))
      (message "Reverted all buffers in project: %s" project-root))))

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

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(global-unset-key (kbd "ESC ESC ESC"))
(global-unset-key (kbd "C-SPC"))
;; (global-unset-key (kbd "C-m"))
(global-unset-key  (kbd "C-."))
(global-unset-key (kbd "C-e"))
(global-unset-key (kbd "s-j"))
(global-unset-key (kbd "s-k"))
(global-unset-key (kbd "s-x"))
(global-unset-key (kbd "C-h"))
(global-unset-key (kbd "C-y"))

;; Attempt to separate C-i from TAB
(define-key input-decode-map [?\C-i] [C-i-real])
(global-set-key [C-i-real] #'previous-line)

;; Make ESC behave like C-g everywhere
;; (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; (global-set-key (kbd "<escape>") 'keyboard-quit)
;; (
 (global-set-key (kbd "<escape>") 'my/escape-quit)

(with-eval-after-load 'general
  (general-define-key
    :keymaps 'override
     ;; VIM Movement
     ;; "C-h" #'left-char
     ;; "C-j" #'next-line
     ;; "C-k" #'previous-line
     ;; "C-l" #'right-char
     ;; VIM Skip word/paragraph
     ;; "C-M-h" #'left-word
     ;; "C-M-j" #'forward-paragraph
     ;; "C-M-k" #'backward-paragraph
     ;; "C-M-l" #'right-word

    ;;WASD
     "C-j" #'left-char
     "C-k" #'next-line
     [C-i-real] #'previous-line
     "C-l" #'right-char
     ;; Skip word/paragraph
     "C-M-j" #'left-word
     "C-M-k" #'forward-paragraph
     "C-M-i" #'backward-paragraph
     "C-M-l" #'right-word
     ;; Before/end line
     "C-a" #'my/toggle-bol-and-indent
     "C-e" #'my/forward-to-last-non-comment-or-eol
     "C-s-a" #'beginning-of-buffer
     "C-s-e" #'end-of-buffer
))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'global
     "C-y C-y" #'my/copy-region-or-line
     "C-y C-w" #'my/yank-word
     "C-y C-f" #'my/copy-defun
))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'override
     "C-w" #'kill-word
     "C-W" #'sp-kill-word
     "C-d C-d" #'kill-line-or-region
     "C-d C-w" #'kill-word
     "C-d C-f" #'my/kill-defun
     "C-x" #'delete-forward-char
))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'override
   "s-/" #'comment-line
 ))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'override
   "C-p" #'my/org-smart-paste
 ))

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'global
   "C-v" #'my/mark-line
   ;; "C-m" #'set-mark-command
   "C-n" #'set-mark-command
))

(with-eval-after-load 'general
  (general-define-key
    :keymaps 'override
    "M-<up>" #'move-dup-move-lines-up
    "M-<down>" #'move-dup-move-lines-down
    "C-M-<up>" #'move-dup-duplicate-up
    "C-M-<down>" #'move-dup-duplicate-down
  ))

(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)

(with-eval-after-load 'general
  (general-define-key
   :keymaps 'global
     "C-u" #'undo
))

(global-set-key (kbd "C-.") 'my/lookup-definition)
(global-set-key (kbd "C-/") 'my/lookup-references)
(global-set-key (kbd "C-;") 'recenter-top-bottom)
(global-set-key (kbd "C-,") 'xref-go-back)

;; VIM
;; (global-set-key (kbd "s-j") 'diff-hl-next-hunk)
;; (global-set-key (kbd "s-k") 'diff-hl-previous-hunk)
;; (global-set-key (kbd "s-x") 'diff-hl-revert-hunk)

;; WASD
(global-set-key (kbd "s-k") 'diff-hl-next-hunk)
(global-set-key (kbd "s-i") 'diff-hl-previous-hunk)
(global-set-key (kbd "s-x") 'diff-hl-revert-hunk)

(with-eval-after-load 'general
  (general-define-key
     :keymaps 'magit-mode-map
     "C-j" #'magit-next-line
     "C-k" #'magit-previous-line
  ))

(with-eval-after-load 'org
  (with-eval-after-load 'general
    (general-define-key
     :keymaps 'org-mode-map
       "M-RET" #'my/org-meta-return-toggle-done
       "S-RET" #'my/org-meta-return-toggle-done
)))

(global-set-key (kbd "C-s-t") 'my/vterm-toggle)
;; (global-set-key (kbd "C-s-n") '+vterm/here)

(global-set-key (kbd "C-}" ) 'split-window-right)
(global-set-key (kbd "C-{" ) 'split-window-below)
(global-set-key (kbd "C-s-<left>" ) 'windmove-left)
(global-set-key (kbd "C-s-<right>" ) 'windmove-right)
(global-set-key (kbd "C-s-<up>" ) 'windmove-up)
(global-set-key (kbd "C-s-<down>" ) 'windmove-down)
(global-set-key (kbd "C-s-]" ) 'my/enlarge-window-horizontally)
(global-set-key (kbd "C-s-[" ) 'my/shrink-window-horizontally)

;; VIM
;; (global-set-key (kbd "C-s-h" ) 'windmove-left)
;; (global-set-key (kbd "C-s-l" ) 'windmove-right)
;; (global-set-key (kbd "C-s-k" ) 'windmove-up)
;; (global-set-key (kbd "C-s-j" ) 'windmove-down)

;; WASD
(global-set-key (kbd "C-s-j" ) 'windmove-left)
(global-set-key (kbd "C-s-l" ) 'windmove-right)
(global-set-key (kbd "C-s-i" ) 'windmove-up)
(global-set-key (kbd "C-s-k" ) 'windmove-down)


;; (global-set-key (kbd "C-s-<backspace>" ) 'windmove-dowdelete-window)
(global-set-key (kbd "C-<enter>" ) 'switch-to-buffer)

;; VIM
;; (global-set-key (kbd "s-j") 'diff-hl-next-hunk)
;; (global-set-key (kbd "s-k") 'diff-hl-previous-hunk)
;; (global-set-key (kbd "s-x") 'diff-hl-revert-hunk)

;; WASD
(global-set-key (kbd "s-k") 'diff-hl-next-hunk)
(global-set-key (kbd "s-i") 'diff-hl-previous-hunk)
(global-set-key (kbd "s-x") 'diff-hl-revert-hunk)

(with-eval-after-load 'general
  (general-define-key
     :keymaps 'magit-mode-map
       "C-j" #'magit-next-line
       "C-k" #'magit-previous-line
))

(use-package general
  :ensure t
  :config
  (general-define-key
    :keymaps 'override                 ;; Global override
    :prefix "C-SPC"
    "."  '(find-file :which-key "find file")

    ;; Avy
    "SPC" '(avy-goto-char-timer :which-key "avy goto char")
    "C-SPC" '(avy-goto-char-timer :which-key "avy goto char")

    ;; Agenda
    "a" '(org-agenda :which-key "Agenda")

    ;; Bookmarks
    "m"   '(:ignore t :which-key "Bookmarks")
    ;; "mm"  '(consult-bookmark :which-key "consult bookmark") ; This is already - SPC <ENTER>
    "ms"  '(bookmark-set :which-key "set bookmark")
    "mj"  '(bookmark-jump :which-key "jump to bookmark")
    "mm"  '(bookmark-jump :which-key "jump to bookmark")
    "md"  '(bookmark-delete :which-key "delete bookmark")

    ;; kill
    "k"   '(:ignore t :which-key "Kill")
    "kw"  '(kill-word :which-key "kill word")
    "kbw"  '(backward-kill-word :which-key "kill backwards word")
    "kl"  '(kill-whole-line :which-key "kill line")
    ;; Export
    "E"   '(:ignore t :which-key "export")
    "Eo"  '(my/org-export-html-to-rtf-clipboard :whichorg-key "org to email")

    ;; File
    "f"   '(:ignore t :which-key "Find")
    "ff"  '(projectile-find-file :which-key "find file in project")
    "ft"  '(treemacs :which-key "treemacs")
    "fd"  '(projectile-dired :which-key "projectile dired")

    ;; Lookup
    "l"   '(:ignore t :which-key "Lookup")
    "ld"  '(+lookup/definition :which-key "definition")
    "lr"  '(+lookup/references :which-key "references")
    "lb"  '(xref-go-back :which-key "back")

    ;; Help
    "h"   '(:ignore t :which-key "Help/describe")
    "hk"  '(describe-key :which-key "keybinding")
    "hv"  '(describe-variable :which-key " ")

    ;; Org
    "o"   '(:ignore t :which-key "Org")
    "oa"  '(org-agenda :which-key "Agenda")
    "oo"  '(org-roam-node-find :which-key "Open/find Note")
    "oc"  '(cfw:open-org-calendar :which-key "Calendar")
    "oe"  '(my/org-export-html-to-rtf-clipboard :which-key "Export to RTF")
    "oT"  '(:ignore t :which-key "Org table")
    "oTc" '(org-table-convert-region :which-key "convert region")
    "ot"  '(:ignore t :which-key "Tag")
    "ott" '(org-set-tags-command :which-key "Task")
    "otn" '(org-roam-tag-add :which-key "Note")

    ;; Project
    "p"   '(:ignore t :which-key "Projectile")
    "pp"  '(projectile-switch-open-project :which-key "switch project")
    "pa"  '(projectile-add-known-project :which-key "Add project")
    "pk"  '(my/kill-project-buffers :which-key "kill all buffers")
    "pr"  '(my/revert-project-buffers :which-key "Refresh all buffers")

    ;; Search
    "s"   '(:ignore t :which-key "Search")
    "ss"  '(consult-line :which-key "buffer")
    "sp"  '(consult-ripgrep :which-key "project ripgrep")
    "sl"  '(consult-goto-line :which-key "line number")
    "si"  '(consult-imenu :which-key "imenu")
    "sw"  '(isearch-forward-symbol-at-point :which-key "word")
    
    ;; Session
    "S"   '(:ignore t :which-key "Sesson")
    "SS"  '(persp-save-state-to-file :which-key "save")
    "SL"  '(persp-load-state-from-file :which-key "load")

    ;; Terminal
    "t"   '(:ignore t :which-key "vterm")
    "to"  '(vterm-other-window :which-key "vterm (other window)")
    "tt"  '(my/vterm-toggle :which-key "vterm")
    "th"  '(vterm :which-key "vterm (here)")

    ;; Diff Conflicts
    "c"   '(:ignore t :which-key "conflicts")
    "ck"   '(smerge-keep-upper :which-key "keep upper")
    "cu"   '(smerge-keep-upper :which-key "keep upper")
    "ck"   '(smerge-keep-lower :which-key "keep lower")
    "cl"   '(smerge-keep-lower :which-key "keep lower")
    "cc"    '(smerge-keep-current :which-key "keep current")

    ;; Refresh
    "r"   '(revert-buffer :which-key "refresh")

    ;; Buffers
    "bk"  '(kill-buffer :which-key "kill buffer")
    "br"  '(my/revert-buffer-no-confirm :which-key "revert buffer")
    "be"  '(eval-buffer :which-key "eval buffer")
    ;; "bo"  '(eval-buffer :which-key "buffer org2html")
    "bo"  '(my/org-export-html-to-rtf-clipboard :which-key "org to email")
    "bs"  '(switch-to-buffer :which-key "switch buffer")
    "bb"  '(switch-to-buffer :which-key "switch buffer")
    "bw"   '(:ignore t :which-key "Buffer Window")
    "bwk"  '(delete-window :which-key "kill")


    "e"   '(:ignore t :which-key "embark")
    "el"  '(embark-live  :which-key "live")
    "eb"  '(eval-buffer  :which-key "eval buffer")
    "er "  '(eval-region  :which-key "eval region")

    ;; Git
    "g"   '(:ignore t :which-key "magit")
    "gg"  '(magit :which-key "magit")
    "gd"  '(magit-diff-range :which-key "diff branch")
    "gb"  '(magit-blame :which-key "blame")

    ;; Workspaces
    "w"   '(:ignore t :which-key "workspace")
    "ww"  '(persp-switch :which-key "switch")
    "wk"  '(persp-kill :which-key "kill")
    "wl"  '(persp-load-state-from-file :which-key "load workspace session")
    
    ;; Window
    "W"   '(:ignore t :which-key "Window")
    "Wk"  '(delete-window :which-key "kill")


    ;; Yank
    "y"   '(:ignore t :which-key "yank")
    "yy"  '(my/yank-line :which-key "yank line")
    "yw"  '(my/yank-word :which-key "yank word")

   ))

;; (map! :leader
;;       :desc "Avy goto char timer"
;;       "SPC" #'avy-goto-char-timer
;;       :desc "Find file"
;;       "fd" #'find-file
;;       :desc "Projectile find file"
;; )
