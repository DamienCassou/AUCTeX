;;; tex-style.el --- Customizable variables for AUCTeX style files

;; Copyright (C) 2005  Free Software Foundation, Inc.

;; Author: Reiner Steib <Reiner.Steib@gmx.de>
;; Keywords: tex, wp, convenience

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This file provides customizable variables for AUCTeX style files.

;;; Code:

(defgroup LaTeX-style nil
  "Support for special LaTeX style files in AUCTeX."
  :group 'LaTeX-macro)

;; Note: We don't have any defcustom in plain TeX style files yet.  Else we
;; should also create a TeX-style group.

;; style/amsmath.el

(defcustom LaTeX-amsmath-label nil
  "Default prefix to amsmath equation labels.

Amsmath equations include \"align\", \"alignat\", \"xalignat\",
\"aligned\", \"flalign\" and \"gather\".  If it is nil,
`LaTeX-equation-label' is used."
  :group 'LaTeX-label
  :type '(choice (const :tag "Use `LaTeX-equation-label'" nil)
		 (string)))

;; style/beamer.el

(defcustom LaTeX-beamer-section-labels-flag nil
  "If non-nil section labels are added"
  :type 'boolean
  :group 'LaTeX-style)

(defcustom LaTeX-beamer-item-overlay-flag t
  "If non-nil do prompt for an overlay in itemize-like environments."
  :type 'boolean
  :group 'LaTeX-style)

(defcustom LaTeX-beamer-themes 'local
  "Presentation themes for the LaTeX beamer package.
It can be a list of themes or a function.  If it is the symbol
`local', search only once per buffer."
  :group 'LaTeX-style
  :type
  '(choice
    (const :tag "TeX search" LaTeX-beamer-search-themes)
    (const :tag "Search once per buffer" local)
    (function :tag "Other function")
    (list
     :value
     ;; Work around (bug in customize?), see
     ;; <news:v9is48jrj1.fsf@marauder.physik.uni-ulm.de>
     ("Antibes" "Bergen" "Berkeley" "Berlin" "Boadilla" "Copenhagen"
      "Darmstadt" "Dresden" "Frankfurt" "Goettingen" "Hannover"
      "Ilmenau" "JuanLesPins" "Luebeck" "Madrid" "Malmoe" "Marburg"
      "Montpellier" "PaloAlto" "Pittsburgh" "Rochester" "Singapore"
      "Szeged" "Warsaw")
     (set :inline t
	  (const "Antibes")
	  (const "Bergen")
	  (const "Berkeley")
	  (const "Berlin")
	  (const "Boadilla")
	  (const "Copenhagen")
	  (const "Darmstadt")
	  (const "Dresden")
	  (const "Frankfurt")
	  (const "Goettingen")
	  (const "Hannover")
	  (const "Ilmenau")
	  (const "JuanLesPins")
	  (const "Luebeck")
	  (const "Madrid")
	  (const "Malmoe")
	  (const "Marburg")
	  (const "Montpellier")
	  (const "PaloAlto")
	  (const "Pittsburgh")
	  (const "Rochester")
	  (const "Singapore")
	  (const "Szeged")
	  (const "Warsaw"))
     (repeat :inline t
	     :tag "Other"
	     (string)))))

;; style/csquotes.el

(defcustom LaTeX-csquotes-quote-after-quote nil
  "Initial value of `TeX-quote-after-quote' for `csquotes.el'"
  :type 'boolean
  :group 'LaTeX-style)

(defcustom LaTeX-csquotes-open-quote ""
  "Opening quotation mark to be used with the csquotes package.
The specified string will be used for `TeX-open-quote' (and override
the value of `LaTeX-german-open-quote' if the german or ngerman
package is used) only if both `LaTeX-csquotes-open-quote' and
`LaTeX-csquotes-close-quote' are non-empty strings."
  :type 'string
  :group 'LaTeX-style)

(defcustom LaTeX-csquotes-close-quote ""
  "Closing quotation mark to be used with the csquotes package.
The specified string will be used for `TeX-close-quote' (and override
the value of `LaTeX-german-close-quote' if the german or ngerman
package is used) only if both `LaTeX-csquotes-open-quote' and
`LaTeX-csquotes-close-quote' are non-empty strings."
  :type 'string
  :group 'LaTeX-style)

;; style/emp.el

(defcustom LaTeX-write18-enabled-p t
  "*If non-nil, insert automatically the \\write18 calling metapost.
When disabled, you have to use mpost on the mp files automatically 
produced by emp.sty and then re-LaTeX the document."
  :type 'boolean
  :group 'LaTeX-style)

;; style/german.el

(defcustom LaTeX-german-quote-after-quote t
  "Initial value of `TeX-quote-after-quote' for `german.el'."
  :group 'LaTeX-style
  :type 'boolean)

(defcustom LaTeX-german-open-quote "\"`"
  "Initial value of `TeX-open-quote' for `german.el'."
  :group 'LaTeX-style
  :type 'string)

(defcustom LaTeX-german-close-quote "\"'"
  "Initial value of `TeX-close-quote' for `german.el'."
  :group 'LaTeX-style
  :type 'string)

(defcustom LaTeX-german-hyphen "\"="
  "String to be used when typing `-'.
This usually is a hyphen alternatives or hyphenation aid
provided by (n)german.sty, like \"=, \"~ or \"-.
Set it to an empty string or nil for disabling this feature."
  :group 'LaTeX-style
  :type '(string))

(defcustom LaTeX-german-hyphen-after-hyphen t
  "Control insertion of hyphen strings.
If non-nil insert normal hyphen on first key press and swap it
with the (n)german.sty-specific hyphen string specified in the
variable `LaTeX-german-hyphen' on second key press.
If nil do it the other way round."
  :group 'LaTeX-style
  :type 'boolean)

;; style/graphicx.el

(defcustom LaTeX-includegraphics-extensions
  '("eps" "jpe?g" "pdf" "png")
  "Extensions for images files used by \\includegraphics."
  :group 'LaTeX-style
  :type '(list (set :inline t
		    (const "eps")
		    (const "jpe?g")
		    (const "pdf")
		    (const "png"))
	       (repeat :inline t
		       :tag "Other"
		       (string))))

(defcustom LaTeX-includegraphics-options-alist
  '((0 width)
    ;; (1 width height clip)
    ;; (2 width height keepaspectratio clip)
    (4) ;; --> (4 nil)
    (5 trim)
    (16
     ;; Table 1 in epslatex.ps: ``includegraphics Options''
     height totalheight width scale angle origin bb
     ;; Table 2 in epslatex.ps: ``cropping Options''
     viewport trim
     ;; Table 3 in epslatex.ps: ``Boolean Options''
     ;; [not implemented:] noclip draft final
     clip keepaspectratio
     ;; Only for PDF:
     page))
  "Controls for which optional arguments of \\includegraphics you get prompted.

An alist, consisting of \(NUMBER . LIST\) pairs.  Valid elements of LIST are
`width', `height', `keepaspectratio', `clip', `angle', `totalheight', `trim'
and `bb' \(Bounding Box\).

The list corresponding to 0 is used if no prefix is given.  Note that 4 \(one
\\[universal-argument]\) and 16 \(two \\[universal-argument]'s\) are easy to
type and should be used for frequently needed combinations."
  :group 'LaTeX-style
  :type '(repeat (cons (integer :tag "Argument")
		       (list (set :inline t
				  (const height)
				  (const totalheight)
				  (const width)
				  (const scale)
				  (const angle)
				  (const origin)
				  (const :tag "Bounding Box" bb)
				  ;;
				  (const viewport)
				  (const trim)
				  ;;
				  (const clip)
				  (const keepaspectratio))))))

(defcustom LaTeX-includegraphics-strip-extension-flag t
  "Non-nil means to strip known extensions from image file name."
  :group 'LaTeX-style
  :type 'boolean)

(defcustom LaTeX-includegraphics-read-file
  'LaTeX-includegraphics-read-file-TeX
  "Function for reading \\includegraphics files.

`LaTeX-includegraphics-read-file-TeX' lists all graphic files
found in the TeX search path.

`LaTeX-includegraphics-read-file-relative' lists all graphic files
in the master directory and its subdirectories and inserts the
relative file name.  This option doesn't works with Emacs 21.3 or
XEmacs.

The custom option `simple' works as
`LaTeX-includegraphics-read-file-relative' but it lists all kind of
files.

Inserting the subdirectory in the filename (as
`LaTeX-includegraphics-read-file-relative') is discouraged by
`epslatex.ps'."
;; ,----[ epslatex.ps; Section 12; (page 26) ]
;; | Instead of embedding the subdirectory in the filename, there are two
;; | other options
;; |   1. The best method is to modify the TeX search path [...]
;; |   2. Another method is to specify sub/ in a \graphicspath command
;; |      [...].  However this is much less efficient than modifying the
;; |      TeX search path
;; `----
;; See "Inefficiency" and "Unportability" in the same section for more
;; information.
  :group 'LaTeX-style
  :type '(choice (const :tag "TeX" LaTeX-includegraphics-read-file-TeX)
		 (const :tag "relative"
			LaTeX-includegraphics-read-file-relative)
		 (const :tag "simple" (lambda ()
					(file-relative-name
					 (read-file-name "Image file: ")
					 (TeX-master-directory))))
		 (function :tag "other")))


(provide 'tex-style)
;;; tex-style.el ends here
