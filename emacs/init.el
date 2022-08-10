;;
;; basic setup
;; ----------------------
(setq inhibit-startup-screen t)
(setq visible-bell nil)
(setq ring-bell-function 'ignore)
(setq confirm-kill-emacs 'yes-or-no-p)
(setq byte-compile-warnings '(cl-functions))
(setq-default indent-tabs-mode nil)
(defun markdown-filter (buffer)
  (princ
   (with-temp-buffer
     (let ((tmpname (buffer-name)))
       (set-buffer buffer)
       (set-buffer (markdown tmpname)) ; the function markdown is in `markdown-mode.el'
       (buffer-string)))
   (current-buffer)))

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

(use-package impatient-mode :ensure t)

;;
;; dockerfile-mode
;;
(use-package dockerfile-mode :ensure t
  :mode (("\\.Dockerfile$" . dockerfile-mode)))


;;
;; xml / html
;;
(defun html-get-tag ()
  (let ((b (line-beginning-position))
        (e (line-end-position))
        (looping t)
        (html-tag-char (string-to-char "<"))
        (char (following-char))
        (p (point))
        (found_tag -1))

    (save-excursion
      ;; search backward
      (unless (= char html-tag-char)
        (while (and looping (<= b (point)) (not (= char 60)))
          (setq char (following-char))
          (setq p (point))
          (if (= p (point-min))
              ;; need get out of loop anyway
              (setq looping nil)
            (backward-char))))

      ;; search forward
      (if (not (= char html-tag-char))
          (save-excursion
            (while (and (>= e (point)) (not (= char 60)))
              (setq char (following-char))
              (setq p (point))
              (forward-char))))

      ;; is end tag?
      (when (and (= char html-tag-char) (< p e))
        (goto-char p)
        (forward-char)
        (if (= (following-char) 47)
            (progn
              ;; </
              (skip-chars-forward "^>")
              (forward-char)
              (setq p (point))
              (setq found_tag 1))
          (progn
            ;; < , looks fine
            (backward-char)
            (setq found_tag 0)))))
    found_tag))

(use-package sgml-mode
  :ensure t
  :config
  ;; fancy html jump
  (autoload 'sgml-skip-tag-backward "sgml-mode" nil t)
  (autoload 'sgml-skip-tag-forward "sgml-mode" nil t))

(defun html-jump(&optional num)
  "Jump forward from html open tag"
  (interactive "P")
  (unless num (setq num 1))
  ;; web-mode-forward-sexp is assigned to forward-sexp-function
  ;; it's buggy in web-mode v11, here is the workaround
  (let ((backup-forward-sexp-function forward-sexp-function))
    (if (= (html-get-tag) 0)
        (sgml-skip-tag-forward num)
      (sgml-skip-tag-backward num))))

(use-package nxml
  :ensure t
  :mode (("\\.xml$" . nxml-mode)
         ("\\.zcml$" . nxml-mode)
         ("\\.xmf$" . nxml-mode))
  :config

  )
(defun my-nxml-mode-hook ()
  (local-set-key (kbd "M-'") 'html-jump)
  )
(add-hook 'nxml-mode-hook 'my-nxml-mode-hook)

;;
;; C / C++
;;
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

(use-package whitespace :ensure t)
;;(setq-default whitespace-line-column 80 whitespace-style '(face lines-tail))

;; hook for keyboard defines
(defun my-c-initialization-hook ()
  (define-key c-mode-base-map (kbd "RET") 'newline-and-indent)
  (define-key c-mode-base-map (kbd "C-c C-c") 'comment-or-uncomment-region)
  (define-key c-mode-base-map (kbd "C-c >") 'indent-region)
  (define-key c-mode-base-map (kbd "C-x C-S-f") 'ff-find-other-file) ;; note, this is C-x C-F
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
  ;;(semantic-mode)
  (my-indent-setup)
  ;; (add-hook 'write-contents-functions
  ;;     (lambda() (save-excursion (whitespace-cleanup)) nil nil))
  )
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;
;; Python
;;
(defun my-python-mode-hook ()
  (setq fill-column 79)
  (local-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
  )
(add-hook 'python-mode 'my-python-mode-hook)

;; emacs ipython notebook
(use-package ein
  :ensure t
  :init
  (progn
    (defun setup-key-hack ()
      ;; changing keybinding
      (define-key ein:notebook-mode-map (kbd "C-x C-s") #'ein:notebook-save-notebook-command)
      (define-key ein:notebook-mode-map (kbd "C-<return>") #'ein:worksheet-execute-cell-and-goto-next-km)
      (define-key ein:notebook-mode-map (kbd "M-<return>") #'ein:worksheet-execute-cell-and-goto-next-km)
      (define-key ein:notebook-mode-map (kbd "S-<return>") #'ein:worksheet-execute-cell-and-goto-next-km)
      (define-key ein:notebook-mode-map (kbd "C-<up>") #'backward-paragraph)
      (define-key ein:notebook-mode-map (kbd "C-<down>") #'forward-paragraph)
      (define-key ein:notebook-mode-map (kbd "M-<up>") #'ein:worksheet-goto-prev-input-km)
      (define-key ein:notebook-mode-map (kbd "M-<down>") #'ein:worksheet-goto-next-input-km)
      )
    (add-hook 'ein:notebooklist-mode-hook #'setup-key-hack)
    )
  )


;; ;; semantic refactoring
;; (use-package srefactor :ensure t)
;; (global-set-key (kbd "C-x r") 'srefactor-refactor-at-point)


;;
;; General usability
;; -------------------------------
;; flyspell
(setq ispell-silently-savep t)
(global-set-key (kbd "M-#") 'flyspell-auto-correct-word)

;; magit
(use-package magit :ensure t)
(global-set-key (kbd "C-x g") 'magit-status)
(add-hook 'after-save-hook 'magit-after-save-refresh-status t)

;; ;; clang-format
;; (load "/usr/local/Cellar/clang-format/12.0.0/share/clang/clang-format.el")
;; (global-set-key [C-M-tab] 'clang-format-region)

;; ;; adaptive-wrap
;; (setq visual-line-fringe-indicators (quote (left-curly-arrow right-curly-arrow)))
;; (when (fboundp 'adaptive-wrap-prefix-mode)
;;   (defun my-activate-adaptive-wrap-prefix-mode ()
;;     "Toggle `visual-line-mode' and `adaptive-wrap-prefix-mode' simultaneously."
;;     (adaptive-wrap-prefix-mode (if visual-line-mode 1 -1)))
;;   (add-hook 'visual-line-mode-hook 'my-activate-adaptive-wrap-prefix-mode))

;; eshell customization
;;(setq eshell-cmpl-cycle-completions nil)


;;
;; navigation
;; ----------------------

;; hide-show code folding
(defun hs-hide-leafs-recursive (minp maxp)
  "Hide blocks below point that do not contain further blocks in
    region (MINP MAXP)."
  (when (hs-find-block-beginning)
    (setq minp (1+ (point)))
    (funcall hs-forward-sexp-func 1)
    (setq maxp (1- (point))))
  (unless hs-allow-nesting
    (hs-discard-overlays minp maxp))
  (goto-char minp)
  (let ((leaf t))
    (while (progn
             (forward-comment (buffer-size))
             (and (< (point) maxp)
                  (re-search-forward hs-block-start-regexp maxp t)))
      (setq pos (match-beginning hs-block-start-mdata-select))
      (if (hs-hide-leafs-recursive minp maxp)
          (save-excursion
            (goto-char pos)
            (hs-hide-block-at-point t)))
      (setq leaf nil))
    (goto-char maxp)
    leaf))

(defun hs-hide-leafs ()
  "Hide all blocks in the buffer that do not contain subordinate
    blocks.  The hook `hs-hide-hook' is run; see `run-hooks'."
  (interactive)
  (hs-life-goes-on
   (save-excursion
     (message "Hiding blocks ...")
     (save-excursion
       (goto-char (point-min))
       (hs-hide-leafs-recursive (point-min) (point-max)))
     (message "Hiding blocks ... done"))
   (run-hooks 'hs-hide-hook)))

(use-package hideshow
  :ensure t
  :config
  (setq hs-hide-comments t)
  (global-set-key (kbd "C-=") 'hs-hide-leafs)
  (global-set-key (kbd "C-+") 'hs-show-all)
  (global-set-key (kbd "C-'") 'hs-toggle-hiding)
  (add-to-list 'hs-special-modes-alist
               '(nxml-mode
		 "<!--\\|<[^/>]*[^/]>"
		 "-->\\|</[^/>]*[^/]>"
		 
		 "<!--"
		 sgml-skip-tag-forward
		 nil))
  )
;;(add-hook 'c-mode-common-hook   'hs-minor-mode)
(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
(add-hook 'sh-mode-hook         'hs-minor-mode)
(add-hook 'python-mode-hook     'hs-minor-mode)
(add-hook 'nxml-mode-hook 'hs-minor-mode)

;; mmm-mode: rst in C++
;;(add-to-list 'load-path "~/.emacs.d/mmm-mode/share/emacs/site-lisp")
(use-package mmm-mode
  :ensure t
  :config
  (setq mmm-global-mode 'maybe)
  (setq mmm-parse-when-idle nil)
  (mmm-add-classes
   '((cpp-rst
      :submode rst-mode
      :front "/\\*!"
      :back "\\*/"
      :end-not-begin t)))
  (mmm-add-mode-ext-class 'c++-mode "\\.hh\\'" 'cpp-rst)
  (add-to-list 'mmm-save-local-variables 'fill-paragraph-function)
  (add-to-list 'mmm-save-local-variables 'fill-paragraph-handle-comment)
  (add-to-list 'mmm-save-local-variables 'adaptive-fill-function)
  (add-to-list 'mmm-save-local-variables 'adaptive-fill-regexp)
  (add-to-list 'mmm-save-local-variables 'adaptive-fill-first-line-regexp)
  ;;  (add-to-list 'mmm-save-local-variables 'indent-line-function buffer (rst-mode)))
)

;; Project management
(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "M-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "M-p t") 'treemacs-display-current-project-exclusively)
  (define-key projectile-mode-map (kbd "M-p T") 'treemacs)
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  )

;; treemacs & projectile
(use-package treemacs
  :ensure t
  :config
  (setq treemacs-position 'right)
  (define-key treemacs-mode-map (kbd "M-t") 'treemacs-command-map)
  (global-set-key (kbd "M-p t") 'treemacs-add-and-display-current-project)
  )

;; and perspective
(use-package perspective
  :ensure t
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  ("C-x b" . persp-ivy-switch-buffer)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c C-p"))  ; pick your own prefix key here
  :init
  (persp-mode))

(use-package persp-projectile
  :ensure t)


;; ivy for swiper and cleaner searching with regex
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
  (global-set-key (kbd "M-f") 'isearch-forward)
  (define-key isearch-mode-map "\M-f" 'isearch-repeat-forward)
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
  ;; (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  ;; (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  ;; (global-set-key (kbd "<f1> l") 'counsel-find-library)
  ;; (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  ;; (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-c g") 'counsel-git)
  (global-set-key (kbd "C-c j") 'counsel-git-grep)
  (global-set-key (kbd "C-c k") 'counsel-ag)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-x y") 'counsel-yank-pop)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  ;;(global-set-key (kbd "M-<return>") 'ivy-immediate-done) ;; cannot figure out conflict with this and ein, and I don't think I use this anyway?
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

;; (defun tv/swiper-backward (&optional initial-input)
;;   (interactive)
;;   (let ((ivy-index-functions-alist
;;          '((swiper . tv/ivy-recompute-index-swiper-backward))))
;;     (swiper initial-input)))

;;
;; iterm2 and OSX integration
;; ----------------------------------------
;; iterm2 mouse support
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (defun track-mouse (e)) 
  (setq mouse-sel-mode t)
  )

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
(global-set-key [f6] 'replace-string)

;; ATS work
(defun fixit-hh ()
  (interactive)
  (replace-string "FieldEvaluator" "Evaluator")
  (beginning-of-buffer)
  (replace-string "Key request" "const Key& request")
  (beginning-of-buffer)
  (replace-string "HasFieldChanged" "Update")
  (beginning-of-buffer)
  (replace-string "EvaluateField" "Evaluate")
  (beginning-of-buffer)
  (replace-string "secondary_variable_field_evaluator" "EvaluatorSecondaryMonotype")
  (beginning-of-buffer)
  (replace-string "secondary_variables_field_evaluator" "EvaluatorSecondaryMonotype")
  (beginning-of-buffer)
  (replace-string "SecondaryVariablesFieldEvaluator" "EvaluatorSecondaryMonotype")
  (beginning-of-buffer)
  (replace-string "SecondaryVariableFieldEvaluator" "EvaluatorSecondaryMonotype")    
  (beginning-of-buffer)
  (replace-string "Clone() const;" "Clone() const override;")
  (beginning-of-buffer)
  (replace-string "results)" "results) override")
  (beginning-of-buffer)
  (replace-string "result)" "result) override")
  (beginning-of-buffer)
  (replace-string "const Teuchos::Ptr<State>& S" "const State& S")
  (beginning-of-buffer)
  (replace-string "Key wrt_key" "const Key& wrt_key, const Tag& wrt_tag")
  (beginning-of-buffer)
  (replace-string "const std::vector<Teuchos::Ptr<CompositeVector> >&" "const std::vector<CompositeVector*>&")
  (beginning-of-buffer)
  (replace-string "const Teuchos::Ptr<CompositeVector>&" "const std::vector<CompositeVector*>&")
  (beginning-of-buffer)
  (replace-string "EnsureCompatibility(const State& S)" "EnsureCompatibility(State& S) override")
  (beginning-of-buffer)
  (whitespace-cleanup)
  (beginning-of-buffer)
)


(defun fixit-cc ()
  (interactive)
  (replace-string "FieldEvaluator" "Evaluator")
  (beginning-of-buffer)
  (replace-string "EvaluateField" "Evaluate")
  (beginning-of-buffer)
  (replace-string "Key request" "const Key& request")
  (beginning-of-buffer)
  (replace-string "HasFieldChanged" "Update")
  (beginning-of-buffer)
  (replace-string "UpdateField_" "Update_")
  (beginning-of-buffer)
  (replace-string "SecondaryVariablesFieldEvaluator" "EvaluatorSecondaryMonotype")
  (beginning-of-buffer)
  (replace-string "SecondaryVariableFieldEvaluator" "EvaluatorSecondaryMonotype")    
  (beginning-of-buffer)
  (replace-string "const Teuchos::Ptr<State>& S" "const State& S")
  (beginning-of-buffer)
  (replace-string "S->" "S.")
  (beginning-of-buffer)
  (replace-string "vo_->" "vo_.")
  (beginning-of-buffer)
  (replace-string "Key wrt_key" "const Key& wrt_key, const Tag& wrt_tag")
  (beginning-of-buffer)
  (replace-string "const std::vector<Teuchos::Ptr<CompositeVector> >&" "const std::vector<CompositeVector*>&")
  (beginning-of-buffer)
  (replace-string "const Teuchos::Ptr<CompositeVector>&" "const std::vector<CompositeVector*>&")
  (beginning-of-buffer)
  (replace-string "Keys::getDomain(my_key_)" "Keys::getDomain(my_keys_.front().first)")
  (beginning-of-buffer)
  (replace-string "result->" "result[0]->")
  (beginning-of-buffer)
  (replace-string "my_key_" "my_keys_.front().first")
  (beginning-of-buffer)
  (replace-string "Tag::NEXT" "my_keys_.front().second")
  (beginning-of-buffer)
  (replace-string "EnsureCompatibility(const State& S)" "EnsureCompatibility(State& S)")
  (beginning-of-buffer)
  (replace-string "S.RequireEvaluator(key)->EnsureCompatibility(S);" "S.RequireEvaluator(key).EnsureCompatibility(S);")
  (beginning-of-buffer)
  (whitespace-cleanup)
  (beginning-of-buffer)
)


;;
;; appearances
;; ----------------------------------------
;; powerline
(use-package spaceline :ensure t)
(use-package spaceline-config :ensure spaceline
  :config
  (spaceline-emacs-theme)
  (spaceline-toggle-buffer-size-off)
  (spaceline-toggle-projectile-root-off)
  ;;(spaceline-toggle-minor-modes-off)
)

;; themes
(use-package zenburn-theme :ensure t)
(use-package solarized-theme :ensure t)
(add-hook 'after-init-hook (lambda () (load-theme 'solarized-zenburn)))

;;
;; macros
;; --------------------------------
(fset 'fixit-evaluator-dependencies-insert
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r down return ?d ?e ?p ?e ?n ?d ?n ?e ?c ?i C-left ?\C-k ?d ?e ?p ?e ?n ?d ?e ?n ?c ?i ?e ?s ?_ ?. ?i ?n ?s ?e ?r ?t ?\( return ?K ?e ?y ?T ?a ?g ?\{ ?\C-e left left ?, ?  ?t ?a ?g ?\}] 0 "%d"))
(global-set-key [f2] 'fixit-evaluator-dependencies-insert)

(fset 'fixit-evaluator-add-tag
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r ?  down return ?d ?o ?m ?a ?i ?n ?_ ?n ?a ?m ?e ?  ?= ?  return down ?\C-a return up ?\C-a down ?\C-k up tab ?T ?a ?g ?  ?t ?a ?g ?  ?= ?  ?m ?y ?_ ?k ?e ?y ?s ?_ ?. ?f ?r ?o ?n ?t ?\( ?\) ?. ?s ?e ?c ?o ?n ?d ?\; return ?\C-a ?\C-k return] 0 "%d"))
(global-set-key [f3] 'fixit-evaluator-add-tag)

(fset 'fixit-use-readkey
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r ?w ?a ?r ?d return ?k ?e ?y ?_ ?  ?= ?  ?p ?l ?i ?s ?t ?_ backspace return C-left ?K ?e ?y ?s ?: ?: ?r ?e ?a ?d ?K ?e ?y ?\( C-right right ?, ?  ?d ?o ?m ?a ?i ?n ?_ ?n ?a ?m ?e ?, ?  ?\C-  ?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r down return ?\" return left C-backspace C-backspace C-backspace backspace] 0 "%d"))
(global-set-key [f1] 'fixit-use-readKey)

(fset 'fixit-add-tag
   (kmacro-lambda-form [tab ?T ?a ?g ?  ?t ?a ?g ?  ?= ?  ?k backspace ?m ?y ?_ ?k ?e ?y ?s ?_ ?. ?f ?r ?o ?n ?t ?\( ?\) ?. ?s ?e ?c ?o ?n ?d ?\; return] 0 "%d"))
(fset 'fixit-override
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r down return ?\( backspace ?\; return left ?  ?o ?v ?e ?r ?l ?o ?a ?d backspace backspace backspace backspace ?r ?i ?d ?e] 0 "%d"))
(fset 'fixit-remove-arg
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r down return ?\( return ?\C-  ?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r return ?\) return left ?\C-w] 0 "%d"))
(fset 'fixit-return-after-wrt_tag
   (kmacro-lambda-form [?\M-x ?s ?e ?a ?r ?h ?c ?  ?f ?o ?r backspace C-backspace backspace backspace backspace ?c ?h ?  ?f ?o ?r down return ?w ?r ?t ?_ ?t ?a ?g return right return ?\C-x ?\C-s] 0 "%d"))
(fset 'fixit-default-copy-constructor
   (kmacro-lambda-form [?\M-< ?\M-x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r down return ?o ?t ?h ?e ?r return ?\C-e backspace ?  ?d ?e ?f ?u ?a ?l backspace backspace backspace ?a ?u ?l ?t ?\; C-left ?= ?  ?\C-x ?\C-s] 0 "%d"))

(fset 'manning-boundary-face
   (kmacro-lambda-form [?\C-\[ ?x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r ?\C-m ?m ?a ?n ?n ?i ?n ?g ?\C-m ?\C-\[ ?x ?s ?e ?a ?r ?c ?h ?  ?f ?o ?r ?\C-\[ ?O ?B ?\C-m ?b ?o ?u ?n ?d ?a ?r ?y ?_ ?f ?a ?c ?e ?\C-m ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-? ?\C-x ?\C-s ?\C-x ?\C-f ?d ?o ?w ?n ?  ?p ?i ?\C-m] 0 "%d"))


;; emacs-client
(server-start)

;; comments are always appreciated
(global-set-key (kbd "C-c c") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)

;; navigate windows backwards
(global-set-key (kbd "C-x p") (lambda ()
                                (interactive)
                                (other-window -1)))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("51ec7bfa54adf5fff5d466248ea6431097f5a18224788d0bd7eb1257a4f7b773" default))
 '(imenu-auto-rescan t)
 '(markdown-command "/usr/local/bin/markdown")
 '(package-selected-packages
   '(persp-projectile perspective hideshow whitespace nxml sgml-mode nxml-mode zenburn-theme use-package treemacs srefactor spaceline solarized-theme ox-rst markdown-mode magit impatient-mode ein counsel-projectile cmake-mode))
 '(safe-local-variable-values '((c-default-style . "google"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(line-number ((t (:background "#3F3F3F" :foreground "light green" :underline nil :weight thin))))
 '(mode-line ((((class color) (min-colors 89)) (:inverse-video unspecified :overline "light green" :underline "#284b54" :foreground "light green" :background "#4F4F4F" :box (:line-width 1 :color "light green" :style unspecified)))))
 '(powerline-active1 ((t (:background "#3F3F3F" :foreground "light green"))))
 '(powerline-active2 ((t (:background "#4F4F4F" :foreground "plum2"))))
 '(powerline-inactive1 ((t (:background "#4F4F4F" :foreground "PaleGreen4")))))
