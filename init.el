;;; package --- Summary
;;; Commentary:
;;; Code:

;;; THEME CUSTOMIZATION
(setq org-fontify-whole-heading-line t)

;; TRUE FULLSCREEN
(defun fullscreen ()
       (interactive)
       (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
			      '(2 "_NET_WM_STATE_FULLSCREEN" 0)))

;; DENOTE
(add-hook 'dired-mode-hook 'denote-dired-mode)
(setq denote-directory (expand-file-name "~/Workspace/orgs/"))

;;; GENERAL CUSTOMIZATION

;; dired
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

;; disable bell sound
(setq ring-bell-function 'ignore)

;; the directory for backup files
(setq backup-directory-alist            '((".*" . "~/.Emacs-Backup-Files")))

;; prevent customization variables from showing in init.el - instead:
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; global-auto-revert-mode
(global-auto-revert-mode 1)

;; revert dired and other buffers:
(defvar global-auto-revert-non-file-buffers t)

;; save place mode
(save-place-mode 1)

;; electric-pairs
(electric-pair-mode t)

;; reducing line spacing
(setq-default line-spacing 1)

;; disable menu on startup
(menu-bar-mode -1)

;; disable tools bar on startup
(tool-bar-mode -1)

;; disable scroll bar on startup
(toggle-scroll-bar -1)

;; inhibit splash screen
(setq inhibit-splash-screen t)

;; line numbers
(defvar display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;; always open fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))`

;; opening the dotfile bind (doesn't work for some reason!)
(global-set-key (kbd "C-c C-d") #'open-init-file)

(defun open-init-file ()
  "Open the init file."
  (interactive)
  (find-file (concat user-emacs-directory "init.el")))

;; startup scratch message
(setq initial-scratch-message
";; ┌──────────────────────┐
;; │     Welcome back!    │
;; │                      │
;; │ >(.)__ <(.)__ =(.)__ │
;; │  (___/  (___/  (___/ │
;; │                      │
;; │    -Happy hacking!   │
;; └──────────────────────┘
")

;; smooth scroll
(setq scroll-margin 8
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)


;;; REPOSITORIES AND P-MANAGERS

;; use-package setup
(unless (package-installed-p 'use-package)
     (package-refresh-contents)
     (package-install 'use-package))
(eval-when-compile
     (require 'use-package))
   (setq use-package-always-ensure t)

;; set up Melpa repository
(require 'package)
   (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
   (package-initialize)

;; ;;; EF THEME CUSTOMIZATION
;; (require 'ef-themes)
;; (setq ef-themes-to-toggle '(ef-kassio ef-symbiosis))

(defun my/reset-face-attributes ()	; because i hate bold text
  (mapc (lambda (face)
          (set-face-attribute face nil :weight 'normal :underline nil))
        (face-list)))

(add-hook 'after-init-hook 'my/reset-face-attributes)

;;(load-theme 'ef-kassio :no-confirm)

;;; ORG-MODE CUSTOMIZATION
     (custom-set-faces
      '(org-level-1 ((t (:height 200))))
      '(org-level-2 ((t (:height 170))))
      '(org-level-3 ((t (:height 140))))
      '(org-level-4 ((t (:height 120))))
      )


;;; CONVINIENCE

;; vertico
(use-package
  vertico
  :init (vertico-mode)
  (setq vertico-count 10)
  (setq vertico-resize t))

;; orderless completion style
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; eldoc-box
(use-package eldoc-box
  :commands
  eldoc-box-help-at-point
  :custom
  (eldoc-echo-area-use-multiline-p t)
  ;; :hook
  ;; (eglot-managed-mode . eldoc-box-hover-mode)
  :bind
  ("C-c k" . eldoc-box-help-at-point))

;; projectile
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind
  (:map projectile-mode-map
        ("C-c p" . projectile-command-map))
  :custom
  (setq projectile-project-search-path '("~/my-projects/" "~/work/"))
  (projectile-register-project-type 'npm '("package.json")
                                  :project-file "package.json"
				  :compile "npm install"
				  :test "npm test"
				  :run "npm start"
				  :test-suffix ".spec")
  (setq projectile-indexing-method 'alien)
  (setq projectile-sort-order 'recently-active)
  (setq projectile-enable-caching t)
  (setq projectile-file-exists-remote-cache-expire (* 10 60))
  (setq projectile-require-project-root t)
  (setq projectile-switch-project-action #'projectile-dired)
  (setq projectile-completion-system 'default))

;; enable corfu
(use-package
  corfu
  :custom
  (corfu-cycle t)	   ; Allows cycling through candidates
  (corfu-auto t)		   ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.0)
  (corfu-preview-current 'insert)   ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)        ; Don't auto expand tempel snippets
  (lsp-completion-provider :none)
  :bind (:map corfu-map
	      ("TAB"        .  corfu-insert)
	      ([tab]        .  corfu-insert)
	      ("RET"        . nil))
  
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)		; Popup completion info
  
  :custom
  (add-hook 'eshell-mode-hook (lambda ()
					(setq-local corfu-quit-at-boundary t corfu-quit-no-match t
						    corfu-auto t)
					(corfu-mode))))

;; eglot config
(use-package eglot
  :ensure t
  :bind
  (:map eglot-mode-map
	("C-c e r" . eglot-rename)
                  ("C-c e d" . eglot-find-typeDefinition)
                  ("C-c e D" . eglot-find-declaration)
                  ("C-c e f" . eglot-format)
                  ("C-c e F" . eglot-format-buffer)
                  ("C-c e R" . eglot-reconnect)))
(add-hook 'js2-mode-hook 'eglot-ensure)
(add-hook 'css-mode-hook 'eglot-ensure)
(add-hook 'c-mode 'eglot-ensure)

(with-eval-after-load 'eglot
  (setq eglot-events-buffer-size 0
        eglot-ignored-server-capabilities '(:hoverProvider
                                            :documentHighlightProvider)
        eglot-autoshutdown t))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
	       '(c-mode . ("clangd" "--stdio"))))


;; the snippet disables eglot jsonrpc logging, for better performance
(defun load-jsonrpc-log-disable()
  "Disabling jsonrpc logging."
  (when (fboundp #'jsonrpc--log-event) ; checking if the jsonrpc--log-event is defined first
  (fset #'jsonrpc--log-event #'ignore)))
(with-eval-after-load 'eglot
  (run-with-idle-timer 2 nil #'load-jsonrpc-log-disable))


;; flycheck
(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)


;; flycheck eglot mode
(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :custom
  (global-flycheck-eglot-mode 1))


;;; JAVASCRIPT

;; js-2 mode config
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;; rainbow delimeters
(add-hook 'js2-mode-hook #'rainbow-delimiters-mode)


;;; MAGIT
(use-package magit
  :ensure t)

;;; OTHER PACKAGES

;; PDF-TOOLS
(pdf-loader-install)
(add-hook 'pdf-view-mode-hook (lambda() (display-line-numbers-mode 0)))
(require 'saveplace-pdf-view)
(save-place-mode 1)

;; TELEGA
(add-hook 'telega-root-mode-hook (lambda() (display-line-numbers-mode 0)))

;; ;; spotify
;; ;; Settings
;; (setq smudge-oauth2-client-secret "<spotify-app-client-secret>")
;; (setq smudge-oauth2-client-id "<spotify-app-client-id>")
;; (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)

;;; PROVIDE
(provide 'init)

;;; init.el ends here
(put 'narrow-to-region 'disabled nil)
