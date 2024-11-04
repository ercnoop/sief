;;; init.el --- Virtual Lisp Machine Configuration (init.el)

;;; Commentary:

;; ... Present day, present time ....

;;; Code:

;;; -*- lexical-binding: t -*-

(when (version< emacs-version "26.3")
  (error "This requires Emacs 26.3 and above!"))

(setq load-prefer-newer noninteractive)

(require 'cl-seq)

(defun vlm/generate-dir-loaddefs (dir &optional generate-full)
  "Generate loaddefs file for all directories inside of `user-emacs-directory/lisp'.
If called interactively, regenerate all loaddefs."
  (let* ((dir (expand-file-name dir))
         (dir-name (car (reverse (string-split dir "/" 't))))
         (outputfile (format "%s/%s-loaddefs.el" dir dir-name)))
    (message (format "Generating loaddefs for %s into %s..." dir outputfile))
    (loaddefs-generate
     (cl-remove-if-not #'file-directory-p (directory-files-recursively dir "^[^.]" t))
     (expand-file-name outputfile dir) nil nil nil generate-full)
    (when generate-full
      (message "Fully generated new loaddefs file"))))

(defun vlm/generate-loaddefs (dir &optional)
  (interactive "DDirectory:")
  (vlm/generate-dir-loaddefs dir))

(require 'loaddefs)

(defmacro safe-load-file (file)
  "Load FILE if exists."
  `(if (not (file-exists-p ,file))
       (message "File not found")
     (load (expand-file-name ,file) t nil nil)))

(defmacro safe-add-dirs-to-load-path (dirs)
  "Add DIRS (directories) to `load-path'."
  `(dolist (dir ,dirs)
     (setq dir (expand-file-name dir))
     (when (file-directory-p dir)
       (unless (member dir load-path)
         (push dir load-path)))))

(defmacro safe-funcall (func &rest args)
  "Call FUNC with ARGS, if it's bounded."
  `(when (fboundp ,func)
     (funcall ,func ,@args)))

(defmacro safe-mkdir (dir)
  "Create DIR in the file system."
  `(when (and (not (file-exists-p ,dir))
              (make-directory ,dir :parents))))

(defun add-dir-to-load-path (dir)
  "Add dir to load-path."
  (interactive "DDirectory:")
  (safe-add-dirs-to-load-path (list dir)))

(safe-add-dirs-to-load-path '("~/.emacs.d/lisp/magit/lisp"))

;; threshold inital value
(setq gc-cons-threshold most-positive-fixnum) ; 2^61 bytes

;; yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

(defvar saved-file-name-handler-alist
  file-name-handler-alist
  "Save `file-name-handler-alist' variable.")

(defvar vlm-window-map
  (make-sparse-keymap)
  "Window commands keymap.")

(defvar vlm-rb-map
  (make-sparse-keymap)
  "Register/Bookmarks commands keymap.")

(defvar vlm-tags-map
  (make-sparse-keymap)
  "Tags (navigation) commands keymap.")

(defvar vlm-tabs-map
  (make-sparse-keymap)
  "Tabs (navigation) commands keymap.")

(defvar vlm-pm-map
  (make-sparse-keymap)
  "Project management commands keymap.")

(defvar vlm-sc-map
  (make-sparse-keymap)
  "Syntax check commands keymap.")

(defvar vlm-completion-map
  (make-sparse-keymap)
  "Completion commands keymap.")

(defvar vlm-docs-map
  (make-sparse-keymap)
  "Docs commands keymap.")

(defvar vlm-files-map
  (make-sparse-keymap)
  "Files commands keymap.")

(defvar vlm-debug-map
  (make-sparse-keymap)
  "Debug commands keymap.")

(defvar vlm-filter-map
  (make-sparse-keymap)
  "Filter commands keymap.")

(defvar vlm-utils-map
  (make-sparse-keymap)
  "Utils commands keymap.")

(defvar vlm-media-map
  (make-sparse-keymap)
  "Media commands keymap.")

(dolist (prefix-map '(vlm-tags-map
                      vlm-tabs-map
                      vlm-rb-map
                      vlm-pm-map
                      vlm-sc-map
                      vlm-docs-map
                      vlm-files-map
                      vlm-filter-map
                      vlm-utils-map
                      vlm-window-map
                      vlm-media-map
                      vlm-completion-map))
  (define-prefix-command prefix-map))

;; vlm prefix maps
(define-key ctl-x-map (kbd "f") 'vlm-files-map) ;; files
;; (define-key ctl-x-map (kbd "") 'vlm-filter-map)
(define-key ctl-x-map (kbd "p") 'vlm-pm-map) ; project
(define-key ctl-x-map (kbd "t") 'vlm-tags-map) ; tags
(define-key ctl-x-map (kbd "C-o") 'vlm-tabs-map) ; tabs
(define-key ctl-x-map (kbd "c") 'vlm-utils-map) ; commands
(define-key ctl-x-map (kbd "e") 'vlm-sc-map) ; errors
(define-key ctl-x-map (kbd "l") 'vlm-docs-map) ; library
(define-key ctl-x-map (kbd "v") 'vlm-media-map) ; video/media
(define-key ctl-x-map (kbd "<tab>") 'vlm-completion-map) ; tab (complete)

;; add vlm-theme-dir to theme load path
(add-to-list 'custom-theme-load-path
             (concat user-emacs-directory "themes"))
(load-theme 'moebius-glass t)

;; clean file-name-handler-alist
(setq file-name-handler-alist nil)

;; restore file-name-handler-alist
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  saved-file-name-handler-alist)))

;; non-nil inhibits the startup screen
(customize-set-variable 'inhibit-startup-message nil)

;; non-nil inhibits the initial startup echo area message
(customize-set-variable 'inhibit-startup-echo-area-message nil)

;; major mode command symbol to use for the initial *scratch* buffer
(customize-set-variable 'initial-major-mode 'emacs-lisp-mode)

;; the full name of the user logged in
(customize-set-variable 'user-full-name (getenv "USER"))

;; email address of the current user
(customize-set-variable 'user-mail-address "menezes.n.eric@gmail.com")

;; (require 'warnings nil t)

;; minimum severity level for displaying the warning buffer
(customize-set-variable 'warning-minimum-level :error)

;; minimum severity level for logging a warning.
(customize-set-variable 'warning-minimum-log-level :warning)

;; non-nil means normalize frame before maximizing (not working)
;; (customize-set-variable 'x-frame-normalize-before-maximize nil)

;; if non-nil with a Gtk+ built Emacs, the Gtk+ tooltip is used
(customize-set-variable 'x-gtk-use-system-tooltips t)

;; if this equals the symbol ’hide’, Emacs temporarily hides the child
;; frame during resizing (testing)
(customize-set-variable 'x-gtk-resize-child-frames 'resize-mode)

;; (require 'files nil t)

(defun vlm-kill-emacs-query-function ()
  "Asks for Emacs kill confirmation."
  (interactive)
  (y-or-n-p "[kill-emacs]: Are you sure? "))

;; control use of version numbers for backup files.
(customize-set-variable 'version-control t)

;; non-nil means always use copying to create backup files
(customize-set-variable 'backup-by-copying t)

;; number of newest versions to keep when a new numbered backup is made
(customize-set-variable 'kept-new-versions 6)

;; number of oldest versions to keep when a new numbered backup is made
(customize-set-variable 'kept-old-versions 2)

;; if t, delete excess backup versions silently
(customize-set-variable 'delete-old-versions t)

;; non-nil means make a backup of a file the first time it is saved
(customize-set-variable 'make-backup-files nil)

;; non-nil says by default do auto-saving of every file-visiting buffer
(customize-set-variable 'auto-save-default nil)

;; most *NIX tools work best when files are terminated
;; with a newline
(customize-set-variable 'require-final-newline t)

;; non-nil if Emacs should confirm killing processes on exit
(customize-set-variable 'confirm-kill-processes nil)

;; functions to call with no arguments to query about killing Emacs
(customize-set-variable 'kill-emacs-query-functions
                        `(server-kill-emacs-query-function vlm-kill-emacs-query-function))

;; alist of filename patterns and backup directory names
(customize-set-variable 'backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; create cache directory, if necessary
;; (add-hook 'window-setup-hook
;;           (lambda ()
;;             (mkdir (concat user-emacs-directory "cache") t)))

;; (require 'ffap nil t)

;; vlm-files-map
(define-key vlm-files-map (kbd "f") 'find-file-at-point)
(define-key vlm-files-map (kbd "d") 'dired-at-point)
(define-key vlm-files-map (kbd "C-d") 'ffap-list-directory)

;; (require 'locate nil t)

(define-key vlm-files-map (kbd "l") 'locate)

;; (require 'recentf nil t)

;; file to save the recent list into.
(customize-set-variable
 'recentf-save-file (concat user-emacs-directory "cache/recentf"))

;; vlm-files-map
(define-key vlm-files-map (kbd "r") 'recentf-open-files)
(define-key vlm-files-map (kbd "t") 'recentf-find-file)

(add-hook 'window-setup-hook
          (lambda ()
            (safe-funcall 'recentf-mode 1)))

;; (require 'diff nil t)

;; a string or list of strings specifying switches to be passed to diff
(customize-set-variable 'diff-switches "-u")

;; (require 'ediff nil t)

;; options to pass to `ediff-custom-diff-program'.
(customize-set-variable 'ediff-custom-diff-options "-U3")

;; the function used to split the main window between buffer-A and buffer-B
(customize-set-variable 'ediff-split-window-function 'split-window-horizontally)

;; function called to set up windows
(customize-set-variable 'ediff-window-setup-function 'ediff-setup-windows-plain)

(add-hook 'ediff-startup-hook 'ediff-toggle-wide-display)
(add-hook 'ediff-cleanup-hook 'ediff-toggle-wide-display)
(add-hook 'ediff-suspend-hook 'ediff-toggle-wide-display)

;; (require 'jka-compr nil t)
;; (require 'jka-compr-hook nil t)

;; list of compression related suffixes to try when loading files
(customize-set-variable 'jka-compr-load-suffixes '(".gz" ".el.gz"))

;; if you set this outside Custom while Auto Compression mode is
;; already enabled (as it is by default), you have to call
;; `jka-compr-update' after setting it to properly update other
;; variables. Setting this through Custom does that automatically.

;; turn on the mode
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'auto-compression-mode 1)))

;; (require 'dired nil t)

;; enable dired-find-alternate-file
(add-hook 'window-setup-hook
          (lambda ()
            (put 'dired-find-alternate-file 'disabled nil)))

;; dired-mode-map
(eval-after-load 'dired
  (lambda ()
    (when (boundp 'dired-mode-map)
      (define-key dired-mode-map (kbd "c") 'dired-do-copy)
      (define-key dired-mode-map (kbd "e") 'dired-create-empty-file)
      (define-key dired-mode-map (kbd "C") 'dired-do-compress-to)
      ;; redundancy
      (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
      (define-key dired-mode-map (kbd "C-j") 'dired-find-alternate-file))))

;; ctl-x-map (redundancy)
(define-key ctl-x-map (kbd "d") 'dired)
(define-key ctl-x-map (kbd "C-d") 'dired)

;; (require 'frame nil t)

;; with some window managers you may have to set this to non-nil
;; in order to set the size of a frame in pixels, to maximize
;; frames or to make them fullscreen.
(customize-set-variable 'frame-resize-pixelwise t)

;; normalize before maximize
(customize-set-variable 'x-frame-normalize-before-maximize t)

;; set frame title format
(customize-set-variable 'frame-title-format
                        '((:eval (if (buffer-file-name)
                                     (abbreviate-file-name (buffer-file-name))
                                   "%b"))))

;; alist of parameters for the initial minibuffer frame.
;; (customize-set-variable 'minibuffer-frame-alist
;;                         '((top . 1)
;;                           (left . 1)
;;                           (width . 80)
;;                           (height . 2)))

;; alist of parameters for the initial X window frame
(add-to-list 'initial-frame-alist '(fullscreen . fullheight))

;; alist of default values for frame creation
(add-to-list 'default-frame-alist '(internal-border-width . 2))

;; set transparency after a frame is created
;; (add-hook 'after-make-frame-functions
;;           (lambda (frame)
;;             (set-frame-transparency .8)))

;; global map
;;(global-set-key (kbd "C-x C-o") 'other-frame)

(defmacro safe-set-frame-font (font)
  "Set the default font to FONT."
  `(cond ((find-font (font-spec :name ,font))
          (set-frame-font ,font nil t))))

;; (safe-set-frame-font "Iosevka:pixelsize=20:width=regular:weight=regular")

;; window divider
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'window-divider-mode 1)))

;; blink cursor
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'blink-cursor-mode 1)))

;; number of lines of margin at the top and bottom of a window
(customize-set-variable 'scroll-margin 0)

;; scroll up to this many lines, to bring point back on screen
(customize-set-variable 'scroll-conservatively 1)

;; t means point keeps its screen position
(customize-set-variable 'scroll-preserve-screen-position t)

;; non-nil means mouse commands use dialog boxes to ask questions
(customize-set-variable 'use-dialog-box nil)

;; width in columns of left marginal area for display of a buffer
(customize-set-variable 'left-margin-width 1)

;; width in columns of right marginal area for display of a buffer.
(customize-set-variable 'right-margin-width 1)

;; if t, resize window combinations proportionally
(customize-set-variable 'window-combination-resize t)

;; if non-nil ‘display-buffer’ will try to even window sizes
(customize-set-variable 'even-window-sizes t)

;; if non-nil, left and right side windows occupy full frame height
(customize-set-variable 'window-sides-vertical nil)

;; non-nil value means always make a separate frame
(customize-set-variable 'pop-up-frames nil)

;; binds (global)
(global-set-key (kbd "s-l") 'shrink-window-horizontally)
(global-set-key (kbd "s-h") 'enlarge-window-horizontally)
(global-set-key (kbd "s-j") 'shrink-window)
(global-set-key (kbd "s-k") 'enlarge-window)

;; next and previous buffer (on current window)
(define-key ctl-x-map (kbd "C-,") 'previous-buffer)
(define-key ctl-x-map (kbd "C-.") 'next-buffer)

;; binds (vlm-window prefix map)
(define-key vlm-window-map (kbd "+") 'maximize-window)
(define-key vlm-window-map (kbd "-") 'minimize-window)
(define-key vlm-window-map (kbd "w") 'balance-windows)
(define-key vlm-window-map (kbd "o") 'other-window-prefix)

;; binds ctl-x-map (C-x w)
(define-key ctl-x-map (kbd "w") 'vlm-window-map)

;; switch to buffer
(define-key ctl-x-map (kbd "C-b") 'switch-to-buffer)

;; kill buffer and window
(define-key ctl-x-map (kbd "C-k") 'kill-buffer-and-window)

;; other window (redundancy)
;;(define-key ctl-x-map (kbd "C-o") 'other-window)

;; switch to the last buffer in the buffer list
(define-key ctl-x-map (kbd "C-u") 'unbury-buffer)



;; (require 'windmove nil t)

;; window move default keybinds (shift-up/down etc..)
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'windmove-default-keybindings)))

;; (require 'page nil t)

;; enable narrow functions
(add-hook 'window-setup-hook
          (lambda ()
            (put 'narrow-to-page 'disabled nil)
            (put 'narrow-to-region 'disabled nil)))

;; non-nil means do not display continuation lines
(customize-set-variable 'truncate-lines nil)

;; column beyond which automatic line-wrapping should happen
(customize-set-variable 'fill-column 80)

;; sentences should be separated by a single space
(customize-set-variable 'sentence-end-double-space nil)

;; list of functions called with no args to query before killing a buffer
(customize-set-variable 'kill-buffer-query-functions nil)

;; non-nil means load prefers the newest version of a file
(customize-set-variable 'load-prefer-newer t)

;; enable erase-buffer
(add-hook 'window-setup-hook
          (lambda ()
            (put 'erase-buffer 'disabled nil)))

;; (require 'hl-line nil t)

;; enable highlight line
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'global-hl-line-mode 1)))

;; (require 'linum nil t)

;; format used to display line numbers
(customize-set-variable 'linum-format " %2d ")

;; (add-hook 'prog-mode-hook 'linum-mode)

;; (require 'display-line-numbers nil t)

;; if non-nil, do not shrink line number width
(customize-set-variable 'display-line-numbers-grow-only t)

;; if non-nil, count number of lines to use for line number width
(customize-set-variable 'display-line-numbers-width-start t)

;; if an integer N > 0, highlight line number of every Nth line
(customize-set-variable 'display-line-numbers-major-tick 0)

;; if an integer N > 0, highlight line number of every Nth line
(customize-set-variable 'display-line-numbers-minor-tick 0)

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; (safe-funcall 'global-display-line-numbers-mode 1)

(add-hook 'prog-mode-hook
          (lambda ()
            (display-fill-column-indicator-mode 1)))

;; non-nil means to make the cursor very visible
(customize-set-variable 'visible-cursor t)

;; coding system to use with system messages
(customize-set-variable 'locale-coding-system 'utf-8)

;; coding system to be used for encoding the buffer contents on saving
(customize-set-variable 'buffer-file-coding-system 'utf-8)

;; add coding-system at the front of the priority list for automatic detection
(prefer-coding-system 'utf-8)

;; set coding system (UFT8)
(set-language-environment "UTF-8")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; (require 'chistory nil t)

;; maximum length of history lists before truncation takes place
(customize-set-variable 'history-length 1024)

;;list history of commands that used the minibuffer
(customize-set-variable 'list-command-history-max history-length)

;; (require 'minibuffer nil t)

;; non-nil means to allow minibuffer commands while in the minibuffer
(customize-set-variable 'enable-recursive-minibuffers nil)

;; if non-nil, `read-answer' accepts single-character answers
(customize-set-variable 'read-answer-short t)

;; non-nil means completion ignores case when reading a buffer name
(customize-set-variable 'read-buffer-completion-ignore-case t)

;; non-nil means when reading a file name completion ignores case
(customize-set-variable 'read-file-name-completion-ignore-case nil)

;; number of completion candidates below which cycling is used
(customize-set-variable 'completion-cycle-threshold nil)

;; treat the SPC or - inserted by `minibuffer-complete-word as delimiters
(customize-set-variable 'completion-pcm-complete-word-inserts-delimiters t)

;; a string of characters treated as word delimiters for completion
(customize-set-variable 'completion-pcm-word-delimiters "-_./:| ")

;; if non-nil, print helpful inline messages during completion
(customize-set-variable 'completion-show-inline-help nil)

;; non-nil means automatically provide help for invalid completion input
(customize-set-variable 'completion-auto-help t)

;; non-nil means don’t consider case significant in completion
(customize-set-variable 'completion-ignore-case t)

;; non-nil means flex completion rejects spaces in search pattern
(customize-set-variable 'completion-flex-nospace t)

;; list of completion styles to use: see `completion-styles-alist variable
(customize-set-variable 'completion-styles '(basic
                                             initials
                                             partial-completion
                                             flex))

;; list of category-specific user overrides for completion styles
(customize-set-variable 'completion-category-overrides
                        '((file (flex basic initials))
                          (buffer (flex basic initials))))
;; (info-menu (styles basic))))

;; define the appearance and sorting of completions
(customize-set-variable 'completions-format 'vertical)

;; how to resize mini-windows (the minibuffer and the echo area)
(customize-set-variable 'resize-mini-windows nil)

;; format string used to output "default" values
(customize-set-variable 'minibuffer-default-prompt-format " (default: %s)")

;; if non-nil, shorten "(default ...)" to "[...]" in minibuffer prompts
(customize-set-variable 'minibuffer-eldef-shorten-default t)

;; non-nil means entering the minibuffer raises the minibuffer's frame
(customize-set-variable 'minibuffer-auto-raise t)

;; non-nil means to delete duplicates in history
(customize-set-variable 'history-delete-duplicates t)

;; any other value means the minibuffer will move onto another frame, but
;; only when the user starts using a minibuffer there
(customize-set-variable 'minibuffer-follows-selected-frame 1)

;; special hook to find the completion table for the entity at point (default)
(customize-set-variable 'completion-at-point-functions
                        `(elisp-completion-at-point
                          tags-completion-at-point-function t))

;; defer garbage collection
;; set `gc-cons-threshold' to most-positive-fixnum
;; the largest lisp integer value representation
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (setq gc-cons-threshold most-positive-fixnum)))

;; reset threshold to inital value (16 megabytes)
(add-hook 'minibuffer-exit-hook
          (lambda () (run-at-time 1 nil
                                  (lambda ()
                                    (setq gc-cons-threshold 16777216)))))

;; minibuffer-local-map
(define-key minibuffer-local-map (kbd "M-`") 'minibuffer-completion-help)
(define-key minibuffer-local-map (kbd "M-w") 'minibuffer-complete-word)
(define-key minibuffer-local-map (kbd "<tab>") 'minibuffer-complete)

;; global
(global-set-key (kbd "<C-delete>") 'quit-minibuffer)

;; if `file-name-shadow-mode' is active, any part of the
;; minibuffer text that would be ignored because of this is given the
;; properties in `file-name-shadow-properties', which may
;; be used to make the ignored text invisible, dim, etc.
(add-hook 'window-setup-hook
          (lambda()
            (funcall 'file-name-shadow-mode 0)))

;; when active, any recursive use of the minibuffer will show
;; the recursion depth in the minibuffer prompt, this is only
;; useful if `enable-recursive-minibuffers' is non-nil
(add-hook 'window-setup-hook
          (lambda()
            (funcall 'minibuffer-depth-indicate-mode 0)))

;; when active, minibuffer prompts that show a default value only show
;; the default when it's applicable
(add-hook 'window-setup-hook
          (lambda()
            (funcall 'minibuffer-electric-default-mode 1)))

;; (require 'savehist nil t)

;; file name where minibuffer history is saved to and loaded from.
(customize-set-variable
 'savehist-file (concat user-emacs-directory "cache/history"))

;; if non-nil, save all recorded minibuffer histories.
(customize-set-variable 'savehist-save-minibuffer-history t)

;; enable savehist mode
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'savehist-mode 1)))

;; (require 'completion nil t)

;; custom
;; how far to search in the buffer when looking for completions,
;; if nil, search the whole buffer
(customize-set-variable 'completion-search-distance 12000)

;; if non-nil, the next completion prompt does a cdabbrev search
(customize-set-variable 'completion-cdabbrev-prompt-flag nil)

;; non-nil means show help message in *Completions* buffer
(customize-set-variable 'completion-show-help nil)

;; minimum output speed at which to display next potential completion
(customize-set-variable 'completion-prompt-speed-threshold 2400)

;; non-nil means separator characters mark previous word as used
(customize-set-variable 'completion-on-separator-character t)

;; the filename to save completions to.
(customize-set-variable
 'save-completions-file-name
 (expand-file-name "cache/completitions" user-emacs-directory))

;; non-nil means save most-used completions when exiting emacs
(customize-set-variable 'save-completions-flag t)

;; discard a completion if unused for this many hours.
;; (1 day = 24, 1 week = 168)
;; if this is 0, non-permanent completions
;; will not be saved unless these are used
(customize-set-variable 'save-completions-retention-time 168)

(add-to-list 'display-buffer-alist
             '("\\*completions\\*"
               (display-buffer-below-selected display-buffer-at-bottom)
               (window-height . fit-window-to-buffer)))

;; completion-list-mode-map
(define-key completion-list-mode-map (kbd "q") 'delete-completion-window)
(define-key completion-list-mode-map (kbd "d") 'delete-completion-line)
(define-key completion-list-mode-map (kbd "w") 'kill-ring-save)
(define-key completion-list-mode-map (kbd "RET") 'choose-completion)
(define-key completion-list-mode-map (kbd "TAB") 'next-completion)
(define-key completion-list-mode-map (kbd "DEL") 'previous-completion)
(define-key completion-list-mode-map (kbd "C-j") 'choose-completion)
(define-key completion-list-mode-map (kbd "C-g") 'quit-minibuffer)

;; enable dynamic completion mode
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'dynamic-completion-mode 1)))

;; (require 'icomplete nil t)

;; custom
;; pending-completions number over which to apply `icomplete-compute-delay
(customize-set-variable 'icomplete-delay-completions-threshold 512)

;; maximum number of initial chars to apply `icomplete-compute-delay
(customize-set-variable 'icomplete-max-delay-chars 2)

;; completions-computation stall, used only with large-number completions
(customize-set-variable 'icomplete-compute-delay 0)

;; when non-nil, show completions when first prompting for input
(customize-set-variable 'icomplete-show-matches-on-no-input t)

;; if non-nil, automatically delete superfluous parts of file names
(customize-set-variable 'icomplete-tidy-shadowed-file-names t)

;; when non-nil, hide common prefix from completion candidates
(customize-set-variable 'icomplete-hide-common-prefix nil)

;; maximum number of lines to use in the minibuffer
(customize-set-variable 'icomplete-prospects-height 1)

;; string used by Icomplete to separate alternatives in the minibuffer
;; (customize-set-variable 'icomplete-separator (propertize " • " 'face 'shadow))
;; (customize-set-variable 'icomplete-separator (propertize " · " 'face 'shadow))
(customize-set-variable 'icomplete-separator (propertize " | " 'face 'shadow))

;; specialized completion tables with which `icomplete' should operate,
;; if this is t, `icomplete operates on all tables
(customize-set-variable 'icomplete-with-completion-tables t)

;; if non-nil, also use icomplete when completing in non-mini buffers
(customize-set-variable 'icomplete-in-buffer nil)

(eval-after-load 'icomplete
  (lambda ()
    (when (boundp 'icomplete-minibuffer-map)
      ;; unbind
      (define-key icomplete-minibuffer-map (kbd "SPC") nil)
      ;; bind
      (define-key icomplete-minibuffer-map (kbd "C-j") 'icomplete-force-complete-and-exit)
      (define-key icomplete-minibuffer-map (kbd "RET") 'exit-minibuffer)
      (define-key icomplete-minibuffer-map (kbd "<tab>") 'minibuffer-complete)
      (define-key icomplete-minibuffer-map (kbd "C-n") 'icomplete-forward-completions)
      (define-key icomplete-minibuffer-map (kbd "C-p") 'icomplete-backward-completions)
      (define-key icomplete-minibuffer-map (kbd "DEL") 'icomplete-fido-backward-updir)
      (define-key icomplete-minibuffer-map (kbd "M-p") 'previous-line-or-history-element)
      (define-key icomplete-minibuffer-map (kbd "M-n") 'next-line-or-history-element)
      (define-key icomplete-minibuffer-map (kbd "M-i") 'minibuffer-insert-completion-in-buffer)
      (define-key icomplete-minibuffer-map (kbd "M-y") 'minibuffer-insert-completion-at-point)
      (define-key icomplete-minibuffer-map (kbd "M-k") 'minibuffer-kill-current-completion)
      (define-key icomplete-minibuffer-map (kbd "M-h") 'minibuffer-describe-current-completion))))

;; enable globally
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'icomplete-mode 1)))

;; (require 'tab-bar nil t)

;; defines where to show the close tab button
(customize-set-variable 'tab-bar-close-button-show nil)

;; if non-nil, show the "New tab" button in the tab bar
(customize-set-variable 'tab-bar-new-button-show nil)

;; string that delimits tabs
(customize-set-variable 'tab-bar-separator " ")

;; if the value is ‘1’, then hide the tab bar when it has only one tab-bar-show
;; if t, enable `tab-bar-mode' automatically on using the commands that
;; create new window configurations
(customize-set-variable 'tab-bar-show nil)

;; if 'rightmost', create as the last tab
(customize-set-variable 'tab-bar-new-tab-to "rightmost")

;; if 'recent', select the most recently visited tab
(customize-set-variable 'tab-bar-close-tab-select "recent")

;; list of modifier keys for selecting a tab by its index digit (testing)
;; (customize-set-variable 'tab-bar-select-tab-modifiers '("super"))

;; show absolute numbers on tabs in the tab bar before the tab name
;; (customize-set-variable 'tab-bar-tab-hints nil)

(define-key vlm-tabs-map (kbd "t") 'tab-switcher)
(define-key vlm-tabs-map (kbd "n") 'tab-bar-new-tab)
(define-key vlm-tabs-map (kbd "r") 'tab-bar-rename-tab)

(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'tab-bar-mode 1)))

;; (require 'tool-bar nil t)

(add-hook 'window-setup-hook
          (lambda ()
            (safe-funcall 'tool-bar-mode 0)))

;; (require 'tooltip nil t)

;; seconds to wait before displaying a tooltip the first time.
(customize-set-variable 'tooltip-delay 0.2)

;; use the echo area instead of tooltip frames for help and GUD tooltips
(customize-set-variable 'tooltip-use-echo-area t)

;; (require 'menu-bar nil t)



(define-key vlm-utils-map (kbd "o") 'menu-bar-open)

(add-hook 'window-setup-hook
          (lambda ()
            (safe-funcall 'menu-bar-mode 0)))

;; (require 'scroll-bar nil t)

;; disable scroll bar
(add-hook 'window-setup-hook
          (lambda ()
            (safe-funcall 'scroll-bar-mode 0)))

;; (require 'fringe nil t)

;; custom
;; 0 -> ("no-fringes" . 0), remove ugly icons to represet new lines
;; ascii is more than enough to represent this information
;; default appearance of fringes on all frame
(customize-set-variable 'fringe-mode 0)

;; remove underline
(customize-set-variable 'x-underline-at-descent-line t)

;; mode-line format
(customize-set-variable 'mode-line-format
            '(" "
              "λ"
              " "
              "»"
              " "
              (:eval (format-time-string " %H:%M"))
              " "
              "¦"
              ;; "
              ;; mode-line-front-space
              " "
              mode-line-modified
              mode-line-remote
              ;; (:eval (when (display-graphic-p)
              ;;          (format "  %d/%d"
              ;;                  exwm-workspace-current-index
              ;;                  (exwm-workspace--count))))
              " "
              "¦"
              " "
              "%l'%c"
              " "
              "·"
              " "
              (:eval (propertized-buffer-identification "(%b)"))
              " "
              "·"
              " "
              "("
              (:eval (upcase (replace-regexp-in-string "-mode" "" (symbol-name major-mode))))
              ")"
              (:eval (when vc-mode (concat " » " (projectile-project-name) " »")))
              (vc-mode vc-mode)))

;; set wallpaper
;; (add-hook 'window-setup-hook
;;           (lambda()
;;             (set-wallpaper
;;              "~/media/images/wallpapers/studio-ghibli/ghibli-7.jpg"
;;              "-g -0-0")))

(setq visible-bell nil
      ring-bell-function '(lambda ()
                            (invert-face 'mode-line)
                            (run-with-timer 0.01 nil #'invert-face 'mode-line)))

;; indentation can insert tabs if this is non-nil
(customize-set-variable 'indent-tabs-mode nil)

;; default number of columns for margin-changing functions to indent
(customize-set-variable 'standard-indent 4)

;; distance between tab stops (for display of tab characters), in columns.
(customize-set-variable 'tab-width 4)

;; if 'complete, TAB first tries to indent the current line
;; if t, hitting TAB always just indents the current line
;; If nil, hitting TAB indents the current line if point is at the left margin
;; or in the line's indentation
(customize-set-variable 'tab-always-indent 'complete)

;; (require 'kmacro nil t)

(define-key ctl-x-map (kbd "m") 'kmacro-keymap)

;; (require 'elec-pair nil t)

;; alist of pairs that should be used regardless of major mode.
(customize-set-variable 'electric-pair-pairs
                        '((?\{ . ?\})
                          (?\( . ?\))
                          (?\[ . ?\])
                          (?\" . ?\")))

(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'electric-pair-mode 1)))

;; (require 'newcomment nil t)

;; global-map
(global-set-key (kbd "M-c") 'comment-line)

;; (require 'face-remap nil t)

;; ctl-x-map (C-x)
(define-key ctl-x-map (kbd "=") 'text-scale-adjust)

;; (require 'delsel nil t)

;; delete selection-mode
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'delete-selection-mode 1)))

;; (require 'replace nil t)

;;(global-set-key (kbd "M-s M-o") 'list-occurrences-at-point)

;; (require 'rect nil t)

;; global map
(global-set-key (kbd "C-x r %") 'replace-rectangle)

;; (require 'whitespace nil t)

;; specify which kind of blank is visualized
;; empty was removed
(customize-set-variable
 'whitespace-style
 '(face
   tabs spaces trailing lines
   space-before-tab newline indentation
   space-after-tab space-mark tab-mark
   newline-mark missing-newline-at-eof))

;; clean whitespace and newlines before buffer save
(add-hook 'before-save-hook #'whitespace-cleanup)

;; binds
(define-key ctl-x-map (kbd ".") 'whitespace-mode)

;; (require 'help nil t)

;; always select the help window
(customize-set-variable 'help-window-select nil)

;; maximum height of a window displaying a temporary buffer.
(customize-set-variable 'temp-buffer-max-height
                        (lambda (buffer)
                          (if (and (display-graphic-p) (eq (selected-window) (frame-root-window)))
                              (/ (x-display-pixel-height) (frame-char-height) 4)
                            (/ (frame-height) 4))))

;; the minimum total height, in lines, of any window
(customize-set-variable 'window-min-height 4)



(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'temp-buffer-resize-mode 1)))

;; (require 'help-fns nil t)

;; (require 'help-mode nil t)

(eval-after-load 'help-mode
  (lambda ()
    (when (boundp 'help-mode-map)
      (define-key help-mode-map (kbd "C-j") 'push-button))))

;; help prefix map (C-h) (redundancy)
(define-key help-map (kbd "C-f") 'describe-function)
(define-key help-map (kbd "C-v") 'describe-variable)
(define-key help-map (kbd "C-k") 'describe-key)
(define-key help-map (kbd "C-m") 'describe-mode)
(define-key help-map (kbd "C-o") 'describe-symbol)
(define-key help-map (kbd "C-e") 'view-echo-area-messages)

;; (require 'info nil t)

;; non-nil means don’t record intermediate Info nodes to the history
(customize-set-variable 'Info-history-skip-intermediate-nodes nil)

;; list of additional directories to search for (not working)
;; (customize-set-variable 'Info-additional-directory-list
;;                         `(,(expand-file-name "info/" user-emacs-directory)))

;; list of directories to search for Info documentation files (works!)
(customize-set-variable 'Info-directory-list
                        `("/usr/local/share/emacs/info/"
                          "/usr/local/share/info/"
                          ,(expand-file-name "info/" user-emacs-directory)))

;; 0 -> means do not display breadcrumbs
(customize-set-variable 'info-breadcrumbs-depth 0)

;; help-map
(define-key help-map (kbd "TAB") 'info-display-manual)

;; info-mode-map
(eval-after-load 'info
  (lambda ()
    (when (boundp 'Info-mode-map)
      (define-key Info-mode-map (kbd "C-j") 'Info-follow-nearest-node))))

;; (require 'eldoc nil t)

;; number of seconds of idle time to wait before printing.
(customize-set-variable 'eldoc-idle-delay 0.1)

;; if value is any non-nil value other than t, symbol name may be truncated
;; if it will enable the function arglist or documentation string to fit on a
;; single line without resizing window
(customize-set-variable 'eldoc-echo-area-use-multiline-p t)

;; enable eldoc globally
(add-hook 'window-setup-hook
          (lambda()
            (funcall 'eldoc-mode 1)))

;; (require 'bookmark nil t)

;; custom
;; file in which to save bookmarks by default.
(customize-set-variable
 'bookmark-default-file (concat user-emacs-directory "cache/bookmarks"))

;; generated by `update-directory-autolods'
(require 'lisp-loaddefs nil t)

;; (require 'comp nil t)

;; non-nil means unconditionally (re-)compile all files
(customize-set-variable 'native-comp-always-compile t)

;; default number of subprocesses used for async native compilation
;; value of zero means to use half the number of the CPU's execution units
(customize-set-variable 'native-comp-async-jobs-number 0)

;; emit a warning if a byte-code file being loaded has no corresponding source
(customize-set-variable 'native-comp-warning-on-missing-source t)



(defmacro safe-load-file (file)
  "Load FILE if exists."
  `(if (not (file-exists-p ,file))
       (message "File not found")
     (load (expand-file-name ,file) t nil nil)))

(defmacro safe-add-dirs-to-load-path (dirs)
  "Add DIRS (directories) to `load-path'."
  `(dolist (dir ,dirs)
     (setq dir (expand-file-name dir))
     (when (file-directory-p dir)
       (unless (member dir load-path)
         (push dir load-path)))))

(defmacro safe-funcall (func &rest args)
  "Call FUNC with ARGS, if it's bounded."
  `(when (fboundp ,func)
     (funcall ,func ,@args)))

(defmacro safe-mkdir (dir)
  "Create DIR in the file system."
  `(when (and (not (file-exists-p ,dir))
              (make-directory ,dir :parents))))

;; (require 'simple nil t)

;; don't omit information when lists nest too deep
(customize-set-variable 'eval-expression-print-level 4)

;; your preference for a mail composition package
(customize-set-variable 'mail-user-agent 'message-user-agent)

;; what to do when the output buffer is used by another shell command
(customize-set-variable 'async-shell-command-buffer 'rename-buffer)

;; column number display in the mode line
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'column-number-mode 1)))

;; buffer size display in the mode line
(add-hook 'window-setup-hook
          (lambda ()
            (funcall 'size-indication-mode 1)))

;; (require 'tramp nil t)

;; set tramp default method for file transfer
;; (customize-set-variable 'tramp-default-method "ssh")

;; if non-nil, chunksize for sending input to local process.
;; (customize-set-variable 'tramp-chunksize 64)

;; a value of t would require an immediate reread during filename completion,
;; nil means to use always cached values for the directory contents.
(customize-set-variable 'tramp-completion-reread-directory-timeout nil)

;; set tramp verbose level
(customize-set-variable 'tramp-verbose 4)

;; file which keeps connection history for tramp connections.
(customize-set-variable
 'tramp-persistency-file-name
 (concat (expand-file-name user-emacs-directory) "cache/tramp"))

;; when invoking a shell, override the HISTFILE with this value
(customize-set-variable
 'tramp-histfile-override "~/.tramp_history")

;; connection timeout in seconds
(customize-set-variable 'tramp-connection-timeout 10)

;; (require 'nsm nil t)

;; if a potential problem with the security of the network
;; connection is found, the user is asked to give input
;; into how the connection should be handled
;; `high': This warns about additional things that many
;; people would not find useful.
;; `paranoid': On this level, the user is queried for
;; most new connections
(customize-set-variable 'network-security-level 'high)

;; the file the security manager settings will be stored in.
(customize-set-variable 'nsm-settings-file
                        (expand-file-name "nsm/netword-security.data" user-emacs-directory))

;; (require 'eps-config nil t)

;; the gpg executable
(customize-set-variable 'epg-gpg-program "gpg")

;; (require 'gnutls nil t)

;; if non-nil, this should be a TLS priority string
(customize-set-variable 'gnutls-algorithm-priority nil)

;; if non-nil, this should be t or a list of checks
;; per hostname regex
(customize-set-variable 'gnutls-verify-error nil)

;; (require 'epa nil t)

;; if non-nil, cache passphrase for symmetric encryption
(customize-set-variable
 'epa-file-cache-passphrase-for-symmetric-encryption t)

;; if t, always asks user to select recipients
(customize-set-variable 'epa-file-select-keys t)

;; in epa commands, a particularly useful mode is ‘loopback’, which
;; redirects all Pinentry queries to the caller, so Emacs can query
;; passphrase through the minibuffer, instead of external Pinentry
;; program
(customize-set-variable 'epa-pinentry-mode 'loopback)

;; (add-hook 'window-setup-hook
;;           (lambda ()
;;             (funcall 'epa-file-enable)))

;; (require 'async nil t)

;; to run command without displaying the output in a window
(add-to-list 'display-buffer-alist
             '("\\*Async Shell Command\\*"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; (require 'mm-bodies nil t)

(eval-after-load 'mm-bodies
  (lambda ()
    (when (boundp 'mm-body-charset-encoding-alist)
      (add-to-list 'mm-body-charset-encoding-alist '(utf-8 . base64)))))

;; (require 'shr nil t)

;; frame width to use for rendering
(customize-set-variable 'shr-width 80)

;; if non-nil, use proportional fonts for text
(customize-set-variable 'shr-use-fonts nil)

;; if non-nil, respect color specifications in the HTML
(customize-set-variable 'shr-use-colors t)

;; if non-nil, inhibit loading images
(customize-set-variable 'shr-inhibit-images t)

;; images that have URLs matching this regexp will be blocked (regexp)
(customize-set-variable 'shr-blocked-images nil)

;; (require 'custom nil t)

;; file used for storing customization information.
;; The default is nil, which means to use your init file
;; as specified by ‘user-init-file’.  If the value is not nil,
;; it should be an absolute file name.
(customize-set-variable
 'custom-file (concat (expand-file-name user-emacs-directory) "custom.el"))

;; (require 'lazy-load nil t)

;; non-nil means starts to monitor the directories
(customize-set-variable 'lazy-load-enable-filenotify-flag t)

;; non-nil means show debug messages
(customize-set-variable 'lazy-load-debug-messages-flag t)

;; non-nil means run `lazy-load-update-autoloads' when emacs is idle
(customize-set-variable 'lazy-load-enable-run-idle-flag nil)

;; idle timer value
(customize-set-variable 'lazy-load-idle-seconds 30)

;; interval in seconds, used to trigger the timer callback
(customize-set-variable 'lazy-load-timer-interval 15)

;; target files and directories
(customize-set-variable 'lazy-load-files-alist
                        (list
                         ;; lisp directory
                         (cons "lisp-loaddefs.el" (expand-file-name "lisp/" user-emacs-directory))
                         ;; site-lisp directory
                         (cons "site-lisp-loaddefs.el"
                               (expand-file-name "site-lisp/" user-emacs-directory))))

;; (add-hook 'window-setup-hook
;;           (lambda ()
;;             (funcall 'turn-on-lazy-load-mode)))

;; generated by `update-directory-autoloads'
(require 'lisp-loaddefs nil t)
(require 'site-lisp-loaddefs nil t)

;; (require 'exwm nil t)

(defvar eos-xrandr-right-screen "eDP1"
  "Defines the screen located at right side")

(defvar eos-xrandr-left-screen "HDMI1"
  "Defines the screen located at right side")

(defvar eos-xrandr-command
  (format "xrandr --output %s --right-of %s"
          eos-xrandr-right-screen
          eos-xrandr-left-screen)
  "Defines the screen located at right side")

;; monitors: check the xrandr(1) output and use the same name/order
;; TODO: create a func that retrieves these values from xrandr

(customize-set-variable
 'exwm-randr-workspace-monitor-plist '(0 "eDP1"
                                         1 "HDMI1"
                                         2 "HDMI1"))

(customize-set-variable 'exwm-workspace-number
                        (if (boundp 'exwm-randr-workspace-monitor-plist)
                            (/ (safe-length exwm-randr-workspace-monitor-plist) 2)
                          1))

;; set exwm workspaces number
(customize-set-variable 'exwm-workspace-number 2)

;; show workspaces in all buffers
(customize-set-variable 'exwm-workspace-show-all-buffers nil)

;; non-nil to allow switching to buffers on other workspaces
(customize-set-variable 'exwm-layout-show-all-buffers nil)

;; non-nil to force managing all X windows in tiling layout.
(customize-set-variable 'exwm-manage-force-tiling t)

;; exwn global keybindings
(customize-set-variable 'exwm-input-global-keys
                        `(([?\s-r] . exwm-reset)
                          ([?\s-q] . exwm-input-toggle-keyboard)
                          ([?\s-d] . exwm-floating-toggle-floating)
                          ([?\s-m] . exwm-layout-toggle-fullscreen)

                          ;; create and switch to workspaces
                          ,@(mapcar (lambda (i)
                                      `(,(kbd (format "s-%d" i)) .
                                        (lambda ()
                                          (interactive)
                                          (exwm-workspace-switch-create ,i))))
                                    (number-sequence 0 2))))

;; The following example demonstrates how to use simulation keys to mimic
;; the behavior of Emacs.  The value of `exwm-input-simulation-keys` is a
;; list of cons cells (SRC . DEST), where SRC is the key sequence you press
;; and DEST is what EXWM actually sends to application.  Note that both SRC
;; and DEST should be key sequences (vector or string).
(customize-set-variable 'exwm-input-simulation-keys
                        '(
                          ;; movement
                          ([?\C-p] . [up])
                          ([?\C-b] . [left])
                          ([?\C-f] . [right])
                          ([?\C-n] . [down])
                          ([?\M-b] . [C-left])
                          ([?\M-f] . [C-right])
                          ([?\C-e] . [end])
                          ([?\C-v] . [next])
                          ([?\C-a] . [home])
                          ([?\M-v] . [prior])
                          ([?\C-d] . [delete])
                          ([?\C-k] . [S-end delete])

                          ;; browser temporary
                          ([?\C-o] . [C-prior]) ; change tab mapping
                          ([?\C-k] . [C-w]) ; close tab mapping
                          ([?\C-j] . [return]) ; close tab mapping

                          ;; cut/paste.
                          ([?\C-w] . [?\C-x])
                          ([?\M-w] . [?\C-c])
                          ([?\C-y] . [?\C-v])

                          ;; Escape (cancel)
                          ([?\C-g] . [escape])

                          ;; search
                          ([?\C-s] . [?\C-f])))

;; this little bit will make sure that XF86 keys work in exwm buffers as well
(if (boundp 'exwm-input-prefix-keys)
    (progn
      (dolist (key '(XF86AudioLowerVolume
                     XF86AudioRaiseVolume
                     XF86PowerOff
                     XF86AudioMute
                     XF86AudioPlay
                     XF86AudioStop
                     XF86AudioPrev
                     XF86AudioNext
                     XF86ScreenSaver
                     XF68Back
                     XF86Forward
                     Scroll_Lock
                     print))
        (cl-pushnew key exwm-input-prefix-keys))))

;; All buffers created in EXWM mode are named "*EXWM*". You may want to
;; change it in `exwm-update-class-hook' and `exwm-update-title-hook', which
;; are run when a new X window class name or title is available.  Here's
;; some advice on this topic:
;; + Always use `exwm-workspace-rename-buffer` to avoid naming conflict.
;; + For applications with multiple windows (e.g. GIMP), the class names of
;; all windows are probably the same.  Using window titles for them makes
;; more sense.

;; update the buffer name by X11 window title
(add-hook 'exwm-update-title-hook
          (lambda ()
            (when (and (fboundp 'exwm-workspace-rename-buffer)
                       (boundp 'exwm-class-name)
                       (boundp 'exwm-title))
              (exwm-workspace-rename-buffer
               (truncate-string-to-width
                (concat exwm-class-name "|" exwm-title) 32)))))

(add-hook 'exwm-randr-screen-change-hook
          (lambda ()
            (start-process-shell-command
             "randr" nil eos-xrandr-command)))

;; enable exwm if graphic display is non-nil
(when (and (display-graphic-p)
           (require 'exwm nil t)
           (require 'exwm-randr nil t))
  (progn
    (exwm-enable)
    (exwm-randr-enable)))

;; (require 'exwm-edit nil t)

(when (display-graphic-p)
    (exwm-input-set-key (kbd "C-c '") #'exwm-edit--compose)
    (exwm-input-set-key (kbd "C-c C-'") #'exwm-edit--compose))
