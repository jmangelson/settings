;; Recite the holy words
(defun confess-faith ()
  (interactive)
  (message "There is no system but GNU and Linux is one of its kernels"))

(setq my-emacs-version (nth 2 (split-string (emacs-version))))

(setq my-emacs-dir (file-name-directory load-file-name))

;; This basically will only work with emacs24.
(condition-case nil
    (progn
      (require 'package)
      (add-to-list 'package-archives
                   '("melpa" . "http://melpa.org/packages/") t)
      (package-initialize)

      (when (not package-archive-contents)
        (package-refresh-contents))

      ;; Add in your own as you wish:
      (defvar my-packages '(smex ido-ubiquitous idle-highlight-mode w3m yasnippet ein org auctex auto-complete)
        "A list of packages to ensure are installed at launch.")

      (dolist (p my-packages)
        (when (not (package-installed-p p))
          (package-install p)))

      (ido-mode t)
      (ido-ubiquitous-mode)
      ;; Use regular find-tag (no ido)
      (setq ido-ubiquitous-command-exceptions '(find-tag))

      (setq ido-use-virtual-buffers t
            recentf-max-saved-items 500)

      ;; Autocomplete in M-x
      (smex-initialize)
      (global-set-key (kbd "M-x") 'smex)

      (add-hook 'prog-mode-hook (lambda () (font-lock-add-keywords
                                            nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\|DEBUG\\):"
                                                   1 font-lock-warning-face t))))))
  (error nil))

;; --------------------------------------------------
;; Function definitions
;; --------------------------------------------------
(defun word-count nil "Count words in buffer" (interactive)
  (shell-command-on-region (point-min) (point-max) "wc -w"))

(defun char-count nil "Count chars in buffer" (interactive)
  (shell-command-on-region (point-min) (point-max) "wc -m"))

(defun paren-latex ()
  (interactive)
  (replace-regexp "(" "\\\\left(")
  (exchange-point-and-mark)
  (replace-regexp ")" "\\\\right)"))

(defun goto-tag ()
  (interactive)
  (let ((start (point)))
    (search-forward-regexp " \\|$\\|(\\|,\\|\\.")
    (backward-char)
    (let ((end (point)))
      (kill-ring-save start end)
      (find-tag (car kill-ring)))))

(defun find-files-recursively (dir)
  (let (returnList fileList)
    (setq returnList ())
    (setq fileList (file-expand-wildcards (concat dir "/*")))
    (while fileList
      (let (currentFile)
        (setq currentFile (car fileList))
        (if (not (car (file-attributes currentFile)))
            (setq returnList (cons currentFile returnList))
          (if (string-equal (car (file-attributes currentFile)) "t")
              (setq returnList (append (find-files-recursively currentFile) returnList)))))
      (pop fileList))
    returnList))

(defun open-filelist (fileList)
  (while fileList
    (let ((currentFile (car fileList)))
      (if (file-exists-p currentFile)
          (find-file-noselect (file-truename currentFile))))
    (setq fileList (cdr fileList))))

(defun file-basename (file)
  (let ((file-no-dash (replace-regexp-in-string "/$" "" file)))
    (car (reverse (split-string file-no-dash "/")))))

(defun filter-from-filelist (list expr)
  (let ((returnList ()))
    (while list
      (let ((currentItem (car list)))
        (if (not (string-match expr currentItem))
            (setq returnList (cons currentItem returnList)))
        (setq list (cdr list))))
    returnList))

(defun extract-from-filelist (list expr)
  (let ((returnList ()))
    (while list
      (let ((currentFile (car list)))
        (if (string-match expr currentFile)
            (setq returnList (cons currentFile returnList))))
      (setq list (cdr list)))
    returnList))

(defun find-file-this ()
  (interactive)
  (find-file buffer-file-name))

(defun command-line-diff (switch)
  (let ((file1 (pop command-line-args-left))
        (file2 (pop command-line-args-left)))
    (ediff file1 file2)))
(add-to-list 'command-switch-alist '("-diff" . command-line-diff))

