;;; packages.el --- franco-godot Layer Packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2017 Sylvain Benner & Contributors
;;
;; Author: Franco Eusébio Garcia
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defvar franco-godot-packages '(
                                ;; company
                                ;; (company-godot-gdscript
                                ;;  :location (recipe
                                ;;             :fetcher github
                                ;;             :repo "francogarcia/company-godot-gdscript.el")
                                ;;  :requires company)
                                ;; TODO dumb-jump
                                ;; TODO evil-matchit
                                ;; TODO flycheck
                                (godot-gdscript
                                 :location (recipe
                                            :fetcher github
                                            :repo "francogarcia/godot-gdscript.el"))
                                smartparens
                                ;; TODO stickyfunc-enhance
                                toml-mode
                                )
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar franco-godot-excluded-packages '()
  "List of packages to exclude.")

;; For each package, define a function franco-godot/init-<package-franco-godot>

(defun franco-godot/post-init-company ()
  (spacemacs|add-company-backends
    :backends (company-files company-capf)
    :modes godot-gdscript-mode
    :variables
    ;; company-minimum-prefix-length 0
    company-minimum-prefix-length 1
    company-async-timeout 10
    company-idle-delay 0.5)
  )

(defun franco-godot/init-company-godot-gdscript ()
  (use-package company-godot-gdscript
    :defer t
    :init
    (progn
      (spacemacs|add-company-backends
            :backends company-godot-gdscript
            :modes godot-gdscript-mode)
      )
    :config
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'godot-gdscript-mode
        "k" 'company-complete)
      )
    ))

(defun franco-godot/init-godot-gdscript()
  "Initialize Godot-GDScript major mode."

  (use-package godot-gdscript
    :mode ("\\.gd\\'" . godot-gdscript-mode)
    :defer t
    :init
    (progn
      ;; (spacemacs/register-repl 'python 'python-start-or-switch-repl "godot gdscript")

      (defun franco/godot-gdscript-mode-default-settings ()
        ;; TODO Paths for Windows.
        (setq mode-name "Godot-GDScript"
              godot-gdscript-shell-interpreter "godot.x11.tools.64"
              godot-gdscript-shell-exec-path `(,(franco/projects "C++/Godot/godot/bin/"))
              godot-gdscript-shell-interpreter-args ""
              indent-tabs-mode nil
              tab-width 4)
        ;; Make C-j work the same way as RET.
        (local-set-key (kbd "C-j") 'newline-and-indent)

        )

      (defun franco/reload-godot-after-save ()
        "Auto-reload the project with `xdotool', then focus on
the game window."
        (add-hook
         'after-save-hook
         #'(lambda ()
             (shell-command (concat "bash ~/tmp/update-godot.sh " (godot-gdscript-get-project-name))))
         nil 'make-it-local))
      )

      (spacemacs/add-all-to-hook 'godot-gdscript-mode-hook
                                 'franco/godot-gdscript-mode-default-settings
                                 ;; 'franco/reload-godot-after-save
                                 )
    :config
    (progn
      ;; Keybindings.
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "mc" "execute")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "md" "debug")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "mh" "help")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "mt" "test")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "ms" "send to REPL")
      (spacemacs/declare-prefix-for-mode 'godot-gdscript-mode "mr" "refactor")

      (spacemacs/set-leader-keys-for-major-mode 'godot-gdscript-mode
        ;; "'"  'godot-gdscript-start-or-switch-repl
        ;; "cc" 'spacemacs/godot-gdscript-execute-file
        ;; "cC" 'spacemacs/godot-gdscript-execute-file-focus
        ;; "db" 'godot-gdscript-toggle-breakpoint
        ;; "ri" 'godot-gdscript-remove-unused-imports
        ;; "sB" 'godot-gdscript-shell-send-buffer-switch
        ;; "sb" 'godot-gdscript-shell-send-buffer
        ;; "sF" 'godot-gdscript-shell-send-defun-switch
        ;; "sf" 'godot-gdscript-shell-send-defun
        ;; "si" 'godot-gdscript-start-or-switch-repl
        ;; "sR" 'godot-gdscript-shell-send-region-switch
        ;; "sr" 'godot-gdscript-shell-send-region
        ;; "cc" 'godot-gdscript-shell-send-buffer

        "," 'godot-gdscript-run-project-in-godot

        "cg" 'godot-gdscript-run-godot-editor
        "cp" 'godot-gdscript-run-project-in-godot
        "ce" 'godot-gdscript-edit-current-scene-in-godot
        "cs" 'godot-gdscript-run-current-scene-in-godot
        "cs" 'godot-gdscript-run-current-script-in-godot

        "dp" 'godot-gdscript-run-project-in-godot-debug-mode
        "ds" 'godot-gdscript-run-current-scene-in-godot-debug-mode
        "dd" 'godot-gdscript-shell-switch-to-shell

        "gi" 'imenu
        ))))

(defun franco-godot/post-init-smartparens ()
  (spacemacs/add-to-hooks 'smartparens-mode '(godot-gdscript-mode))
  (defadvice godot-gdscript-indent-dedent-line-backspace
      (around godot-gdscript/sp-backward-delete-char activate)
    (let ((godot-gdscriptp (or (not smartparens-strict-mode)
                       (char-equal (char-before) ?\s))))
      (if godot-gdscriptp
          ad-do-it
        (call-interactively 'sp-backward-delete-char))))
  )

(defun franco-godot/init-toml-mode()
  "Initialize TOML major mode."

  (use-package toml-mode
    :defer t
    :init
    (progn
      (dolist (pattern '("\\.tscn\\'" ;; "\\.tscn\\'"
                         "\\.tres\\'"))
        (add-to-list 'auto-mode-alist (cons pattern 'toml-mode))))
    :config
    (progn
      )))
