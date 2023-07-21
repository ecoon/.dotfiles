;; MELPA packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(require 'use-package)

;;
;; appearances
;; ----------------------------------------
;; powerline
(use-package spaceline :ensure t)
(use-package spaceline-config :ensure spaceline
  :config
;;  (spaceline-emacs-theme)
;;  (spaceline-toggle-buffer-size-off)
;;  (spaceline-toggle-projectile-root-off)
  ;;(spaceline-toggle-minor-modes-off)
)
