(setq-default cursor-type 'box)
(set-cursor-color "red")

(require 'subr-x)

(package-initialize)

(require 'package)
(add-to-list 'package-archives
         '("melpa" . "http://melpa.org/packages/") t)

(when (not package-archive-contents)
    (package-refresh-contents))

(dolist (package '(use-package))
  (unless (package-installed-p 'use-package)
    (package-install 'use-package)))

(require 'use-package)
(setq use-package-always-ensure t)

(add-to-list 'load-path "~/.emacs.d/custom")

(require 'setup-general)
(if (version< emacs-version "24.4")
    (require 'setup-ivy-counsel)
  (require 'setup-helm)
;  (require 'setup-helm-gtags)
  )

;; (require 'setup-ggtags)
(require 'setup-cedet)
(require 'setup-editing)

(projectile-global-mode)
(setq projectile-completion-system 'helm)
(helm-projectile-on)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(setq projectile-indexing-method 'alien)

;; jump to help window when it is displayed
(setq help-window-select t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PACKAGE: magit                       ;;
;;                                      ;;
;; GROUP: Programming -> Tools -> Magit ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this ensure the magit packe is installed, and installs it if not
(use-package magit
  :ensure t)

(require 'magit)
(set-default 'magit-stage-all-confirm nil)
;(add-hook 'magit-mode-hook 'magit-load-config-extensions)

;; full screen magit-status
(defadvice magit-status (around magit-fullscreen activate)
  (window-configuration-to-register :magit-fullscreen)
  ad-do-it
  (delete-other-windows))

(global-unset-key (kbd "C-x g"))
(global-set-key (kbd "C-x g h") 'magit-log)
(global-set-key (kbd "C-x g f") 'magit-file-log)
(global-set-key (kbd "C-x g b") 'magit-blame-mode)
(global-set-key (kbd "C-x g m") 'magit-branch-manager)
(global-set-key (kbd "C-x g c") 'magit-branch)
(global-set-key (kbd "C-x g s") 'magit-status)
(global-set-key (kbd "C-x g r") 'magit-reflog)
(global-set-key (kbd "C-x g t") 'magit-tag)

; on MacOS, C-up and C-down are bound by the finder to show all windows show all app windows, soit overrides the move paragraph forward and back.
; M-e and M-a are not bound so use them for that tool
(global-set-key (kbd "ESC <down>") 'forward-paragraph)
(global-set-key (kbd "ESC <up>") 'backward-paragraph)


; ensures eglot is installed and installs it if not
(use-package eglot
  :ensure t)
(require 'eglot)

(use-package sr-speedbar
  :ensure t)

;; we need this for cross-compilation so clangd/eglot uses the definitions
;; for the embedded target, in conjunction with compile_command.json
(add-to-list 'eglot-server-programs
             `((c++-mode c-mode) "clangd" "--query-driver=/**/*"))

;; install and enable platformio mode if needed
(use-package platformio-mode
  :ensure t)
(require 'platformio-mode)

;; Enable ccls for all c++ files, and platformio-mode only
;; when needed (platformio.ini present in project root).
(add-hook 'c++-mode-hook (lambda ()
                           (lsp-deferred)
                           (platformio-conditionally-enable)))
;; end platformio

;; function-args
;; (require 'function-args)
;; (fa-config-default)
;; (define-key c-mode-map  [(tab)] 'company-complete)
;; (define-key c++-mode-map  [(tab)] 'company-complete)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-startup-truncated nil)
 '(package-selected-packages
   '(anzu clean-aindent-mode comment-dwim-2 company dtrt-indent gptel
          gptel-agent helm-projectile iedit magit pdf-tools
          platformio-mode sr-speedbar undo-tree volatile-highlights
          ws-butler yasnippet zygospore)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-diff-added ((t (:extend t :background "#335533" :foreground "black"))))
 '(magit-diff-added-highlight ((t (:extend t :background "#336633" :foreground "black")))))

(defun open-this-file-as-other-user (user)
  "Edit current file as USER, using `tramp' and `sudo'.  If the current
buffer is not visiting a file, prompt for a file name."
  (interactive "sEdit as user (default: root): ")
  (when (string= "" user)
    (setq user "root"))
  (let* ((filename (or buffer-file-name
                       (read-file-name (format "Find file (as %s): "
                                               user))))
         (tramp-path (concat (format "/sudo:%s@localhost:" user) filename)))
    (if buffer-file-name
        (find-alternate-file tramp-path)
      (find-file tramp-path))))

;; For MacOS use commad key as meta
;;(setq mac-command-modifier 'meta)
;; use ALT key as meta, because PC ALT key is mapped by MacOS as the 'option' key
(setq mac-option-modifier 'meta)
;; leave right ALT as normal mac modifier so we can enter special characters
(setq mac-right-option-modifier 'none)

;; pfd-tools
(use-package pdf-tools
  :ensure t)
(require 'pdf-tools)
(pdf-tools-install :no-query)  ; Standard activation command
;(pdf-loader-install) ; On demand loading, leads to faster startup time
(require 'pdf-info)
(require 'pdf-util)

;; gptel
(use-package gptel
  :ensure t)
(require 'gptel)

;; Llama.cpp offers an OpenAI compatible API
;; configure my default gptel backend
(setq gptel-track-media 't) ; Ensure media mode is on
(setq
 gptel-model   'local-llama
 gptel-backend (gptel-make-openai "llama-cpp"          ;Any name
                   :stream t                           ;Stream responses
                   :protocol "http"
                   :host "bigboss:8080"     ;Llama.cpp server location
                   :models              ;Any names, doesn't matter for Llama
                    '((local-llama
                      :description "my own local llama-server instance"
                      :capabilities (media tool-use json url)
                      :mime-types ("image/jpeg" "image/png" "image/gif" "image/webp" "text/plain" "text/csv" "text/html")))))

;; "application/pdf"
;; llama does not support PDF files, only images. this does the conversion
(defun pdf-to-images-path (file-path)
  "Export selected PDF file pages as PNG images."
  (interactive "fSelect a PDF file: ")
  (let* ((pdf-buf (find-file-noselect file-path))
         (pdf-name (file-name-base file-path))
         (output-dir (make-temp-file (concat pdf-name "-images") t))
         (total-pages (pdf-info-number-of-pages pdf-buf)))
    (set-buffer pdf-buf)
    (cl-loop for page from 1 to total-pages do
             (let ((image (pdf-view-create-page page)))
               (with-temp-buffer
                 (insert (plist-get (cdr image) :data))
                 (write-region (point-min) (point-max)
                               (format "%s/page-%03d.png" output-dir page)))))
    (message "PDF pages exported as images in %s" output-dir)
    (kill-buffer pdf-buf)
    output-dir)
  )

;; tell gptel about our function above so it does the conversion of PDF into PNG and use them
(define-advice gptel-add-file (:filter-args (path) )
  (if-let* ((gptel--model-capable-p 'media)
            (mime (mailcap-file-name-to-mime-type (car path)))
            ;; Check if PATH is a pdf, and if the model supports PNG but not PDF
            ((and (equal mime "application/pdf")
                  (not (gptel--model-mime-capable-p mime))
                  (gptel--model-mime-capable-p "image/png"))))
      (list (pdf-to-images-path (car path)))
    path))

;;  "application/pdf"
;; (setq
;;  gptel-model   'local-llama
;;  gptel-backend (gptel-make-openai "llama-cpp"          ;Any name
;;                  :stream t                           ;Stream responses
;;                  :protocol "http"
;;                  :host "files.bschwand.net:8080"     ;Llama.cpp server location
;;                  :models              ;Any names, doesn't matter for Llama
;;                  '("gpt-5")))

(setq gptel-log-level 'debug)
;; gptel agents
(setq gptel-max-tokens 262000)
(use-package gptel-agent
  :ensure t)
(require 'gptel-agent)
