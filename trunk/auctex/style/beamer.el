;;; beamer.el --- AUCTeX style for the latex-beamer class

;; Copyright (C) 2003, 2004, 2005 Free Software Foundation
;; License: GPL, see the file COPYING in the base directory of AUCTeX

;; Author: Thomas Baumann <thomas.baumann@ch.tum.de>
;; Created: 2003-12-20
;; Keywords: tex

;;; Commentary:

;; This file adds support for the latex-beamer class.

;;; Code:

(TeX-add-style-hook
 "beamer"
 (lambda ()
   (unless LaTeX-beamer-section-labels-flag
     (make-local-variable 'LaTeX-section-hook)
     (setq LaTeX-section-hook
	   '(LaTeX-section-heading
	     LaTeX-section-title
	     LaTeX-section-section)))

   (setq LaTeX-item-list
	 (append '(("itemize" . LaTeX-item-beamer)
		   ("enumerate" . LaTeX-item-beamer))
		 LaTeX-item-list))

   (LaTeX-paragraph-commands-add-locally "frametitle")

   (TeX-add-symbols
    '("alert" 1)
    '("alt" TeX-arg-beamer-overlay-spec 2)
    '("beamerbutton" 1)
    '("beamergotobutton" 1)
    '("beamerreturnbutton" 1)
    '("beamerskipbutton" 1)
    '("frame" TeX-arg-beamer-frametitle)
    '("frametitle" 1)
    '("hyperlink" TeX-arg-beamer-overlay-spec 2)
    '("hyperlinkslideprev" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkslidenext" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkframestart" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkframeend" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkframestartnext" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkframeendprev" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkpresentationstart" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkpresentationend" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkappendixstart" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkappendixend" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkdocumentstart" TeX-arg-beamer-overlay-spec 1)
    '("hyperlinkdocumentend" TeX-arg-beamer-overlay-spec 1)
    '("hypertarget" TeX-arg-beamer-overlay-spec 2)
    '("institute" 1)
    '("invisible" TeX-arg-beamer-overlay-spec 1)
    '("label" TeX-arg-beamer-overlay-spec 1)
    '("logo" 1)
    '("note" TeX-arg-beamer-note 1)
    '("only" TeX-arg-beamer-overlay-spec 1)
    '("onslide" TeX-arg-beamer-overlay-spec)
    '("partpage")
    '("pause")
    '("structure" TeX-arg-beamer-overlay-spec 1)
    '("temporal" TeX-arg-beamer-overlay-spec 3)
    '("titlepage")
    '("titlegraphic" 1)
    '("uncover" TeX-arg-beamer-overlay-spec 1)
    '("usetheme" LaTeX-arg-beamer-theme)
    '("useinnertheme" LaTeX-arg-beamer-inner-theme)
    '("useoutertheme" LaTeX-arg-beamer-outer-theme)
    '("usecolortheme" LaTeX-arg-beamer-color-theme)
    '("usefonttheme" LaTeX-arg-beamer-font-theme)
    '("usetheme" LaTeX-arg-beamer-theme)
    '("visible" TeX-arg-beamer-overlay-spec 1))

   (LaTeX-add-environments
    '("actionenv")
    '("alertblock" 1)
    '("beamerboxesrounded" 1)
    '("block" 1)
    '("column" "Width")
    "columns"
    "columnsonlytextwidth"
    '("exampleblock" 1)
    '("frame"  (lambda (env &rest ignore)
		 (let ((title (read-input "(Optional) Title: ")))
		   (LaTeX-insert-environment env)
		   (unless (zerop (length title))
		     (save-excursion
		       (LaTeX-find-matching-begin)
		       (end-of-line)
		       (LaTeX-newline)
		       (insert (format "\\frametitle{%s}" title))
		       ;; This works because \frametitle is a
		       ;; paragraph command.
		       (backward-char)
		       (LaTeX-fill-paragraph))))))
    '("onlyenv" (lambda (env &rest ignore)
		  (LaTeX-insert-environment
		   env
		   (let ((overlay (read-input "(Optional) Overlay: ")))
		     (unless (zerop (length overlay))
		       (format "<%s>" overlay))))))
    '("overlayarea" "Area width" "Area height")
    '("overprint"  (lambda (env &rest ignore)
		     (LaTeX-insert-environment
		      env
		      (let ((width (read-input "(Optional) Area width: ")))
			(unless (zerop (length width))
			  (format "[%s]" width)))))))

   ;; Fontification
   (when (and (featurep 'font-latex)
	      (eq TeX-install-font-lock 'font-latex-setup))
     (add-to-list 'font-latex-match-slide-title-keywords-local
		  '("frametitle" "<[{"))
     (font-latex-match-slide-title-make)
     ;; Tell font-lock about the update.
     (setq font-lock-set-defaults nil)
     (font-lock-set-defaults))))

(defun TeX-arg-beamer-overlay-spec (optional &optional prompt)
  "Prompt for overlay specification." 
  (let ((overlay (read-input "(Optional) Overlay: ")))
    (unless (zerop (length overlay))
      (insert "<" overlay ">"))
    (indent-according-to-mode)))

(defun TeX-arg-beamer-frametitle (optional &optional prompt)
  "Prompt for the frametitle."
  (let ((title (read-input "Title: ")))
    (if (not (zerop (length title)))
        (insert TeX-grop TeX-esc "frametitle" TeX-grop 
		title TeX-grcl TeX-grcl)
      (insert TeX-grop TeX-grcl))))

(defun LaTeX-item-beamer ()
  "Insert a new item with an optional overlay argument. You 
can turn off the prompt for the overlay argument by setting 
`LaTeX-beamer-item-overlay-flag' to nil. Calling the function
with a prefix argument prompts for the overlay specification
unconditionally."
  (if (listp current-prefix-arg)
      (setq current-prefix-arg (car current-prefix-arg))
    current-prefix-arg)
  (TeX-insert-macro "item")
  (delete-horizontal-space)
  (if (or current-prefix-arg LaTeX-beamer-item-overlay-flag)
      (TeX-arg-beamer-overlay-spec 0))
  (insert " ")
  (indent-according-to-mode))
  
(defun TeX-arg-beamer-note (optional &optional prompt)
  "Prompt for overlay specification and optional argument."
  (let ((overlay (read-input "(Optional) Overlay: "))
        (options (read-input "(Optional) Options: ")))
    (unless (zerop (length overlay))
      (insert "<" overlay ">"))
    (unless (zerop (length options))
      (insert "[" options "]"))
    (indent-according-to-mode)))

(defun LaTeX-beamer-search-themes (&optional regexp extensions length)
  "Search for beamer themes matching REGEXP with EXTENSIONS.
The function removes the first LENGTH characters and the
extension of the file and returns a list of strings.  LENGTH may
also be a string.  Then the length of the string is used."
  (let* ((match (or regexp "^beamertheme[A-Z]"))
	 (exts  (or extensions '("tex" "sty")))
	 (chars (cond ((integerp length)
		       length)
		      ((stringp length)
		       (string-width length))
		      ;; Try some DWIM magic...
		      ((and (not length)
			    (string-match "beamer[A-Za-z0-9]*theme" match))
		       (- (match-end 0) (match-beginning 0)))
		      (t (error "Invalid length: `%s'" length)))))
    ;; (message "match=`%s' chars=`%s'" match chars)
    (TeX-delete-duplicate-strings
     (delete nil
	     (mapcar
	      (lambda (file)
		(let ((case-fold-search nil))
		  (and (numberp (string-match match file))
		       (substring file chars))))
	      (TeX-search-files nil exts t t))))))

(defun LaTeX-arg-beamer-theme (&rest ignore)
  "Prompt for beamer theme with completion."
  (TeX-argument-insert
   (completing-read
    (TeX-argument-prompt nil nil "Theme")
    (mapcar 'list
	    (cond ((eq LaTeX-beamer-themes 'local)
		   (set (make-local-variable 'LaTeX-beamer-themes)
			(LaTeX-beamer-search-themes)))
		  ((functionp LaTeX-beamer-themes)
		   (funcall LaTeX-beamer-themes))
		  ((listp LaTeX-beamer-themes)
		   LaTeX-beamer-themes)
		  (t (error
		      "`LaTeX-beamer-themes' should be a list: `%s'"
		      LaTeX-beamer-themes))))
    nil nil nil)
   t))

(defun LaTeX-arg-beamer-inner-theme (&rest ignore)
  "Prompt for beamer inner theme with completion."
  (TeX-argument-insert
   (completing-read
    (TeX-argument-prompt nil nil "Theme")
    (mapcar 'list
	    (cond ((eq LaTeX-beamer-inner-themes 'local)
		   (set (make-local-variable 'LaTeX-beamer-inner-themes)
			(LaTeX-beamer-search-themes "^beamerinnertheme")))
		  ((functionp LaTeX-beamer-inner-themes)
		   (funcall LaTeX-beamer-inner-themes))
		  ((listp LaTeX-beamer-inner-themes)
		   LaTeX-beamer-inner-themes)
		  (t (error
		      "`LaTeX-beamer-inner-themes' should be a list: `%s'"
		      LaTeX-beamer-inner-themes))))
    nil nil nil)
   t))

(defun LaTeX-arg-beamer-outer-theme (&rest ignore)
  "Prompt for beamer outer theme with completion."
  (TeX-argument-insert
   (completing-read
    (TeX-argument-prompt nil nil "Theme")
    (mapcar 'list
	    (cond ((eq LaTeX-beamer-outer-themes 'local)
		   (set (make-local-variable 'LaTeX-beamer-outer-themes)
			(LaTeX-beamer-search-themes "^beameroutertheme")))
		  ((functionp LaTeX-beamer-outer-themes)
		   (funcall LaTeX-beamer-outer-themes))
		  ((listp LaTeX-beamer-outer-themes)
		   LaTeX-beamer-outer-themes)
		  (t (error
		      "`LaTeX-beamer-outer-themes' should be a list: `%s'"
		      LaTeX-beamer-outer-themes))))
    nil nil nil)
   t))

(defun LaTeX-arg-beamer-color-theme (&rest ignore)
  "Prompt for beamer color theme with completion."
  (TeX-argument-insert
   (completing-read
    (TeX-argument-prompt nil nil "Theme")
    (mapcar 'list
	    (cond ((eq LaTeX-beamer-color-themes 'local)
		   (set (make-local-variable 'LaTeX-beamer-color-themes)
			(LaTeX-beamer-search-themes "^beamercolortheme")))
		  ((functionp LaTeX-beamer-color-themes)
		   (funcall LaTeX-beamer-color-themes))
		  ((listp LaTeX-beamer-color-themes)
		   LaTeX-beamer-color-themes)
		  (t (error
		      "`LaTeX-beamer-color-themes' should be a list: `%s'"
		      LaTeX-beamer-color-themes))))
    nil nil nil)
   t))

(defun LaTeX-arg-beamer-font-theme (&rest ignore)
  "Prompt for beamer font theme with completion."
  (TeX-argument-insert
   (completing-read
    (TeX-argument-prompt nil nil "Theme")
    (mapcar 'list
	    (cond ((eq LaTeX-beamer-font-themes 'local)
		   (set (make-local-variable 'LaTeX-beamer-font-themes)
			(LaTeX-beamer-search-themes "^beamerfonttheme")))
		  ((functionp LaTeX-beamer-font-themes)
		   (funcall LaTeX-beamer-font-themes))
		  ((listp LaTeX-beamer-font-themes)
		   LaTeX-beamer-font-themes)
		  (t (error
		      "`LaTeX-beamer-font-themes' should be a list: `%s'"
		      LaTeX-beamer-font-themes))))
    nil nil nil)
   t))
