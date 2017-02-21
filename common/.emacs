;; initialize packages
(require 'package)
(package-initialize)

;; indentation
(setq-default c-basic-offset 4)

;; recognize .def files as c-code
(add-to-list 'auto-mode-alist '("\\.def\\'" . c-mode)) 
;; recognize .sdl files as c-code
(add-to-list 'auto-mode-alist '("\\.sdl\\'" . c-mode)) 

;; auto-complete code
(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
;; Bad config - select candidates with C-n/C-p
;; only allow this when the menu is displayed though
;;(setq ac-use-menu-map t)
;;(define-key ac-completing-map "\C-n" 'ac-next)
;;(define-key ac-completing-map "\C-p" 'ac-previous)
;; Change autocomplete popup colors
(set-face-background 'ac-candidate-face "blue")
(set-face-underline 'ac-candidate-face "blue")
(set-face-background 'ac-selection-face "cyan")

;; display column number
(setq column-number-mode t)

;; flex autopair
(require 'flex-autopair)
(flex-autopair-mode 1)

;; Python auto-complete
;;(add-hook 'python-mode-hook 'jedi:setup)
;;(setq jedi:complete-on-dot t)                 ; optional

;; mark 78th column
(require 'column-marker)
(add-hook 'c-mode-hook (lambda () (interactive) (column-marker-2 78)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(comment-fill-column 78)
 '(ido-mode (quote buffer) nil (ido))
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/")
			    ("melpa" . "http://melpa.org/packages/"))))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-marker-2 ((t (:background "blue" :width ultra-condensed))))
 )

;; ace jump mode
(require 'ace-jump-mode)
(global-set-key (kbd "C-c SPC")    'ace-jump-mode)
(global-set-key (kbd "M-o r")      'kmacro-start-macro)
(global-set-key (kbd "M-o s")      'kmacro-end-or-call-macro)
