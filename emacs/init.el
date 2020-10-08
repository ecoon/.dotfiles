;; turn off the stupid splash screen and warnings from dependent packages
(setq inhibit-startup-screen t)
(setq confirm-kill-emacs 'yes-or-no-p)
(setq byte-compile-warnings '(cl-functions))

;; MELPA packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(require 'use-package)

;; misc.el zap-up-to-char
(require 'misc)
(global-set-key (kbd "M-z") 'zap-up-to-char)

;; org-mode
(use-package ox-rst :ensure t)
(use-package markdown-mode :ensure t
  :config
  (custom-set-variables '(markdown-command "/usr/local/bin/markdown"))
  )
(defun markdown-filter (buffer)
  (princ
   (with-temp-buffer
     (let ((tmpname (buffer-name)))
       (set-buffer buffer)
       (set-buffer (markdown tmpname)) ; the function markdown is in `markdown-mode.el'
       (buffer-string)))
   (current-buffer)))
(use-package impatient-mode :ensure t)
;;
;; NOTE: to use, in markdown file:
;;  * M-x markdown-mode
;;  * M-x impatient-mode
;;  * M-x httpd-start
;;  * M-x imp-set-user-filter RET markdown-filter RET
;;  * open http://localhost:8080/imp


;; ITERM2 MOUSE SUPPORT
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (defun track-mouse (e)) 
  (setq mouse-sel-mode t)
  )

;; flyspell
(setq ispell-silently-savep t)
(global-set-key (kbd "M-#") 'flyspell-auto-correct-word)
 
;; semantic refactoring
(use-package srefactor :ensure t)
(global-set-key (kbd "C-x r") 'srefactor-refactor-at-point)

;; set functions to limit argument indentation after long function names
(defconst my-c-lineup-maximum-indent 30)

(defun my-c-lineup-arglist (langelem)
  (let ((ret (c-lineup-arglist langelem)))
    (if (< (elt ret 0) my-c-lineup-maximum-indent)
        ret
      (save-excursion
        (goto-char (cdr langelem))
        (vector (+ (current-column) 8))))))

(defun my-indent-setup ()
  (setcdr (assoc 'arglist-cont-nonempty c-offsets-alist)
          '(c-lineup-gcc-asm-reg my-c-lineup-arglist)))

;; C/ C++
(use-package whitespace :ensure t)
;;(setq-default whitespace-line-column 80 whitespace-style '(face lines-tail))

;; hook for keyboard defines
(defun my-c-initialization-hook ()
  (define-key c-mode-base-map (kbd "RET") 'newline-and-indent)
  (define-key c-mode-base-map (kbd "C-c C-c") 'comment-or-uncomment-region)
  (define-key c-mode-base-map (kbd "C-c >") 'indent-region)
  )
(add-hook 'c-initialization-hook 'my-c-initialization-hook)

;; style for others
(defconst my-c-style
  '((c-tab-always-indent        . t)
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 2)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)
                                   (innamespace       . 0))))
  "My C Programming Style")
(c-add-style "PERSONAL" my-c-style)

;; hook for mode
(defun my-c-mode-common-hook ()
  (c-set-style "PERSONAL")
  (setq c-basic-offset 2)
  (setq fill-column 79)
  (setq tab-width 2 indent-tabs-mode nil)
  (c-toggle-hungry-state)
  (setq whitespace-style '(face trailing))
  (whitespace-mode)
  (semantic-mode)
  (my-indent-setup)
  ;; (add-hook 'write-contents-functions
  ;;     (lambda() (save-excursion (whitespace-cleanup)) nil nil))
  )
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;; Python
(defun my-python-mode-hook ()
  (setq fill-column 79)
  (define-key c-mode-base-map (kbd "C-c C-c") 'comment-or-uncomment-region)
  )
(add-hook 'python-mode 'my-python-mode-hook)

;; powerline
(use-package spaceline :ensure t)
(require 'spaceline-config)
(spaceline-emacs-theme)

;; navigation
;; project management
(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "M-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "M-p t") 'treemacs-display-current-project-exclusively)
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1))

;; treemacs & projectile
(use-package treemacs
  :ensure t
  :config
  (setq treemacs-position 'right)
  (define-key treemacs-mode-map (kbd "M-t") 'treemacs-command-map)
  (global-set-key (kbd "M-p t") 'treemacs-add-and-display-current-project)
  )

;; ivy for swiper and cleaner searching wiht regex
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq swiper-goto-start-of-match t)
  (global-set-key (kbd "C-s") 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume)
)

(use-package avy
  :ensure t
  :config
  (avy-setup-default)
  (global-set-key (kbd "C-;") 'avy-goto-char)
  )

(use-package counsel
  :ensure t
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-x y") 'counsel-yank-pop)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (global-set-key (kbd "M-<return>") 'ivy-immediate-done)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

  (setq counsel-find-file-ignore-regexp
    (concat
     ;; File names beginning with # or .
     "\\(?:\\`[#.]\\)"
     ;; File names ending with # or ~
     "\\|\\(?:\\`.+?[#~]\\'\\)")
    )
  )
(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode)
  )

(defun tv/swiper-backward (&optional initial-input)
  (interactive)
  (let ((ivy-index-functions-alist
         '((swiper . tv/ivy-recompute-index-swiper-backward))))
    (swiper initial-input)))

;; magit
(use-package magit :ensure t)
(global-set-key (kbd "C-x g") 'magit-status)
(add-hook 'after-save-hook 'magit-after-save-refresh-status t)

;; tabs suck
(setq-default indent-tabs-mode nil)

;; randomly stolen stuff to work with iterm2
(defun get-file-dir-or-home ()
  "If inside a file buffer, return the directory, else return home"
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
	"~/"
      (file-name-directory filename))))

(defun iterm-goto-filedir-or-home ()
  "Go to present working dir and focus iterm"
  (interactive)
  (do-applescript
   (concat
    " tell application \"iTerm2\"\n"
    "   tell the current session of current window\n"
    (format "     write text \"pushd %s\" \n" (get-file-dir-or-home))
    "   end tell\n"
    " end tell\n"
    " do shell script \"open -a iTerm\"\n"
    ))
  )

(global-set-key (kbd "M-=") 'iterm-goto-filedir-or-home)

;; eshell customization
;;(setq eshell-cmpl-cycle-completions nil)

;; clang-format
(load "/usr/local/Cellar/clang-format/10.0.1/share/clang/clang-format.el")
(global-set-key [C-M-tab] 'clang-format-region)

;; adaptive-wrap
(setq visual-line-fringe-indicators (quote (left-curly-arrow right-curly-arrow)))
(when (fboundp 'adaptive-wrap-prefix-mode)
  (defun my-activate-adaptive-wrap-prefix-mode ()
    "Toggle `visual-line-mode' and `adaptive-wrap-prefix-mode' simultaneously."
    (adaptive-wrap-prefix-mode (if visual-line-mode 1 -1)))
  (add-hook 'visual-line-mode-hook 'my-activate-adaptive-wrap-prefix-mode))

;; comments are always appreciated
(global-set-key (kbd "C-c c") 'comment-or-uncomment-region)

;; emacs-client
(server-start)

;; themes
(use-package zenburn-theme :ensure t)
(use-package solarized-theme :ensure t)
(add-hook 'after-init-hook (lambda () (load-theme 'solarized-zenburn)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(beacon-color "#d33682")
 '(compilation-message-face 'default)
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-safe-themes
   '("7575474658c34b905bcec30a725653b2138c2f2d3deef0587e3abfae08c5b276" "57e3f215bef8784157991c4957965aa31bac935aca011b29d7d8e113a652b693" "51ec7bfa54adf5fff5d466248ea6431097f5a18224788d0bd7eb1257a4f7b773" "0fffa9669425ff140ff2ae8568c7719705ef33b7a927a0ba7c5e2ffcfac09b75" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "c433c87bd4b64b8ba9890e8ed64597ea0f8eb0396f4c9a9e01bd20a04d15d358" default))
 '(fci-rule-color "#073642")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(frame-background-mode 'dark)
 '(highlight-changes-colors '("#d33682" "#6c71c4"))
 '(highlight-symbol-colors
   '("#98695021d64f" "#484f5a50ffff" "#9ae80000c352" "#00000000ffff" "#98695021d64f" "#9ae80000c352" "#484f5a50ffff"))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   '(("#073642" . 0)
     ("#5b7300" . 20)
     ("#007d76" . 30)
     ("#0061a8" . 50)
     ("#866300" . 60)
     ("#992700" . 70)
     ("#a00559" . 85)
     ("#073642" . 100)))
 '(hl-bg-colors
   '("#866300" "#992700" "#a7020a" "#a00559" "#243e9b" "#0061a8" "#007d76" "#5b7300"))
 '(hl-fg-colors
   '("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36"))
 '(hl-paren-colors '("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900"))
 '(lsp-ui-doc-border "#93a1a1")
 '(nrepl-message-colors
   '("#dc322f" "#cb4b16" "#b58900" "#5b7300" "#b3c34d" "#0061a8" "#2aa198" "#d33682" "#6c71c4"))
 '(ns-left-alternate-modifier 'super)
 '(package-selected-packages
   '(markdown-mode impatient-mode hydra magit treemacs treemacs-all-the-icons treemacs-icons-dired treemacs-magit treemacs-persp treemacs-projectile srefactor color-theme-sanityinc-solarized color-theme-sanityinc-tomorrow solarized-theme tao-theme tangotango-theme tango-plus-theme tango-2-theme spaceline-all-the-icons projectile-codesearch ox-rst ivy-avy gh-md ggtags gandalf-theme function-args ein-mumamo dracula-theme darktooth-theme darkokai-theme darkmine-theme darkburn-theme dark-mint-theme dark-krystal-theme darcula-theme danneskjold-theme dakrone-theme dakrone-light-theme counsel-projectile counsel-osx-app counsel-gtags cmake-mode clues-theme cherry-blossom-theme challenger-deep-theme caroline-theme calmer-forest-theme bliss-theme badwolf-theme badger-theme auto-complete atom-one-dark-theme atom-dark-theme apropospriate-theme ample-zen-theme ample-theme all-the-icons-ivy-rich all-the-icons-ivy all-the-icons-ibuffer alect-themes afternoon-theme adaptive-wrap ace-window))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(safe-local-variable-values '((c-default-style . "google")))
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   '((20 . "#dc322f")
     (40 . "#cb4b16")
     (60 . "#b58900")
     (80 . "#859900")
     (100 . "#2aa198")
     (120 . "#268bd2")
     (140 . "#d33682")
     (160 . "#6c71c4")
     (180 . "#dc322f")
     (200 . "#cb4b16")
     (220 . "#b58900")
     (240 . "#859900")
     (260 . "#2aa198")
     (280 . "#268bd2")
     (300 . "#d33682")
     (320 . "#6c71c4")
     (340 . "#dc322f")
     (360 . "#cb4b16")))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   '(unspecified "#002b36" "#073642" "#a7020a" "#dc322f" "#5b7300" "#859900" "#866300" "#b58900" "#0061a8" "#268bd2" "#a00559" "#d33682" "#007d76" "#2aa198" "#839496" "#657b83"))
 '(xterm-color-names
   ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#eee8d5"])
 '(xterm-color-names-bright
   ["#002b36" "#cb4b16" "#586e75" "#657b83" "#839496" "#6c71c4" "#93a1a1" "#fdf6e3"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )




