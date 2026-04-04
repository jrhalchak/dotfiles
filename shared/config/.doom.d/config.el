;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-tokyo-night)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/org/")
(setq org-directory "~/vault/org")

(after! org
  (setq org-hide-emphasis-markers t)
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :height 1.4)
    '(org-level-2 :inherit outline-2 :height 1.3)
    '(org-level-3 :inherit outline-3 :height 1.2)
    '(org-level-4 :inherit outline-4 :height 1.1)
    '(org-level-5 :inherit outline-5 :height 1.0))
  ;; Unbind C-j/C-k from org-mode-map so global C-j/C-k window movement works,
  ;; and remap heading navigation to C-S-j/C-S-k instead.
  (map! :map org-mode-map
        :n "C-j" nil
        :n "C-k" nil
        :n "C-S-j" #'org-forward-heading-same-level
        :n "C-S-k" #'org-backward-heading-same-level))

(after! org-appear
  (setq org-appear-trigger 'always)
  (add-hook 'org-mode-hook #'org-appear-mode))

(after! org-fragtog
  (add-hook 'org-mode-hook #'org-fragtog-mode))

(after! org
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.3))
  ;; Use dvisvgm for crisp SVG output instead of PNG
  (setq org-latex-preview-process-default 'dvisvgm))

;; Ligatures are enabled globally via the `ligatures' module in init.el.
;; Doom only configures ligatures for prog-mode by default, so we copy the
;; full set to `t' (all modes) here.
(after! ligature
  (ligature-set-ligatures t '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***"
                               "||=" "||>" ":::" "::=" "=:=" "===" "==>" "=!="
                               "=>>" "=<<" "=/=" "!==" "!!." ">=>" ">>=" ">>>"
                               ">>-" ">->" "->>" "-->" "---" "-<<" "<~~" "<~>"
                               "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                               "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###"
                               "#_(" "..<" "..." "+++" "/==" "///" "_|_" "www"
                               "&&" "^=" "~~" "~@" "~=" "~>" "~-" "**" "*>"
                               "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|" "[|"
                               "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!="
                               "!!" ">:" ">=" ">>" ">-" "-~" "-|" "->" "--"
                               "-<" "<~" "<*" "<|" "<:" "<$" "<=" "<>" "<-"
                               "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!" "##"
                               "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>"
                               "++" "?:" "?=" "?." "??" ";;" "/*" "/=" "/>"
                               "//" "__" "~~" "(*" "*)" "\\\\" "://")))

;; To restrict ligatures to specific modes instead, replace the above with:
;;
;; (after! ligature
;;   (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####"
;;                                        "~~>" "***" "||=" "||>" ":::" "::="
;;                                        "=:=" "===" "==>" "=!=" "=>>" "=<<"
;;                                        "=/=" "!==" "!!." ">=>" ">>=" ">>>"
;;                                        ">>-" ">->" "->>" "-->" "---" "-<<"
;;                                        "<~~" "<~>" "<*>" "<||" "<|>" "<$>"
;;                                        "<==" "<=>" "<=<" "<->" "<--" "<-<"
;;                                        "<<=" "<<-" "<<<" "<+>" "</>" "###"
;;                                        "#_(" "..<" "..." "+++" "/==" "///"
;;                                        "_|_" "&&" "^=" "~~" "~=" "~>" "->"
;;                                        "=>" "!=" ">=" "<=" "//" "/*" "*/")))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Make Ctrl+h/j/k/l move between windows (splits) like Vim/Tmux
(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right
      ;; Restore visual-mode s to delete selection and enter insert (evil-substitute),
      ;; since Doom remaps s to evil-snipe in normal mode.
      :v "s" #'evil-substitute)

;; No titlebar - doesn't work with Aerospace
;;(add-to-list 'default-frame-alist '(undecorated . t))

;; Keep WM-manageable frame, but make the titlebar visually minimal
(setq frame-title-format nil)                 ; already have

;; Translucent background setup
;; - macOS: use NS frame params + face stippling for the blur-like effect
;; - Linux: only set alpha; compositor (e.g. picom) can handle blur
(defconst jrh/is-mac (eq system-type 'darwin))

(when jrh/is-mac
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))) ; or light

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq doom-font (font-spec :family "VictorMono Nerd Font Mono" :size 14))
(setq doom-variable-pitch-font (font-spec :family "VictorMono Nerd Font Mono"))

(defun jrh/apply-frame-transparency (&optional frame)
  "Apply frame transparency for GUI frames."
  (let ((f (or frame (selected-frame))))
    (when (display-graphic-p f)
      ;; Works on X11/Cocoa; ignored where unsupported.
      (ignore-errors (set-frame-parameter f 'alpha '(97 . 97)))
      ;; PGTK/Wayland builds may prefer this.
      (ignore-errors (set-frame-parameter f 'alpha-background 97)))))

;; (set-face-background 'default "mac:windowBackgroundColor")
(set-face-background 'default (face-background 'default))
(set-face-stipple 'default "alpha:10%") ; tweak 10–60%

; specify .org files:
; (after! org
;   (setq org-agenda-files
;         '("~/vault/org/agenda.org"
;           "~/vault/org/inbox.org"
;           "~/vault/org/todo.org"
;           "~/vault/org/areas/day-job.org"
;           "~/vault/org/areas/finances.org"
;           "~/vault/org/areas/learning.org"
;           "~/vault/org/areas/life.org"
;           "~/vault/org/areas/work.org")))

; recursively include all .org files:
(after! org
  (setq org-agenda-files
        (directory-files-recursively "~/vault/org" "\\.org$")))

(add-to-list 'default-frame-alist '(alpha . (97 . 97)))
(add-to-list 'default-frame-alist '(alpha-background . 97))
(add-hook 'window-setup-hook #'jrh/apply-frame-transparency)
(add-hook 'after-make-frame-functions #'jrh/apply-frame-transparency)

(when jrh/is-mac
  (defun jrh/macos-background-stipple ()
    "Use macOS-only stippling for translucent/blurred background."
    (when (display-graphic-p)
      (ignore-errors (set-face-stipple 'default "alpha:10%"))))
  ;; Re-apply after initial UI is up.
  (add-hook 'window-setup-hook #'jrh/macos-background-stipple)
  ;; Re-apply whenever a theme is loaded.
  (advice-add 'load-theme :after (lambda (&rest _) (jrh/macos-background-stipple))))
