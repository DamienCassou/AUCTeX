;;; @ book.el - Special code for book style.
;;;
;;; $Id: book.el,v 1.3 1993-07-07 00:41:42 amanda Exp $

;;; @@ Hook

(TeX-add-style-hook "book"
 (function (lambda () 
  (setq LaTeX-largest-level (LaTeX-section-level "chapter")))))

;;; @@ Emacs

;;; Local Variables:
;;; mode: emacs-lisp
;;; mode: outline-minor
;;; outline-regexp: ";;; @+\\|(......"
;;; End:
