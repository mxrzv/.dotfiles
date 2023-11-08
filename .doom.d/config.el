;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Font

(setq doom-font (font-spec :family "Iosevka Comfy" :size 20))

;;; TODO detect modus themes and enable this git-gutter fix
;; (use-package! git-gutter-fringe
;;   :config
;;   (setq-default fringes-outside-margins t)
;;   (define-fringe-bitmap 'git-gutter-fr:added [0]
;;     nil nil '(center repeated))
;;   (define-fringe-bitmap 'git-gutter-fr:modified [0]
;;     nil nil '(center repeated))
;;   (define-fringe-bitmap 'git-gutter-fr:deleted [0]
;;     nil nil 'bottom)
;;   (defun my-modus-themes-custom-faces ()
;;     (modus-themes-with-colors
;;      (custom-set-faces
;;       ;; Replace green with blue if you use `modus-themes-deuteranopia'.
;;       `(git-gutter-fr:added ((,class :foreground ,green-fringe-bg)))
;;       `(git-gutter-fr:deleted ((,class :foreground ,red-fringe-bg)))
;;       `(git-gutter-fr:modified ((,class :foreground ,yellow-fringe-bg))))))
;;   (add-hook 'modus-themes-after-load-theme-hook #'my-modus-themes-custom-faces))

;;; Line numbers
(setq display-line-numbers-type t)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq org-directory "~/org/")

(fset 'rainbow-delimiters-mode #'ignore)

;;; Emms

(use-package emms
  :init
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-source-file-default-directory "~/Music")
  :config
  (emms-mode-line-disable))

(defun track-title-from-file-name (file)
  "For using with EMMS description functions. Extracts the track
title from the file name FILE, which just means a) taking only
the file component at the end of the path, and b) removing any
file extension."
  (with-temp-buffer
    (save-excursion (insert (file-name-nondirectory (directory-file-name file))))
    (ignore-error 'search-failed
      (search-forward-regexp (rx "." (+ alnum) eol))
      (delete-region (match-beginning 0) (match-end 0)))
    (buffer-string)))

