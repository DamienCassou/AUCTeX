;;; @ j-article.el - Special code for j-article style.
;;;
;;; $Id: j-article.el,v 1.2 1993-07-07 00:41:43 amanda Exp $

;;; @@ Hook

(TeX-add-style-hook "j-article"
 (function (lambda ()
  (setq LaTeX-largest-level (LaTeX-section-level "section")))))

;;; @@ Emacs

;;; Local Variables:
;;; mode: emacs-lisp
;;; mode: outline-minor
;;; outline-regexp: ";;; @+\\|(......"
;;; End:
