;;; pdfsync.el --- AUCTeX style for `pdfsync.sty'

;; Copyright (C) 2005 Free Software Foundation, Inc.

;; Author: Ralf Angeli <angeli@iwi.uni-sb.de>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2005-12-28
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

;; This file adds support for `pdfsync.sty'.

;;; Code:

(defun LaTeX-pdfsync-output-page ()
  "Return page number in output file corresponding to buffer position."
  (let* ((file (file-name-sans-extension
		(file-name-nondirectory (buffer-file-name))))
	 (line (line-number-at-pos))
	 (master (TeX-active-master))
	 (pdfsync-file (concat master ".pdfsync"))
	 (sync-line "-1")
	 (sync-page "1")
	 sync-record last-match)
    (when (file-exists-p pdfsync-file)
      (with-current-buffer (find-file-noselect pdfsync-file)
	(save-restriction
	  (goto-char (point-min))
	  ;; Narrow region to file in question.
	  (when (not (string= file master))
	    (re-search-forward (concat "^(" file "$") nil t)
	    (let ((beg (match-beginning 0)))
	      (goto-char beg)
	      (narrow-to-region (line-beginning-position 2)
				(progn (forward-sexp) (point))))
	    (goto-char (point-min)))
	  ;; Look for the record number.
	  (catch 'break
	    (while (re-search-forward "^(\\|^l \\([0-9]+\\) \\([0-9]+\\)" nil t)
	      (cond ((string= (match-string 0) "(")
		     (goto-char (match-beginning 0))
		     (forward-sexp))
		    ((> (string-to-number (match-string 2)) line)
		     (throw 'break nil))
		    (t
		     (setq sync-record (match-string 1)
			   sync-line (match-string 2)
			   last-match (match-beginning 0))))))
	  ;; Look for the page number.
	  (goto-char (or last-match (point-min)))
	  (catch 'break
	    (while (re-search-forward "^p \\([0-9]+\\)" nil t)
	      (when (>= (string-to-number (match-string 1))
			(string-to-number sync-record))
		(re-search-backward "^s \\([0-9]+\\)" nil t)
		(setq sync-page (match-string 1))
		(throw 'break nil)))))))
    sync-page))

(TeX-add-style-hook
 "pdfsync"
 (lambda ()
   (setq TeX-sync-output-page-function 'LaTeX-pdfsync-output-page)))

;;; pdfsync.el ends here
