;;;* Last edited: Jul 22 14:28 1992 (krab)
;;;;;;;;;;;;;;;;;;;;;;;;;;; -*- Mode: Emacs-Lisp -*- ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; tex-buf.el - Invoking TeX from an inferior shell
;; 
;; Copyright (C) 1991 Kresten Krab Thorup (krab@iesd.auc.dk).
;; 
;; This file is part of the AUC TeX package.
;; 
;; $Id: tex-buf.el,v 1.18 1992-09-09 20:55:42 amanda Exp $
;; Author          : Kresten Krab Thorup
;; Created On      : Thu May 30 23:57:16 1991
;; Last Modified By: Per Abrahamsen
;; this file so that you can know how you may redistribute it all.
;; It should be in a file named COPYING.  Among other things, the
;; copyright notice and this notice must be preserved on all copies.
;;
;; This software was written as part of the author's official duty as
;; an employee of the University of Aalborg (denmark) and is in the
;; public domain.  You are free to use this software as you wish, but
;; WITHOUT ANY WARRANTY WHATSOEVER.  It would be nice, though if when
;; you use this code, you give due credit to the author.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; THE GOOD GUYS
;;
;;  Martin Simons             <simons@karlsruhe.gmd.de>
;;  George Ferguson           <ferguson@cs.rochester.edu>
;;  Ralf Handl                <handl@cs.uni-sb.de>
;;  Sven Mattisson            <sven@tde.lth.se>
;;  Denys Duchier             <dduchier@csi.UOttawa.CA>
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar TeX-master-file nil "\
Master file to run TeX-command on if different from buffer-file-name.")
(make-variable-buffer-local 'TeX-master-file)

(defvar TeX-master-command nil "\
TeX-command to use on TeX-master-file.")
(make-variable-buffer-local 'TeX-master-command)

(defvar TeX-master-preview-command nil "\
TeX-preview-command to use on TeX-master-file.")
(make-variable-buffer-local 'TeX-preview-command)

(defvar TeX-master-bibtex-command nil "\
TeX-bibtex-command to use on TeX-master-file.")
(make-variable-buffer-local 'TeX-bibtex-command)

(defvar TeX-master-index-command nil "\
TeX-index-command to use on TeX-master-file.")
(make-variable-buffer-local 'TeX-index-command)

(defvar TeX-current-page ""
  "The pagenumber currently being formatted, enclosed in brackets")

(defvar TeX-running nil
  "Last command run from AUC TeX.  May be 'tex or 'lacheck")

;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'tex-site)

(defvar TeX-process nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-buffer-directory (buffer directory)
  "Set BUFFER's default directory to be DIRECTORY."
  (setq directory (file-name-as-directory (expand-file-name directory)))
  (if (not (file-directory-p directory))
      (error "%s is not a directory" directory)
    (save-excursion
      (set-buffer buffer)
      (setq default-directory directory))))

(defun TeX-build-command (command file)
  "Replace the substring %s in COMMAND with FILE if present, 
otherwise append it separated by a space.  Return a list 
containing each space separated word in the resulting string. 
FILE is never split."
  (if (string-match " *%s *" command)
      (append (split-string "  *" (substring command 0 (match-beginning 0)))
	      (list file)
	      (if (< (match-end 0) (length command))
		  (split-string "  *" (substring command (match-end 0)))
		nil))
    (append (split-string "  *" command) (list file))))

(defun TeX-type-command (string command file)
  "Print STRING followed by COMMAND with FILE inserted, as done by 
TeX-build-command in the minibuffer."
  (format string 
	  (apply 'concat
		 (mapcar '(lambda (a) (concat " " a))
			 (TeX-build-command command file)))))

(defun TeX-home-buffer ()
  "Go back to buffer most recent run by TeX"
  (interactive)
  (cond
   (TeX-original-file
    (find-file (expand-file-name TeX-original-file TeX-start-directory)))
   (t (message "TeX hasn't been run..."))))

(defun TeX-test-process ()
  "Internal function to test if a TeX process is already running"
  (if TeX-process
      (if (or (not (eq (process-status TeX-process) 'run))
	      (y-or-n-p (concat "Process \""
				(process-name TeX-process)
				"\" is running; kill it? ")))
	  (condition-case ()
	      (let ((comp-proc TeX-process))
		(interrupt-process comp-proc)
		(sit-for 1)
		(delete-process comp-proc))
	    (error nil))
	(error "Cannot have two TeX processes")))
  (setq TeX-process nil))

(defun TeX-fix-process (mode)
  "Internal function to set up sentinel etc."
  (set-process-sentinel TeX-process 'TeX-compilation-sentinel)
  (save-excursion
    (set-buffer (process-buffer TeX-process))
    (fundamental-mode)
    (setq mode-name mode)
    ;; Make log buffer's mode line show process state
    (setq TeX-current-page "[0]")
    (TeX-update-process-mode-line TeX-process)
    ;(set-process-filter TeX-process 'TeX-process-filter)
    (goto-char (point-min))))

(defvar TeX-trailer nil
  "String searched to determine if there is a trailer in the current region.
If the file specified by TeX-auto-trailer is missing, this string is appended
before the file is sent to TeX. Used by \\[TeX-region].")

(defvar TeX-original-file nil)

(defvar TeX-start-of-header nil
  "String used by \\[TeX-region] to delimit the start of the file's header.")

(defvar TeX-end-of-header nil
  "String used by \\[TeX-region] to delimit the end of the file's header.")

(defconst TeX-directory "."
  "Directory in which to run TeX subjob.  Temporary files are
created in this directory. Should always be \".\"")

;; Mon Mar  9 20:41:52 1992
;; marsj@ida.liu.se
;; - create local variable, to enable multiple dvips files.
;;
;;(defvar TeX-zap-file nil
;;  "Temporary file name used for text being sent as input to TeX.
;;Should be a simple file name with no extension or directory specification.")
;;

(defun TeX-region (beg end)
  "Run TeX on the current region.  A temporary file (TeX-zap-file) is
written in directory TeX-directory, and TeX is run in that directory.
If the buffer has a header, it is written to the temporary file before
the region itself.  The buffer's header is all lines between the
strings defined by TeX-start-of-header and TeX-end-of-header
inclusive.  The header must start in the first 100 lines.  The value
of TeX-trailer is appended to the temporary file after the region.

If, in the first 500 bytes , there is a line like this:

%% Master: <file>

Then the header/trailer will be searched in <file>."
  (interactive "r")
  (save-some-buffers)
  (setq TeX-start-line (+ 1 (count-lines (point-min) beg)))
  (TeX-test-process)
  (setq TeX-original-file (buffer-name nil))
  (setq TeX-zap-file (make-temp-name TeX-default-jobname-prefix))
  (let ((TeX-out-file (concat TeX-zap-file ".tex"))
	(temp-buffer (get-buffer-create " TeX-Output-Buffer"))
	(zap-directory
	 (file-name-as-directory (expand-file-name TeX-directory)))
	(h1 TeX-h1)
	(h2 TeX-h2)
	(t1 TeX-t1)
	(t2 TeX-t2)
	(trailer TeX-trailer))
    
    ;;
    ;; now make a new file, and write `\nonstopmode{}' to it
    ;;
    (save-excursion
      (set-buffer temp-buffer)
      (erase-buffer)
      (insert h1)
      (set-buffer-directory temp-buffer zap-directory)
      (write-region (point-min) (point-max) TeX-out-file nil "no msg")
      (setq TeX-header-lines (- (count-lines (point-min) (point-max)) 1)))
    
    ;;
    ;; First look for a header in the first 100 lines
    ;;
    (save-excursion
      (save-restriction
	(widen)	 ;; in the entire document
	(goto-char (point-min))
	(forward-line 100)
	(let ((search-end (point))
	      (hbeg (point-min))
	      (hend (point-min))
	      (default-directory zap-directory))
	  
	  ;;
	  ;; Chech for Master document 
	  ;;
	  (save-excursion
	    (goto-char (point-min))
	    (setq master-buffer
		  (if (re-search-forward 
		       "^%% *[Mm]aster:?[ \t]*\\([^ \t\n]+\\)" 500 t)
		      (find-file-noselect (buffer-substring (match-beginning 1)
							    (match-end 1)))
		    (current-buffer))))
	  
	  ;;
	  ;; Initialize the temp file with either the header or an `\input-ed'
	  ;; header file. 
	  ;;
	  
	  ;; Is there a header in this document ?
	  
	  (save-excursion
	    (set-buffer master-buffer)
	    (goto-char (point-min))
	    (if (search-forward TeX-start-of-header search-end t)
		
		;; If so, then write it to the file
		(progn
		  (beginning-of-line)
		  (setq hbeg (point))	;mark beginning of header
		  (if (search-forward TeX-end-of-header nil t)
		      (let (buffer-read-only (flag (buffer-modified-p)))
			(insert "\n")
			(setq hend (point)) ;mark end of header
			(write-region (min hbeg beg) hend TeX-out-file t nil)
			(setq TeX-header-lines
			      (+ TeX-header-lines
				 (count-lines (min hbeg beg) hend) 1))
			(backward-delete-char 1)
			(set-buffer-modified-p flag))))
	      
	      
	      ;; otherwise, insert `\input{TeX-auto-header}{}', in the tmp
	      ;; buffer, and append that to the temporary file.
	      (progn (setq hbeg (point-min))
		     (save-excursion
		       (set-buffer temp-buffer)
		       (erase-buffer)
		       (insert h2)
		       (goto-char (point-max))
		       (insert t1)
		       (set-buffer-directory temp-buffer zap-directory)
		       (write-region (point-min)
				     (point-max)
				     (concat TeX-out-file) t "no msg")
		       ;; Increment the line number
		       (setq TeX-header-lines
			     (+ TeX-header-lines
				(count-lines (min hbeg beg) hend) 1))))))
	  
	  ;;
	  ;; Now, append the main body of the document to the file
	  ;;
	  
 	  (write-region (if (eq master-buffer
 				(current-buffer))
 			    (max beg hend)
			  beg)
			end
			TeX-out-file t "no msg"))
	
	
	;;
	;; For the trailer, we'll see if we can find it...
	;;
	(save-excursion
	  (set-buffer master-buffer)
	  (goto-char (point-max))  ;; end of given region
	  (cond ((search-forward trailer nil t)
		 (set-buffer temp-buffer)
		 (erase-buffer)
		 ;; make sure trailer isn't hidden by a comment
		 (insert "\n")
		 (insert trailer)
		 (set-buffer-directory temp-buffer zap-directory)
		 (write-region (point-min)
			       (point-max)
			       TeX-out-file t "no msg"))
		(t
		 (set-buffer temp-buffer)
		 (erase-buffer)
		 ;; make sure trailer isn't hidden by a comment
		 (insert "\n")
		 (insert t2)
		 (set-buffer-directory temp-buffer zap-directory)
		 (write-region (point-min)
			       (point-max)
			       TeX-out-file t "no msg"))))))
    (setq TeX-start-line (- TeX-start-line TeX-header-lines))
    
    ;; 
    ;; And now - go for a run!
    ;;
    
    (message (TeX-type-command "Running %s" TeX-command TeX-out-file))
      
    (setq TeX-process
	  (apply 'start-process 
		 "TeX-run" 
		 "*TeX-output*"
		 (TeX-build-command TeX-command TeX-out-file)))
    (with-output-to-temp-buffer "*TeX-output*"))
  
  (TeX-fix-process "Compilation")
  (setq TeX-new-run t)
  (setq TeX-running 'tex)
  (setq TeX-start-directory (expand-file-name TeX-directory)))

(defun TeX-compilation-sentinel (proc msg)
  (cond ((null (buffer-name (process-buffer proc)))
	 ;; buffer killed
	 (set-process-buffer proc nil))
	((memq (process-status proc) '(signal exit))
	 (let* ((obuf (current-buffer))
		omax opoint)
	   ;; save-excursion isn't the right thing if
	   ;;  process-buffer is current-buffer
	   (unwind-protect
	       (progn
		 (set-buffer (process-buffer proc))
		 (goto-char (point-min))
		 (cond ((and (or (string= mode-name "Compilation")
				 (string= mode-name "Formatting"))
			     (re-search-forward "^! " nil t))
			(message
			 (concat mode-name ": ERRORS                      "
				 "    (NB: use C-c C-n to display)")))
		       ((re-search-forward "^LaTeX Warning: \\(Reference\\|Label(s)\\)" nil t)
			(message (concat "You should run LaTeX again"
					 " to get references right.")))
		       ((re-search-forward "^LaTeX Warning: Citation" nil t)
			(message (concat "You should run BibTeX"
					 " to get citations right.")))
		       ((and (or (string= mode-name "Compilation")
				 (string= mode-name "Formatting"))
			     (re-search-forward "^LaTeX Version" nil t))
			(message
			 (concat mode-name ": successfully ended.")))
		       ((string= mode-name "BibTeX")
			(message (concat "You should perhaps run LaTeX again"
					 " to get citations right."))))
		 
		 ;; Write something in *compilation* and hack its mode line,
		 (setq omax (point-max) opoint (point))
		 (goto-char (point-max))
		 (insert ?\n mode-name " " msg)
		 (forward-char -1)
		 (insert " at "
			 (substring (current-time-string) 0 -5))
		 (forward-char 1)

		 (TeX-update-process-mode-line proc)
		 
		 ;; If buffer and mode line will show that the process
		 ;; is dead, we can delete it now.  Otherwise it
		 ;; will stay around until M-x list-processes.
		 (delete-process proc)
		 (setq compilation-process nil)
		 ;; Force mode line redisplay soon
		 (set-buffer-modified-p (buffer-modified-p)))
	     (if (and opoint (< opoint omax))
		 (goto-char opoint))
	     (set-buffer obuf))))))

(defun TeX-buffer ()
  "Run TeX on current buffer.  See \\[TeX-region] for more information.
This function was heavily modified by gf so that when formatting an
entire file, it uses the normal auxiliary and output files rather than
some strange temporary file. Thus, the results are just like running the
formatter from the shell.

If a line in the first 500 bytes of the buffer is:

%% Master: <file>

TeX/LaTeX will be run on <file> instead of the current."
  (interactive)
  (save-some-buffers)
  (TeX-test-process)
  ;; no need to calculate this for whole buffer
  (setq TeX-start-line 0)
  (setq TeX-header-lines 0)
  (save-excursion
    (goto-char (point-min))
    (setq TeX-original-file 
	  (if (re-search-forward 
	       "^%% *[Mm]aster:?[ \t]*\\([^ \t\n]+\\)" 500 t)
	      (buffer-substring (match-beginning 1) (match-end 1))
	    (file-name-nondirectory buffer-file-name))))
  (hack-local-variables)
  (if TeX-master-file
      (setq TeX-original-file (file-name-nondirectory TeX-master-file)))
  ;; no temp file needed since we're doing it all
  (setq TeX-zap-file (substring TeX-original-file 0
				(string-match ".[^.]*$" TeX-original-file)))
;;; Find out what TeX-command to use
  (if TeX-master-command
      (setq TeX-command TeX-master-command))
;;;
  ;; no header/trailer garbage either
  (let ((temp-buffer (get-buffer-create " TeX-Output-Buffer"))
	(zap-directory
	 (file-name-as-directory (expand-file-name TeX-directory))))
    (message (concat "Formatting " TeX-original-file))
    (setq TeX-process
	  (apply 'start-process 
		 "TeX-run" 
		 "*TeX-output*" 
		 (TeX-build-command TeX-command
				    (concat "\\nonstopmode{}\\input "
					    TeX-original-file))))
    (with-output-to-temp-buffer "*TeX-output*"))
  (TeX-fix-process "Formatting")
  (setq TeX-new-run t)
  (setq TeX-running 'tex)
  (setq TeX-start-directory (expand-file-name TeX-directory)))

(defun TeX-kill-job ()
  "Kill the currently running TeX job."
  (interactive)
  (quit-process (process-name TeX-process) t))

(defun TeX-recenter-output-buffer (linenum)
  "Redisplay buffer of TeX job output so that most recent output can be seen.
The last line of the buffer is displayed on
line LINE of the window, or at bottom if LINE is nil."
  (interactive "P")
  (let ((TeX-shell (get-buffer "*TeX-output*"))
	(old-buffer (current-buffer)))
    (if (null TeX-shell)
	(message "No TeX output buffer")
      (pop-to-buffer TeX-shell)
      (bury-buffer TeX-shell)
      (goto-char (point-max))
      (recenter (if linenum
		    (prefix-numeric-value linenum)
		  (/ (window-height) 2)))
      (pop-to-buffer old-buffer)
      )))

(defun TeX-process-filter (proc str)
  (let ((cur (selected-window))
	(pos))
    (set-buffer (process-buffer proc))
    (goto-char (point-max))
    (insert str)
    (save-excursion
      (cond ((re-search-backward "\\[[0-9]+\\(\\.[0-9\\.]+\\)?\\]" nil t)
	     (setq TeX-current-page
		   (buffer-substring (match-beginning 0)
				     (match-end 0)))
	     (TeX-update-process-mode-line proc)
	     ;; Return to last position
	     (goto-char (point-max)))))
    (set-buffer-modified-p (buffer-modified-p))
    (select-window cur)))

(defun TeX-update-process-mode-line (proc)
  (setq mode-line-process (concat ;; TeX-current-page
			   ": "
				  (symbol-name
				   (process-status proc))))
  ;; Force mode line redisplay soon
  (set-buffer-modified-p (buffer-modified-p)))

(defun TeX-preview ()
  "Preview the .dvi file made by \\[TeX-region] or \\[TeX-buffer]."
  (interactive)
  
  (if (and (not TeX-original-file)
	   (buffer-file-name))
      (setq TeX-original-file (buffer-file-name)))
  
  (TeX-test-process)
  
;;; Find out what preview command to use
  (hack-local-variables)
  (if TeX-master-preview-command
      (setq TeX-preview-command TeX-master-preview-command)
    (let ((alist TeX-preview-alist)
	  (do-search t))
      (save-excursion
	(save-restriction
	  (set-buffer (find-file-noselect TeX-original-file))
	  (widen)
	  (goto-char (point-min))
	  (while (and do-search alist)
	    (if (not (re-search-forward (car (car alist)) (point-max) t))
		(setq alist (cdr alist))	; try next regexp
	      (setq do-search nil))))) ; found one, quit master-buffer
      (if alist			; we have a match, set
	  (setq TeX-preview-command (symbol-value (cdr (car alist)))))))
;;;
  (process-kill-without-query
   (apply 'start-process
	  "preview"
	  "*TeX-output*"
	  (TeX-build-command TeX-preview-command
			     (concat TeX-zap-file ".dvi"))))

  (with-output-to-temp-buffer "*TeX-output*"
    (princ (TeX-type-command "Started %s; process is \"preview\"\n"
			     TeX-preview-command
			     (concat TeX-zap-file ".dvi")))))

(defun TeX-print ()
  "Print the .dvi file made by \\[TeX-region] or \\[TeX-buffer].
This command will not work under bash"
  (interactive)
  
  (TeX-test-process)
  
  (let* (				; Ask for a printer
	 (tmp1 (if TeX-printer-name-alist
		   (completing-read (concat "Printer: (default "
					    TeX-default-printer-name
					    ") ")
				    TeX-printer-name-alist)
		 ""))
					; If "", use default
	 (printer (if (string= tmp1 "")
		      TeX-default-printer-name
		    tmp1))
					; Insert printer in command
	 (tmp2 (if (string-match "%p" TeX-print-command)
		   (concat (substring TeX-print-command
				      0 (match-beginning 0))
			   printer
			   (substring TeX-print-command (match-end 0)))
		 (concat TeX-print-command " -P" printer)))
					; Insert file in command
	 (tmp3 (if (string-match "%s" tmp2)
		   (concat (substring tmp2 0 (match-beginning 0))
			   TeX-zap-file ".dvi"
			   (substring tmp2 (match-end 0)))
		 (concat tmp2 " " TeX-zap-file ".dvi")))
					; Make user confirm command
	 (command (read-from-minibuffer "Print command: " tmp3)))
	 
    ;; Let the last selected be the default from now on...
    (setq TeX-default-printer-name printer)
    
    (setq TeX-process
	  (apply 'start-process 
		 "printing"
		 "*TeX-output*"
		 (split-string "  *" command)))
    (with-output-to-temp-buffer "*TeX-output*"
      (princ (format "Started %s; process is \"printing\"\n" command)))
    
    (TeX-fix-process "printing")))

(defun LaTeX-bibtex ()
  "Run BibTeX on file made by \\[TeX-region] or \\[TeX-buffer]."
  (interactive)
  (TeX-filter TeX-bibtex-command "BibTeX"))

(defun LaTeX-makeindex ()
  "Run Makeindex on file made by \\[TeX-buffer]."
  (interactive)
  (TeX-filter TeX-index-command "Makeindex"))

(defun TeX-filter (filter &optional name)
  "Run FILTER on the current buffer (with processname NAME)
(options for FILTER is not allowed.)"
  (interactive "s")
  (or name (setq name filter))
  (TeX-test-process)
  (hack-local-variables)
  (if TeX-master-bibtex-command
      (setq TeX-bibtex-command TeX-master-bibtex-command))
  (hack-local-variables)
  (if TeX-master-index-command
      (setq TeX-index-command TeX-master-index-command))
  (setq TeX-process
	(start-process name "*TeX-output*"
				    filter
				    TeX-zap-file ))
  (with-output-to-temp-buffer "*TeX-output*")
  (TeX-fix-process name))

(defun TeX-run-lacheck ()
  "Run LaCheck on the current document"
  (interactive)
  (setq TeX-running 'lacheck)
  (save-excursion
    (goto-char (point-min))
    (let ((lacheck-buffer
	   (if (re-search-forward 
		"^%% *[Mm]aster:?[ \t]*\\([^ \t\n]+\\)" 500 t)
	       (buffer-substring (match-beginning 1)
				 (match-end 1))
	     (buffer-file-name (current-buffer)))))
      (compile (format "lacheck %s" lacheck-buffer)))))