(defun f ()
  (interactive)
  (set-face-attribute 'default nil :height 120))

(defun insert-amps ()
  (interactive)
  (insert (format "& %s &" (read-from-minibuffer "Symbol? "))))

(defun kill-all-dired-buffers (exclude)
  "Kill all dired buffers."
  (interactive)
  (save-excursion
    (let((count 0))
      (dolist(buffer (buffer-list))
        (set-buffer buffer)
        (when (and (equal major-mode 'dired-mode)
                   (not (string-equal (buffer-name) exclude)))
          (setq count (1+ count))
          (kill-buffer buffer)))
      (message "Killed %i dired buffer(s)." count ))))

(defun eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its value"
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (whitespace-cleanup))

(defun c-c++-header ()
  "sets either c-mode or c++-mode, whichever is appropriate for
header, based on presence of .c file"
  (interactive)
  (let ((c-file (concat (substring (buffer-file-name) 0 -1) "c")))
    (if (file-exists-p c-file)
        (c-mode)
      (c++-mode))))

;; --------------------------------------------------
;; Aliases
;; --------------------------------------------------
(defalias 'yes-or-no-p 'y-or-n-p) ;; That 'yes' or 'no' shit is anoying:
(defalias 'man 'woman) ;; Doesn't work at startup?
(defalias 'cf 'customize-face)
(defalias 'c (lambda ()
               (interactive)
               (compile "compile ~/perls/build")))
(defalias 'cc (lambda ()
                (interactive)
                (compile "compile ~/perl/perl-git/hauv-mosaic")))
(defalias 'ac (lambda ()
                (interactive)
                (if auto-complete-mode
                    (auto-complete-mode -1)
                  (auto-complete-mode t))))

;; --------------------------------------------------
;; Packages / Minor modes / Keybindings
;; --------------------------------------------------
;; append my stuff to load-path
(add-to-list 'load-path
             (concat (file-name-as-directory my-emacs-dir) "lisp"))

