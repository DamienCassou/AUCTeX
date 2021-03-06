;;; slides.el --- AUCTeX style for the `slides' document class

;; Copyright (C) 2004 Free Software Foundation, Inc.

;; Author: Ralf Angeli <angeli@iwi.uni-sb.de>
;; Maintainer: auc-tex@sunsite.dk
;; Created: 2004-04-21
;; Keywords: tex

;; This file is part of AUCTeX.

;; AUCTeX is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; AUCTeX is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with AUCTeX; see the file COPYING.  If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.

;;; Commentary:

;; This file adds support for the `slides' document class.  Currently
;; the support is very limited.  You are welcome to improve it.

;;; Code:

(TeX-add-style-hook
 "slides"
 (lambda ()
   (LaTeX-add-environments "slide"
			   "overlay"
			   "note")))

;;; slides.el ends here