(defun my-emms-track-description (track)
  "Return a description of TRACK, for EMMS, but try to cut just
the track name from the file name, and just use the file name too
rather than the whole path."
  (let ((artist (emms-track-get track 'info-artist))
        (title (emms-track-get track 'info-title)))
    (cond ((and artist title)
           (concat (format "%s" artist) " - " (format "%s" title)))
          (title title)
          ((eq (emms-track-type track) 'file)
           (track-title-from-file-name (emms-track-name track)))
          (t (emms-track-simple-description track)))))

(setq emms-track-description-function 'my-emms-track-description)

(use-package! emms-state
  :config
  (eval-after-load 'emms '(emms-state-mode)))

(map! :desc "emms-play-directory"
      "<f2>" 'emms-play-directory)
(map! :desc "emms-toggle-repeat-track"
      "C-c r" 'emms-toggle-repeat-track)
(map! :desc "emms-pause"
      "C-c <f1>" 'emms-pause)
(map! :desc "emms-previous"
      "C-c ," 'emms-previous)
(map! :desc "emms-next"
      "C-c ." 'emms-next)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Theme

(setq doom-theme 'doom-homage-black)

;;; Theme toggle

(defun bb/toggle-theme ()
  "Toggle between light and dark themes."
  (interactive)
  (if (eq (car custom-enabled-themes) 'doom-homage-black)
      (progn
	(disable-theme 'doom-homage-black)
	(load-theme 'modus-operandi t)
	)
    (progn
      (disable-theme 'doom-homage-black)
      (load-theme 'doom-homage-black t)
      )))

(map! :desc "toggle-modus-themes"
      "<f12>" #'bb/toggle-theme)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Olivetti

(use-package! olivetti
  :config
  (setq-default olivetti-body-width 130)
  (add-hook 'mixed-pitch-mode-hook  (lambda () (setq-local olivetti-body-width 80))))

(load-file "~/.doom.d/modules/ui/auto-olivetti/auto-olivetti.el")

(use-package! auto-olivetti
  :custom
  (auto-olivetti-enabled-modes '(text-mode prog-mode helpful-mode ibuffer-mode image-mode))
  :config
  (auto-olivetti-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Go
(setq exec-path (append exec-path '("~/go/bin")))
(setq lsp-gopls-server-path (expand-file-name "~/go/bin/gopls"))
(setq lsp-gopls-staticcheck t)
(setq gofmt-command "goimports")

(add-hook 'before-save-hook 'gofmt-before-save)

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Icons

(use-package! nerd-icons
  :custom
  ;; (nerd-icons-font-family  "Iosevka Nerd Font Mono")
  ;; (nerd-icons-scale-factor 2)
  ;; (nerd-icons-default-adjust -.075)
  (doom-modeline-major-mode-icon t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Dashboard

(add-to-list '+doom-dashboard-menu-sections
             '("Open diary"
               :icon (nerd-icons-mdicon "nf-md-notebook_heart" :face 'doom-dashboard-menu-title)
               :action diary))

(setq user-full-name "Maxim Rozhkov"
      user-mail-address "foldersjarer@gmail.com"
      +doom-dashboard-banner-file "/home/pingvi/.doom.d/misc/doom.png"
      +doom-dashboard-banner-padding '(0 . 2))

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Info colors

(use-package! info-colors
  :after info
  :commands (info-colors-fontify-node)
  :hook (Info-selection . info-colors-fontify-node))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Improve completions
(after! lsp-mode
  (setq +lsp-company-backends
        '(:separate company-capf company-yasnippet company-dabbrev)))

;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . fullscreen))

;; Scrolling

(pixel-scroll-precision-mode)

(defun filter-mwheel-always-coalesce (orig &rest args)
  "A filter function suitable for :around advices that ensures only
   coalesced scroll events reach the advised function."
  (if mwheel-coalesce-scroll-events
      (apply orig args)
    (setq mwheel-coalesce-scroll-events t)))

(defun filter-mwheel-never-coalesce (orig &rest args)
  "A filter function suitable for :around advices that ensures only
   non-coalesced scroll events reach the advised function."
  (if mwheel-coalesce-scroll-events
      (setq mwheel-coalesce-scroll-events nil)
    (apply orig args)))

;; Don't coalesce for high precision scrolling
(advice-add 'pixel-scroll-precision :around #'filter-mwheel-never-coalesce)

;; Coalesce for default scrolling (which is still used for horizontal scrolling)
;; and text scaling (bound to ctrl + mouse wheel by default).
(advice-add 'mwheel-scroll          :around #'filter-mwheel-always-coalesce)
(advice-add 'mouse-wheel-text-scale :around #'filter-mwheel-always-coalesce)

;; Horizontal scrolling
(setq mouse-wheel-tilt-scroll t)
;; Reversed/Natural scrolling
(setq mouse-wheel-flip-direction t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Use smaller step for text scaling
(setq text-scale-mode-step 1.05)

(map! :desc "save-buffer"
      "C-s" 'save-buffer)
(map! :desc "swiper"
      "C-f" 'swiper-isearch)
(map! :desc "avy-goto-char-2"
      "C-'" 'avy-goto-char-2)
(map! :desc "scroll-up"
      "C-d" 'scroll-up-command)
(map! :desc "scroll-down"
      "C-u" 'scroll-down-command)
(map! :desc "treemacs-select-window"
      "M-0" 'treemacs-select-window)
(map! :desc "counsel-recentf"
      "C-x f" 'counsel-recentf)

(use-package! python-black
  :demand t
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

(require 'auto-virtualenv)
(add-hook 'python-mode-hook 'auto-virtualenv-set-virtualenv)

;; Move line up/down
(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(map! :desc "move-line-up"
      "<M-up>" #'move-line-up)
(map! :desc "move-line-down"
      "<M-down>" #'move-line-down)

(use-package! recentf
  :custom
  (setq recentf-max-saved-items 40)
  (setq recentf-max-menu-items 10)
  (setq recentf-show-file-shortcuts-flag nil)
  (run-at-time nil (* 5 60) 'recentf-save-list))

(use-package! evil-nerd-commenter
  :init
  (evilnc-default-hotkeys nil t))
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)

(use-package! undo-fu
  :custom
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(map! :desc "undo-fu-only-undo"
      :map 'override "C-z" 'undo-fu-only-undo)

(use-package! pulsar
  :config
  (setq pulsar-pulse t)
  (setq pulsar-delay 0.055)
  (setq pulsar-iterations 10)
  (setq pulsar-face 'pulsar-blue)
  (setq pulsar-highlight-face 'pulsar-yellow)

  (pulsar-global-mode 1)

  (add-hook 'next-error-hook 'pulsar-pulse-line-red)
  (add-hook 'flycheck-next-error 'pulsar-pulse-line-yellow)
  (add-hook 'flycheck-previous-error 'pulsar-pulse-line-)
  (add-hook 'minibuffer-setup-hook 'pulsar-pulse-line-red)
  (add-hook 'minibuffer-setup-hook 'pulsar-pulse-line)
  (add-hook 'imenu-after-jump-hook 'pulsar-recenter-top)
  (add-hook 'imenu-after-jump-hook 'pulsar-reveal-entry))

(map! :desc "current-line-pulse"
      "C-c l" 'pulsar-pulse-line)

(set-popup-rule! "*doom:vterm-popup:*" :size 0.25 :vslot -4 :select t :quit nil :ttl 0)

(use-package! multi-compile
  :config
  (setq multi-compile-alist '(
			      (go-mode . (
					  ("go-build" "go build -v"
					   (locate-dominating-file buffer-file-name ".git"))
					  ("go-build-and-run" "go build -v && echo 'build finish' && eval ./${PWD##*/}"
					   (multi-compile-locate-file-dir ".git"))
					  ("go-build-test-and-run" "go build -v && go test -v && go vet && eval ./${PWD##*/}"
					   (multi-compile-locate-file-dir ".git")))))))
