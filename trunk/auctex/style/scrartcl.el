;;; -*- emacs-lisp -*-
;;; scrartcl.el -- AUCTeX style for scrartcl.cls

;; Copyright (C) 2002 Free Software Foundation
;; License: GPL, see the file COPYING in the base directory of AUCTeX

;; Author: Mark Trettin <Mark.Trettin@gmx.de>
;; Created: 2002-09-26
;; Version: $Id: scrartcl.el,v 1.3 2004-08-15 20:11:21 dak Exp $
;; Keywords: tex

;;; Commentary:

;; This file adds support for `scrartcl.cls'. This file needs
;; `scrbase.el'.

;; This file is part of  AUCTeX.

;;; Code:
(TeX-add-style-hook "scrartcl"
   (lambda ()
     (setq LaTeX-largest-level (LaTeX-section-level "section"))
     ;; load basic definitons
     (TeX-run-style-hooks "scrbase")))

;;; scrartcl.el ends here
