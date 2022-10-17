(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#839496" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#fdf6e3"))
 '(beacon-color "#d33682")
 '(custom-enabled-themes '(sanityinc-tomorrow-eighties))
 '(custom-safe-themes
   '("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" default))
 '(fci-rule-color "#073642")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(frame-background-mode 'dark)
 '(ispell-dictionary nil)
 '(mailcap-user-mime-data '(((viewer . "mpv --loop %s") (type . "image/jpg"))))
 '(package-selected-packages
   '(python-mode color-theme-sanityinc-solarized color-theme-sanityinc-tomorrow company ein lsp-mode lsp-pyright paredit eldoc undo-tree))
 '(vc-annotate-background nil)
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
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'dired-x)

(add-hook
 'dired-mode-hook
 (lambda ()
   (dired-omit-mode)
   (dired-hide-details-mode)))

(add-hook
 'emacs-lisp-mode-hook
 (lambda ()
   (paredit-mode)))

(add-hook
 'python-mode-hook
 (lambda ()
   (require 'python-mode)
   (setq py-indent-offset 2)
   (setq python-indent-offset 2)
   (lsp)))

(menu-bar-mode 0)
(tool-bar-mode 0)
(column-number-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(global-undo-tree-mode)

(global-set-key (kbd "C-w") 'backward-kill-word)
(global-set-key (kbd "C-x C-k") 'kill-region)

(setq mailcap-user-mime-data
      '(((type   . "(image/jpg|image/png)")
	 (viewer . "mpv --loop %s"))))

;; Workaround for the conflict between python.el and python-mode.el
;; https://gitlab.com/python-mode-devs/python-mode/-/issues/105

;; Thomas Lotze
;; @tlotze · 2022-09-10

;; FWIW, I experience the two modes to be compatible in the sense that
;; once one of them has been applied to a buffer, it works without the
;; other mode's functionality getting in the way. However, there is
;; the issue of which mode gets applied, and that is non-obvious, to
;; say the least. I'm using Emacs 28.1 and python-mode 6.3.0.

;; The behaviour I observe is that when opening Python files, the
;; python-mode.el variety gets used, as can be seen by the "Py"
;; lighter. However, sometimes Emacs starts using the python.el mode
;; on newly opened files, either right from the start or starting from
;; some seemingly random point during a session. Turns out this has to
;; do with autoloads and registration of definition prefixes:

;; While the loading order of the two files is always such that
;; python-mode.el gets to override things, it doesn't register itself
;; for the "python-" prefix. So when the python-mode function is first
;; accessed, it is autoloaded from python-mode.el if there hadn't been
;; a reason to load python.el earlier. But as soon as something
;; accesses the definition-prefixes hash table for the first time, be
;; it some Emacs code loaded during Emacs start-up or the user
;; triggering completions, python.el is loaded and the python-mode
;; function gets defined or overridden by it, switching the preferred
;; Python mode to the built-in one for the remainder of the session.

;; So here is a suggestion for how to "better override" the built-in
;; Python mode by python-mode.el: register python-mode.el for the
;; "python-" prefix (which is correct anyway as it exports the
;; python-mode function) and do it in such a way that python-mode.el
;; is loaded last when completions on the "python-" prefix are
;; searched. This is what works for me; it needs to be run after the
;; python-mode package has been autoloaded: 

;; (puthash "python-"
;;          (append (gethash "python" definition-prefixes) '("python-mode"))
;;          definition-prefixes)

;; This snippet is derived from the definition of
;; register-definition-prefixes and (in my experience) reliably solves
;; the problem I described. It may be worth adding to python-mode.el's
;; autoloads to achieve a more stable experience for users who install
;; python-mode.el to override the built-in Python mode.. 

(require 'python-mode)
(puthash
 "python-"
 (append (gethash "python" definition-prefixes) '("python-mode"))
 definition-prefixes)