(require 'matlab)
(require 'cmake-mode)
(require 'lua-mode)
(require 'autopair)
(require 'unbound)
(require 'yasnippet)
(require 'color-theme)
(require 'linum)
(require 'flymake)
(require 'flymake-cursor)
(require 'org-install)
(require 'uniquify)
(require 'rainbow-mode)
(require 'reftex)
(require 'w3m)
(require 'mediawiki)
(require 'highline)
(require 'diff-mode-)
(require 'smarttabs)
(require 'browse-kill-ring)
(require 'nyan-mode)
(show-paren-mode 1) ;;This needs to be enabled before changing color theme
(require 'subword)
(require 'naquadah-theme)
(require 'dired-mod)            ;; mine
(require 'myOrgSettings)        ;; mine
(require 'smooth-scrolling)
(require 'markdown-mode)

;; idle-highlight-mode only works on emacs 24
(condition-case nil
    (progn
      (require 'idle-highlight-mode))
  (error nil))

;; (require 'idle-highlight-mode)

;; Turn off the bad shit
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Turn on the good shit
(transient-mark-mode 1)
(ido-mode t)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-auto-merge-work-directories-length nil
      ido-create-new-buffer 'always
      ido-use-filename-at-point nil
      ido-handle-duplicate-virtual-buffers 2
      ido-max-prospects 10)
(setq mouse-yank-at-point 1)
(autopair-global-mode 1)
(setq autopair-autowrap t)
;; (global-linum-mode 1)
(global-auto-revert-mode t)
(column-number-mode 1)
(setq default-fill-column 90)
(setq scroll-preserve-screen-position 1)
(setq woman-fill-column default-fill-column)
(setq-default indicate-empty-lines t)
(setq gdb-many-windows t)
(setq ns-command-modifier 'meta)
(setq bibtex-align-at-equal-sign t)

;; To keep myself happy
(set-default 'indent-tabs-mode nil)
(setq-default tab-width 4)
(defalias 'un 'untabify-buffer)

;; ipython notebook mode
(defun ipn ()
  (interactive)
  (ein:notebooklist-open))

;; stuff for anything library
;; (global-set-key "\M-." 'anything-etags+-select-one-key)
;; (global-set-key "\M-*" 'anything-etags+-history-go-back)

;; Woman is pretty cool
(setq woman-use-own-frame nil)

;; Make the nyan mode line not so long
(nyan-mode)
(setq nyan-bar-length 12)
;; I know it's tempting, Paul - but DO NOT enable this!
;; (nyan-start-animation)

;; Show time in mode line
(display-time)

;; This makes color work in 'M-x shell'
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(if (string-equal system-type "gnu/linux")
    (setq shell-file-name "/bin/bash"))

;; Number of killed things to remember
(setq kill-ring-max 6000)

;; My key bindings
(global-set-key (kbd "C-x h") 'global-highline-mode)
(global-set-key (kbd "C-x l") 'linum-mode)
(global-set-key [(meta return)] 'shell-resync-dirs)
(global-set-key (kbd "C-c C-f") 'find-file-this)
                                        ;(global-set-key [(meta .)] 'goto-tag)
(global-set-key [(control o)] 'other-window)
(global-set-key [(control meta |)] 'fill-region)
(global-set-key [(meta h)] 'ff-find-other-file)
(global-set-key (kbd "C-c k") 'ido-kill-buffer)
(global-set-key (kbd "C-S-k") (lambda () (interactive)
                                (kill-all-dired-buffers (user-login-name))))
(global-set-key (kbd "C-S-a") 'align-regexp)
(global-set-key (kbd "C-x f") 'find-name-dired)
(global-set-key (kbd "C-x C-j") 'dired-jump)
(global-set-key (kbd "C-x m") 'comment-region)
(global-set-key (kbd "C-x C-b") (lambda () 
                                  (interactive)
                                  (ibuffer)
                                  (isearch-forward)))
(global-set-key (kbd "M-e") (lambda () 
                              (interactive)
                              (next-line 3)))
(global-set-key (kbd "M-a") (lambda () 
                              (interactive)
                              (previous-line 3)))
(global-set-key (kbd "<f5>") 'shrink-window-horizontally)
(global-set-key (kbd "<f6>") 'enlarge-window-horizontally)
(global-set-key (kbd "<f7>") 'shrink-window)
(global-set-key (kbd "<f8>") 'enlarge-window)
;; (global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-c e") 'eval-and-replace)
(global-set-key (kbd "C-c u") 'cua-mode)
(global-set-key (kbd "M-Q") (lambda ()
                              (interactive)
                              (fill-paragraph 1)))
(setq ediff-split-window-function 'split-window-horizontally)

(put 'upcase-region 'disabled nil)

(if (file-exists-p "~/TAGS")
    (visit-tags-table "~/TAGS"))

;; HACK: disable the default snippets packaged with melpa
(setq yas-snippet-dirs (concat (file-name-as-directory my-emacs-dir) "snippets"))
(yas/initialize)

(put 'downcase-region 'disabled nil)

(setq TeX-auto-save t)
(setq TeX-parse-self t)

;; Activate occur easily inside isearch
(define-key isearch-mode-map (kbd "C-M-o")
  (lambda () (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))

(global-highline-mode 1)

;; --------------------------------------------------
;; Language-specific settings
;; --------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.txt$" . mediawiki-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt$" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.lcm$" . java-mode))
(add-to-list 'auto-mode-alist '("Doxyfile$" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.shell_aliases$" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.SRC$" . asm-mode))
(add-to-list 'auto-mode-alist '("\\.isam$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.moos$" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-c++-header))
(setq matlabf-fill-code nil)

;; set default C style to 4-space indentation with "cc-mode" style (from rme-linux)
(setq c-default-style
      '((java-mode . "java") (awk-mode . "awk") (c-mode . "cc-mode") (other . "cc-mode")))
;; Also make function calls highlighted for common programming modes
(let (modeList)
  (setq modeList '(c-mode
                   c++-mode
                   python-mode
                   java-mode))
  (while modeList
    (font-lock-add-keywords (car modeList)
                            '(("\\s\"?\\(\\(\\sw\\|\\s_\\)+\\(<-\\)?\\)\\s\"?*\\s-*("
                               (1 font-lock-function-name-face)))  t)
    (setq modeList (cdr modeList))))
;; Special case: require space before opening parenthesis:
(font-lock-add-keywords 'matlab-mode
  '(("\\s\"?\\(\\(\\sw\\|\\s_\\)+ \\(<-\\)?\\)\\s\"?*\\s-*("
    (1 font-lock-function-name-face)))  t)
(font-lock-add-keywords 'octave-mode
  '(("\\s\"?\\(\\(\\sw\\|\\s_\\)+ \\(<-\\)?\\)\\s\"?*\\s-*("
    (1 font-lock-function-name-face)))  t)

;; LaTeX: Enable flymake for texlive distribution of LaTeX
(defun flymake-get-tex-args (file-name)
  (list "pdflatex" (list "-shell-escape" "-draftmode" "-file-line-error" "-interaction=nonstopmode" file-name)))

;; --------------------------------------------------
;; My hooks
;; --------------------------------------------------
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'ibuffer-mode-hook (lambda ()
                               (define-key ibuffer-mode-map (kbd "C-o") 'other-window)))

(condition-case nil
    (global-subword-mode 1)
  (error nil))

;; apply CamelCase hooks
(let (modeList)
  (setq modeList '(python-mode-hook 
                   java-mode-hook
                   c-mode-hook
                   c++-mode-hook
                   matlab-mode-hook
                   cmake-mode-hook
                   emacs-lisp-mode-hook))
  (while modeList
    (add-hook (car modeList) (lambda ()
                               (hs-minor-mode)
                               (define-key hs-minor-mode-map [(control tab)] 'hs-toggle-hiding)
                               ;; Only supported in emacs 24
                               (condition-case nil
                                   (progn
                                     (idle-highlight-mode t))
                                 (error nil))))
    (setq modeList (cdr modeList))))

;; apply LaTeX hooks (spellcheck, etc.)
(add-hook 'LaTeX-mode-hook (lambda ()
                             (flyspell-mode)
                             (outline-minor-mode)
                             (auto-fill-mode)
                             ;;(flymake-mode)
                             (turn-on-reftex)
                             (define-key LaTeX-mode-map (kbd "C-7") 'insert-amps)
                             (orgtbl-mode)
                             (TeX-PDF-mode-on)
                             (TeX-global-PDF-mode t)))

;; this makes control-tab function like org-mode
(add-hook 'outline-minor-mode-hook
          (lambda ()
            (define-key outline-minor-mode-map [(control tab)] 'org-cycle)))

;; elisp documentation in minibuffer
(add-hook 'emacs-lisp-mode-hook (lambda ()
                                  (turn-on-eldoc-mode)
                                  (rainbow-mode)))

;; spell check should be enabled in .txt files
(add-hook 'mediawiki-mode-hook (lambda ()
                            (flyspell-mode)))

;; matlab rebinds M-e and M-a
(add-hook 'matlab-mode-hook (lambda ()
                              (define-key matlab-mode-map (kbd "M-e") (lambda ()
                                                                        (interactive)
                                                                        (next-line 6)))
                              (define-key matlab-mode-map (kbd "M-a") (lambda ()
                                                                        (interactive)
                                                                        (previous-line 6)))))

(add-hook 'vc-dir-mode-hook (lambda ()
                              (define-key vc-dir-mode-map (kbd "RET") 'vc-dir-find-file-other-window)))

;; check the buffer when flyspell loads
(add-hook 'flyspell-mode-hook (lambda ()
                                (flyspell-buffer)))

;; Don't indent extern "C"
(add-hook 'c-mode-hook (lambda ()
                         (c-set-offset 'inextern-lang 0)))

;; Use /* comment */ for c++
(add-hook 'c++-mode-hook (lambda ()
                           (setq comment-start "/* "
                                 comment-end " */")
                           (c-set-offset 'innamespace 0)))

;; Use % for octave
(add-hook 'octave-mode-hook (lambda ()
                              (setq comment-start "% ")))


(server-start)
;; diable warning when killing buffers opened with emacsclient 
;; (must be set after calling (server-start))
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command "latex -shell-escape")
 '(TeX-view-program-list (quote (("Evince" "evince --page-index=%(outpage) %o"))))
 '(c-doc-comment-style (quote gtkdoc))
 '(ido-ignore-files (quote ("\\`CVS/" "\\`#" "\\`.#" "\\`\\.\\./" "\\`\\./" "_region_" "\\\\.prv/" "\\auto/" "__flymake")))
 '(inhibit-default-init t)
 '(inhibit-startup-screen t)
 '(jabber-account-list (quote (("pjozog@gmail.com" (:network-server . "talk.google.com") (:connection-type . ssl)))))
 '(org-agenda-files (quote ("~/Dropbox/org/projects.org")))
 '(org-hide-leading-stars nil)
 '(search-whitespace-regexp "[ \t\r\n]+")
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(vc-follow-symlinks t)
 '(vc-hg-log-switches (quote ("-v"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dired-directory ((t (:inherit font-lock-builtin-face))))
 '(dired-symlink ((t (:inherit font-lock-comment-face))))
 '(diredp-dir-heading ((((background dark)) (:inherit font-lock-comment-face))))
 '(diredp-dir-priv ((((background dark)) (:foreground "#7474FFFFFFFF"))))
 '(font-latex-string-face ((((class color) (background dark)) (:foreground "#A2AB64"))))
 '(org-column ((t (:background "#000000" :strike-through nil :underline nil :slant normal :weight normal :height 98 :family "DejaVu Sans Mono")))))

;; os-specific stuff:
;; GNU/Linux
(if (string-equal "gnu/linux" system-type)
    (if (string-equal "paul-laptop" system-name)
        (set-face-attribute 'default nil :height 75 :family "ubuntu mono")
      (set-face-attribute 'default nil :height 100 :family "ubuntu mono")))

;; OS X
(if (string-equal "darwin" system-type)
    (setq ns-command-modifier 'meta))

(open-filelist '("~/.emacs.d/init.el" "~/.shell_aliases" "~/.profile"
                 "~/.config/openbox/autostart.sh"
                 "~/.config/awesome/rc.lua"
                 "~/Dropbox/personal/org/projects.org"
                 "~/perl/perl-svn/references/bibtex/references.bib"))

;; Fix linum margin when running in terminal mode
(setq linum-format "%d ")
(dired (getenv "HOME"))
(switch-to-buffer (user-login-name))
(setq split-height-threshold 90)
(split-window-sensibly (selected-window))
(switch-to-buffer "*scratch*")
