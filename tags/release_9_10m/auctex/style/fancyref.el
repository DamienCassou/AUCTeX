;; AUCTeX style file with support for fancyref.sty
;; Author: C. Dominik <dominik@strw.leidenuniv.nl>
;; Last change: 20 Feb 1999

(TeX-add-style-hook "fancyref"
   (lambda ()
     
     (TeX-add-symbols

      ;; The macros with label arguments
      '("fref" [ TeX-arg-fancyref-format ] TeX-arg-label)
      '("Fref" [ TeX-arg-fancyref-format ] TeX-arg-label)

      ;; The macros which define new prefixes and formats
      '("fancyrefchangeprefix" TeX-arg-macro "Prefix")
      '("Frefformat" TeX-arg-fancyref-format TeX-arg-macro "Output")
      '("frefformat" TeX-arg-fancyref-format TeX-arg-macro "Output")

      ;; The delimiter
      "fancyrefargdelim"

      ;; All those names and abbreviations.
      ;; Part
      "fancyrefpartlabelprefix" 
      "Frefpartname" "frefpartname"   
      ;; Chapter
      "fancyrefchalabelprefix"
      "Frefchaname" "frefchaname"   
      ;; Section
      "fancyrefseclabelprefix"
      "Frefsecname" "frefsecname"
      ;; Equation
      "fancyrefeqlabelprefix"
      "Frefeqname" "frefeqname"   
      ;; Figure
      "fancyreffiglabelprefix"
      "Freffigname" "freffigname" "Freffigshortname"
      ;; Footnote
      "fancyreffnlabelprefix"
      "Freffnname" "freffnname"   
      ;; Item
      "fancyrefitemlabelprefix"
      "Frefitemname" "frefitemname" 
      ;; Table
      "fancyreftablabelprefix"
      "Freftabname" "freftabname" "Freftabshortname"
      ;; Page
      "Frefpgname" "frefpgname" "Frefpgshortname"
      ;; On
      "Frefonname" "frefonname" 
      ;; See
      "Frefseename" "frefseename"

      ;; The spacing macros
      "fancyrefloosespacing" "fancyreftightspacing" "fancyrefdefaultspacing"

      ;; And the hook
      "fancyrefhook")

     ;; Insatall completion for labels and formats
     (setq TeX-complete-list
	   (append
	    '(("\\\\[fF]ref\\(\\[[^]]*\\]\\)?{\\([^{}\n\r\\%,]*\\)" 
	       2 LaTeX-label-list "}")
	      ("\\\\[fF]ref\\[\\([^{}\n\r\\%,]*\\)" 
	       1 LaTeX-fancyref-formats "]")
	      ("\\\\[fF]refformat{\\([^{}\n\r\\%,]*\\)"
	       1 LaTeX-fancyref-formats "}"))
	    TeX-complete-list))))

;; The following list keeps a list of available format names
;; Note that this list is only updated when a format is used, not
;; during buffer parsing.  We could install a regexp to look for
;; formats, but this would not work in multifile documents since the
;; formats are not written out to the auto files.
;; For now, we just leave it at that.
(defvar LaTeX-fancyref-formats '(("plain") ("vario") ("margin") ("main"))
  "List of formats for fancyref.")

(defun LaTeX-fancyref-formats () LaTeX-fancyref-formats)

(defun TeX-arg-fancyref-format (optional &optional prompt definition)
  "Prompt for a fancyref format name.
If the user gives an unknown name, add it to the list."
  (let ((format (completing-read (TeX-argument-prompt optional prompt "Format")
				 LaTeX-fancyref-formats)))
    (if (not (string-equal "" format))
	(add-to-list 'LaTeX-fancyref-formats (list format)))
    (TeX-argument-insert format optional)))

;; fancyref.el ends here
