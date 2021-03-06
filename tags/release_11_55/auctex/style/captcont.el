;; captcont.el --- AUCTeX style file for captcont.sty
;; Copyright (C) 2003 Reiner Steib

;; Author: Reiner Steib  <Reiner.Steib@gmx.de>
;; Keywords: tex

;;; Commentary:
;;
;; AUCTeX style file for captcont.sty

;;; Code:

(TeX-add-style-hook
 "captcont"
 (lambda ()
   (TeX-add-symbols
    '("captcont"  [ "list entry" ] "Caption")
    '("captcont*" [ "list entry" ] "Caption"))
   (when (and (featurep 'font-latex)
	      (eq TeX-install-font-lock 'font-latex-setup))
     (add-to-list 'font-latex-match-textual-keywords-local "captcont")
     (font-latex-match-textual-make))))

;;; captcont.el ends here
