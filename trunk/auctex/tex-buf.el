;;; @ tex-buf.el - External commands for AUC TeX.
;;;
;;; $Id: tex-buf.el,v 1.29 1993-03-28 15:40:58 amanda Exp $

(provide 'tex-buf)
(require 'tex-site)

;;; @@ Copyright
;;;
;;; Copyright (C) 1991 Kresten Krab Thorup
;;; Copyright (C) 1993 Per Abrahamsen 
;;; 
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;; 
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;; 
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; @@ Customization

(defvar TeX-process-asynchronous (not (eq system-type 'ms-dos))
  "*Use asynchronous processes.")

(defvar shell-command-option "-c"
  "DEMACS stuff.")

;;; @@ Interactive Commands
;;;
;;; The general idea is, that there is one process and process buffer
;;; associated with each master file, and one process and process buffer
;;; for running TeX on a region.   Thus, if you have N master files, you
;;; can run N + 1 processes simultaneously.  
;;;
;;; Some user commands operates on ``the'' process.  The following
;;; algorithm determine what ``the'' process is.
;;;
;;; IF   last process started was on a region 
;;; THEN ``the'' process is the region process
;;; ELSE ``the'' process is the master file (of the current buffer) process

(defun TeX-command-master ()
  "Run command on the current document."
  (interactive)
  (setq TeX-current-process-region-p nil)
  (TeX-command (TeX-command-query (TeX-master-file)) 'TeX-master-file))

(defun TeX-command-region (old)
  "Run TeX on the current region.

Query the user for a command to run on the temporary file specified by
the variable TeX-region.  If the chosen command is so marked in
TeX-command-list, and no argument (or nil) is given to the command,
the region file file be recreated with the current region.

If the master file for the document has a header, it is written to the
temporary file before the region itself.  The documents header is all
text until TeX-header-end.

If the master file for the document has a trailer, it is written to
the temporary file before the region itself.  The documents trailer is
all text after TeX-trailer-start."
  (interactive "P")
  (setq TeX-current-process-region-p t)
  (let ((command (TeX-command-query (TeX-region-file))))
    (if (and (nth 4 (assoc command TeX-command-list))
	     (null old))
	(if (null (mark))
	    (error "Mark not set.")
	  (let ((begin (min (point) (mark)))
		(end (max (point) (mark))))
	    (TeX-region-create (TeX-region-file "tex")
			       (buffer-substring begin end)
			       (file-name-nondirectory (buffer-file-name))
			       (count-lines (point-min) begin)))))
    (TeX-command command 'TeX-region-file)))

(defun TeX-recenter-output-buffer (line)
  "Redisplay buffer of TeX job output so that most recent output can be seen.
The last line of the buffer is displayed on line LINE of the window, or
at bottom if LINE is nil." 
  (interactive "P")
  (let ((buffer (TeX-active-buffer)))
    (if buffer
	(let ((old-buffer (current-buffer)))
	  (pop-to-buffer buffer t)
	  (bury-buffer buffer)
	  (goto-char (point-max))
	  (recenter (if line
			(prefix-numeric-value line)
		      (/ (window-height) 2)))
	  (pop-to-buffer old-buffer))
      (message "No process for this document."))))

(defun TeX-kill-job ()
  "Kill the currently running TeX job."
  (interactive)
  (let ((process (TeX-active-process)))
    (if process
	(kill-process process)
      ;; Should test for TeX background process here.
      (error "No TeX process to kill."))))

(defun TeX-home-buffer (arg)
  "Go to the buffer where you last issued a TeX command.  
If there is no such buffer, or you already are in that buffer, find
the master file."
  (interactive "P")

  (if (or (null TeX-command-buffer)
	  (eq TeX-command-buffer (current-buffer)))
      (find-file (TeX-master-file "tex"))
    (switch-to-buffer TeX-command-buffer)))

(defun TeX-next-error (reparse)
  "Find the next error in the TeX output buffer.
Prefix by C-u to start from the beginning of the errors."
  (interactive "P")
  (if (null (TeX-active-buffer))
      (error "No TeX output buffer.")
    (funcall (TeX-process-get-variable (TeX-active-master) 'TeX-parse-hook)
	     reparse)))

(defun TeX-toggle-debug-boxes ()
  "Toggle if the debugger should display \"bad boxes\" too."
  (interactive)
  (cond (TeX-debug-bad-boxes
	 (setq TeX-debug-bad-boxes nil))
	(t
	 (setq TeX-debug-bad-boxes t)))
  (message (concat "TeX-debug-bad-boxes: " (cond (TeX-debug-bad-boxes "on")
						 (t "off")))))

;;; @@ Command Query

(defun TeX-command (name file)
  "Run command NAME on the file you get by calling FILE.

FILE is a function return a file name.  It has one optional argument,
the extension to use on the file.

Use the information in TeX-command-list to determine how to run the
command."
  (let ((command (TeX-command-expand (nth 1 (assoc name TeX-command-list))
				     file))
	(hook (nth 2 (assoc name TeX-command-list)))
	(confirm (nth 3 (assoc name TeX-command-list))))

    ;; Verify the expanded command
    (if confirm
	(setq command
	      (read-from-minibuffer (concat name " command: ") command)))
    
    ;; Now start the process
    (let ((buffer (current-buffer)))
      (TeX-process-set-variable name 'TeX-command-next TeX-command-default)
      (apply hook name command (apply file nil) nil)
      (pop-to-buffer buffer))))

(defun TeX-command-expand (command file &optional list)
  "Expand COMMAND for FILE as described in LIST.
LIST default to TeX-expand-list."
  (if (null list)
      (setq list TeX-expand-list))
  (while list
    (let ((string (car (car list)))	;First element
	  (expansion (car (cdr (car list)))) ;Second element
	  (arguments (cdr (cdr (car list))))) ;Remaining elements
      (while (string-match string command)
	(let ((prefix (substring command 0 (match-beginning 0)))
	      (postfix (substring command (match-end 0))))
	  (setq command (concat prefix
				(cond ((or (listp expansion)
					   (fboundp expansion))
				       (apply expansion arguments))
				      ((boundp expansion)
				       (apply (eval expansion) arguments))
				      (t
				       (error "Nonexpansion %s." expansion)))
				postfix)))))
    (setq list (cdr list)))
  command)

(defun TeX-command-query (name)
  "Query the user for a what TeX command to use."
  (let* ((default (cond ((buffer-modified-p)
			 TeX-command-default)
			((TeX-process-get-variable name
						   'TeX-command-next
						   TeX-command-default))
			(TeX-command-default)))
	 (completion-ignore-case t)
	 (answer (completing-read (concat "Command: (default " default  ") ")
				  TeX-command-list nil t)))
    (if (and answer
	     (not (string-equal answer "")))
	answer
      default)))

(defvar TeX-command-next nil
  "The default command next time TeX-command is invoked.")

 (make-variable-buffer-local 'TeX-command-next)

(defun TeX-printer-query ()
  "Query the user for a printer name."

  (let ((printer (if TeX-printer-list
		     (let ((completion-ignore-case t))
		       (completing-read (concat "Printer: (default "
						TeX-printer-default ") ")
					TeX-printer-list
					nil t))
		   "")))
    (if (string-equal "" printer)
	(setq printer TeX-printer-default)
      (setq TeX-printer-default printer))

    (let ((expansion (let ((entry (assoc printer TeX-printer-list)))
		       (if (and entry (nth 1 entry))
			   (nth 1 entry)
			 TeX-print-command))))
      (if (string-match "%p" expansion)
	  (concat (substring expansion 0 (match-beginning 0))
		  printer
		  (substring expansion (match-end 0)))
	expansion))))

(defun TeX-style-check (styles)
  "Check STYLES compared to the current style options."

  (let ((files (TeX-style-list)))
    (while (and styles
		(not (TeX-member (car (car styles)) files 'string-match)))
      (setq styles (cdr styles))))
  (if styles
      (nth 1 (car styles))
    ""))

;;; @@ Command Hooks

(defun TeX-command-hook (name command file)
  "Create a process for NAME using COMMAND to process FILE.
Return the new process."
  (let ((default TeX-command-default)
	(buffer (TeX-process-buffer-name file)))
    (TeX-process-check file)		; Check that no process is running
    (setq TeX-command-buffer (current-buffer))
    (pop-to-buffer (get-buffer-create buffer) t)
    (erase-buffer)
    (insert "Running `" name "' on `" file "' with ``" command "''\n")
    (setq mode-name name)
    (setq TeX-parse-hook 'TeX-parse-command)
    (setq TeX-command-default default)
    (if TeX-process-asynchronous
	(let ((process (start-process name buffer "sh" "-c" command)))
	  (TeX-command-mode-line process)
	  (set-process-filter process 'TeX-command-filter)
	  (set-process-sentinel process 'TeX-command-sentinel)
	  process)
      (setq mode-line-process ": run")
      (set-buffer-modified-p (buffer-modified-p))
      (sit-for 0)				; redisplay
      (call-process
       shell-file-name nil buffer nil shell-command-option command))))

(defun TeX-format-hook (name command file)
  "Create a process for NAME using COMMAND to format FILE with TeX."
  (let ((process (TeX-command-hook name command file)))
    ;; Hook to TeX debuger.
    (setq TeX-parse-hook 'TeX-parse-TeX)
    (TeX-parse-reset)
    (if TeX-process-asynchronous
	(progn
	  ;; Updating the mode line.
	  (setq TeX-current-page "[0]")
	  (TeX-format-mode-line process)
	  (set-process-filter process 'TeX-format-filter)))
    process))

(defun TeX-TeX-hook (name command file)
  "Create a process for NAME using COMMAND to format FILE with TeX."
  (let ((process (TeX-format-hook name command file)))
    (setq TeX-sentinel-hook 'TeX-TeX-sentinel)
    (if TeX-process-asynchronous
	process
      (TeX-synchronous-sentinel name file process))))

(defun TeX-LaTeX-hook (name command file)
  "Create a process for NAME using COMMAND to format FILE with TeX."
  (let ((process (TeX-format-hook name command file)))
    (setq TeX-sentinel-hook 'TeX-LaTeX-sentinel)
    (if TeX-process-asynchronous
	process
      (TeX-synchronous-sentinel name file process))))

(defun TeX-BibTeX-hook (name command file)
  "Create a process for NAME using COMMAND to format FILE with BibTeX."
  (let ((process (TeX-command-hook name command file)))
    (setq TeX-sentinel-hook 'TeX-BibTeX-sentinel)
    (if TeX-process-asynchronous
	process
      (TeX-synchronous-sentinel name file process))))

(defun TeX-compile-hook (name command file)
  "Ignore first and third argument, start compile with second argument."
  (compile command))

(defun TeX-shell-hook (name command file)
  "Ignore first and third argument, start shell-command with second argument."
  (shell-command command)
  (if (eq system-type 'ms-dos)
      (redraw-display)))

(defun TeX-discard-hook (name command file)
  "Start process with second argument, discarding its output."
  (process-kill-without-query (start-process (concat name " discard")
					     nil "sh" "-c" command)))

(defun TeX-background-hook (name command file)
  "Start process with second argument, show output when and if it arrives."
  (let ((process (start-process (concat name " background")
				nil "sh" "-c" command)))
    (set-process-filter process 'TeX-background-filter)
    (process-kill-without-query process)))

;;; @@ Command Sentinels

(defun TeX-synchronous-sentinel (name file result)
  "Process TeX command output buffer after the process dies."
  (let* ((buffer (TeX-process-buffer file)))
    (save-excursion
      (set-buffer buffer)
      
      ;; Append post-mortem information to the buffer
      (goto-char (point-max))
      (insert "\n" mode-name (if (and result (zerop result))
				 " finished" " exited") " at "
	      (substring (current-time-string) 0 -5))
      (setq mode-line-process ": exit")
      
      ;; Do command specific actions.
      (setq TeX-command-next TeX-command-default)
      (goto-char (point-min))
      (apply TeX-sentinel-hook nil name nil)
      
      ;; Force mode line redisplay soon
      (set-buffer-modified-p (buffer-modified-p)))))

(defun TeX-command-sentinel (process msg)
  "Process TeX command output buffer after the process dies."
  (let* ((buffer (process-buffer process))
	 (name (process-name process)))
    (cond ((null (buffer-name buffer))	; buffer killed
	   (set-process-buffer process nil)
	   (set-process-sentinel process nil))
	  ((memq (process-status process) '(signal exit))
	   (save-excursion
	     (set-buffer buffer)
	     
	     ;; Append post-mortem information to the buffer
	     (goto-char (point-max))
	     (insert "\n" mode-name " " msg)
	     (forward-char -1)
	     (insert " at "
		     (substring (current-time-string) 0 -5))
	     (forward-char 1)
	     
	     ;; Do command specific actions.
	     (TeX-command-mode-line process)
	     (setq TeX-command-next TeX-command-default)
	     (goto-char (point-min))
	     (apply TeX-sentinel-hook process name nil)
	     
	     
	     ;; If buffer and mode line will show that the process
	     ;; is dead, we can delete it now.  Otherwise it
	     ;; will stay around until M-x list-processes.
	     (delete-process process)
	     
	     ;; Force mode line redisplay soon
	     (set-buffer-modified-p (buffer-modified-p)))))))

(defvar TeX-sentinel-hook (function (lambda (process name)))
  "Hook to cleanup TeX command buffer after temination of PROCESS.
NAME is the name of the process.  Point is set to   ")

 (make-variable-buffer-local 'TeX-sentinel-hook)

(defun TeX-TeX-sentinel (process name)
  "Cleanup TeX output buffer after running TeX.
Return nil ifs no errors were found."
  (if process (TeX-format-mode-line process))
  (if (re-search-forward "^! " nil t)
      (progn
	(message (concat name " errors in `" (buffer-name)
			 "'. Use C-c ` to display."))
	(setq TeX-command-next TeX-command-default)
	t)
    (setq TeX-command-next TeX-command-Show)
    nil))

(defun TeX-LaTeX-sentinel (process name)
  "Cleanup TeX output buffer after running LaTeX."
  (cond ((TeX-TeX-sentinel process name))
	((re-search-forward "^LaTeX Warning: Citation" nil t)
	 (message "You should run BibTeX to get citations right.")
	 (setq TeX-command-next TeX-command-BibTeX))
	((re-search-forward "^LaTeX Warning: \\(Reference\\|Label(s)\\)" nil t)
	 (message "You should run LaTeX again to get references right.")
	 (setq TeX-command-next TeX-command-default))
	((re-search-forward
	  "^\\(\\*\\* \\)?J?\\(La\\|Sli\\)TeX \\(Version\\|ver\\.\\)" nil t)
	 (message (concat name ": successfully ended."))
	 (setq TeX-command-next TeX-command-Show))
	(t
	 (message (concat name ": problems."))
	 (setq TeX-command-next TeX-command-default))))

(defun TeX-BibTeX-sentinel (process name)
  "Cleanup TeX output buffer after running BibTeX."
  (message "You should perhaps run LaTeX again to get citations right.")
  (setq TeX-command-next TeX-command-default))

;;; @@ Process Control

(defun TeX-process-get-variable (name symbol &optional default)
  "Return the value in the process buffer for NAME of SYMBOL.

Return DEFAULT if the process buffer does not exist or SYMBOL is not
defined."
  (let ((buffer (TeX-process-buffer name)))
    (if buffer
	(save-excursion
	  (set-buffer buffer)
	  (if (boundp symbol)
	      (eval symbol)
	    default))
      default)))

(defun TeX-process-set-variable (name symbol value)
  "Set the variable SYMBOL in the process buffer to VALUE.
Return nil iff no process buffer exist."
  (let ((buffer (TeX-process-buffer name)))
    (if buffer
	(save-excursion
	  (set-buffer buffer)
	  (set symbol value)
	  t)
      nil)))

(defun TeX-process-check (name)
  "Check if a process for the TeX document NAME already exist.
If so, give the user the choice of aborting the process or the current
command."
  (save-some-buffers)
  (let ((process (TeX-process name)))
    (cond ((null process))
	  ((not (eq (process-status process) 'run)))
	  ((yes-or-no-p (concat "Process `"
				(process-name process)
				"' for document `"
				name
				"' running, kill it? "))
	   (delete-process process))
	  (t
	   (error "Cannot have two processes for the same document.")))))

(defun TeX-process-buffer-name (name)
  "Return name of AUC TeX buffer associated with the document NAME."
  (concat "*" (expand-file-name name) " output*"))

(defun TeX-process-buffer (name)
  "Return the AUC TeX buffer associated with the document NAME."
  (get-buffer (TeX-process-buffer-name name)))

(defun TeX-process (name)
  "Return AUC TeX process associated with the document NAME."
  (get-buffer-process (TeX-process-buffer name)))

;;; @@ Process Filters

(defun TeX-command-mode-line (process)
  "Format the mode line for a buffer containing output from PROCESS."
    (setq mode-line-process (concat ": "
				    (symbol-name (process-status process))))
    (set-buffer-modified-p (buffer-modified-p)))

(defun TeX-command-filter (process string)
  "Filter to process normal output."
  (save-excursion
    (set-buffer (process-buffer process))
    (goto-char (point-max))
    (insert string)
    (save-excursion)
    ))

(defvar TeX-current-page nil
  "The page number currently being formatted, enclosed in brackets.")

 (make-variable-buffer-local 'TeX-current-page)

(defun TeX-format-mode-line (process)
  "Format the mode line for a buffer containing TeX output from PROCESS."
    (setq mode-line-process (concat " " TeX-current-page ": "
				    (symbol-name (process-status process))))
    (set-buffer-modified-p (buffer-modified-p)))

(defun TeX-format-filter (process string)
  "Filter to process TeX output."
  (save-excursion
    (set-buffer (process-buffer process))
    (goto-char (point-max))
    (insert string)
    (save-excursion 
      (if (re-search-backward "\\[[0-9]+\\(\\.[0-9\\.]+\\)?\\]" nil t)
	  (let ((new (TeX-match-buffer 0)))
	    (if (not (string-equal new TeX-current-page))
		(setq TeX-current-page new)))))
    (TeX-format-mode-line process)))

(defvar TeX-parse-hook nil
  "Function to call to parse content of TeX output buffer.")

 (make-variable-buffer-local 'TeX-parse-hook)

(defun TeX-background-filter (process string)
  "Filter to process background output."
  (let ((old-window (selected-window))
	(pop-up-windows t))
    (pop-to-buffer "*TeX background*")
    (goto-char (point-max))
    (insert string)
    (select-window old-window)))


;;; @@ Active Process

(defvar TeX-current-process-region-p nil
  "This variable is set to t iff the last TeX command is on a region.")

(defun TeX-active-process ()
  "Return the active process for the current buffer."
  (if TeX-current-process-region-p
      (TeX-process (TeX-region-file))
    (TeX-process (TeX-master-file))))

(defun TeX-active-buffer ()
  "Return the buffer of the active process for this buffer."
  (if TeX-current-process-region-p
      (TeX-process-buffer (TeX-region-file))
    (TeX-process-buffer (TeX-master-file))))

(defun TeX-active-master (&optional extension)
  "The master file currently being compiled."
  (if TeX-current-process-region-p
      (TeX-region-file extension)
    (TeX-master-file extension)))

(defvar TeX-command-buffer nil
  "The buffer from where the last TeX command was issued.")

;;; @@ Region File

(defun TeX-region-create (file region original offset)
  "Create a new file named FILE with the string REGION
The region is taken from ORIGINAL starting at line OFFSET.

The current buffer and master file is searched, in order to ensure
that the TeX header and trailer information is also included.

The OFFSET is used to provide the debugger with information about the
original file."
  (let* (;; We shift buffer a lot, so we must keep track of the buffer
	 ;; local variables.  
	 (header-end TeX-header-end)
	 (trailer-start TeX-trailer-start)
	 
	 ;; We seach for header and trailer in the master file.
	 (master-name (TeX-master-file "tex"))
	 (master-buffer (find-file-noselect master-name))
	 
	 ;; And insert them into the FILE buffer.
	 (file-buffer (find-file-noselect file))
	 
	 ;; We search for the header from the master file, if it is
	 ;; not present in the region.
	 (header (if (string-match header-end region)
		     ""
		   (save-excursion
		     (save-restriction
		       (set-buffer master-buffer)
		       (goto-char (point-min))
		       ;; NOTE: We use the local value of
		       ;; TeX-header-end from the master file.
		       (if (not (re-search-forward TeX-header-end nil t))
			   ""
			 (beginning-of-line 2)
			 (buffer-substring (point-min) (point)))))))
	 
	 ;; We search for the trailer from the master file, if it is
	 ;; not present in the region.
	 (trailer-offset 0)
	 (trailer (if (string-match trailer-start region)
		      ""
		    (save-excursion
		      (save-restriction
			(set-buffer master-buffer)
			(goto-char (point-max))
			;; NOTE: We use the local value of
			;; TeX-trailer-start from the master file.
			(if (not (re-search-backward TeX-trailer-start nil t))
			    ""
			  (beginning-of-line 1)
			  (setq trailer-offset
				(count-lines (point-min) (point)))
			  (buffer-substring (point) (point-max))))))))
    (save-excursion
      (set-buffer file-buffer)
      (erase-buffer)
      (insert "\\message{ @name<" master-name ">}"
	      header
	      "\n\\message{ @name<" original "> @offset<")
      (insert (int-to-string (- offset
				(count-lines (point-min) (point))))
	      "> }\n"
	      region
	      "\n\\message{ @name<"  master-name "> @offset<")
      (insert (int-to-string (- trailer-offset
				(count-lines (point-min) (point))))
	      "> }\n"
	      trailer)
      (save-buffer 0))))

(defun TeX-region-file (&optional extension)
  "Return TeX-region file name with EXTENSION."
  (if extension
      (concat TeX-region "." extension)
    TeX-region))

(defvar TeX-region "_region_"
  "*Base name for temporary file for use with TeX-region.")

;;; @@ Parsing

;;; @@@ Customization

(defvar TeX-display-help t
  "*Non-nil means popup help when stepping thrugh errors with \\[TeX-next-error]")

(defvar TeX-debug-bad-boxes nil
  "*Non-nil means also find overfull/underfull boxes warnings with TeX-next-error")

;;; @@@ Global Parser Variables

(defvar TeX-error-point nil
  "How far we have parsed until now.")

 (make-variable-buffer-local 'TeX-error-point)

(defvar TeX-error-file nil
  "Stack of files in which errors have occured")

 (make-variable-buffer-local 'TeX-error-file)

(defvar TeX-error-offset nil
  "Add this to any line numbers from TeX.  Stack like TeX-error-file.")

 (make-variable-buffer-local 'TeX-error-offset)

(defun TeX-parse-reset ()
  "Reset all variables used for parsing TeX output."
  (setq TeX-error-point (point-min))
  (setq TeX-error-offset nil)
  (setq TeX-error-file nil))

;;; @@@ Parsers Hooks

(defun TeX-parse-command (reparse)
  "We can't parse anything but TeX."
  (error "I cannot parse %s output, sorry."
	 (if (TeX-active-process)
	     (process-name (TeX-active-process))
	   "this")))

(defun TeX-parse-TeX (reparse)
  "Find the next error produced by running TeX.
Prefix by C-u to start from the beginning of the errors.

If the file occurs in an included file, the file is loaded (if not
already in an Emacs buffer) and the cursor is placed at the error."

  (let ((old-buffer (current-buffer)))
    (pop-to-buffer (TeX-active-buffer))
    (if reparse
	(TeX-parse-reset))
    (goto-char TeX-error-point)
    (TeX-parse-error old-buffer)))

;;; @@@ Parsing (La)TeX

(defun TeX-parse-error (old)
  "Goto next error.  Pop to OLD buffer if no more errors are found."
    (while
	(progn
	  (re-search-forward (concat "\\("
				     "^! \\|"
				     "(\\|"
				     ")\\|"
				     "\\'\\|"
				     "@offset<[---0-9]*>\\|"
				     "@name<[^>]*>\\|"
				     "^.*erfull \\\\.*[0-9]*--[0-9]*"
				     "\\)"))
	  (let ((string (TeX-match-buffer 1)))

	    (cond (;; TeX error
		   (string= string "! ")
		   (TeX-error)
		   nil)

		  ;; LaTeX warning
		  ((string-match "^.*erfull \\\\.*[0-9]*--[0-9]*"
				 string)
		   (TeX-warning string))

		  ;; New file -- Push on stack
		  ((string= string "(")
		   (re-search-forward "\\([^()\n \t]*\\)")
		   (setq TeX-error-file
			 (cons (TeX-match-buffer 1) TeX-error-file))
		   (setq TeX-error-offset (cons 0 TeX-error-offset))
		   t)

		  ;; End of file -- Pop from stack
		  ((string= string ")")
		   (setq TeX-error-file (cdr TeX-error-file))
		   (setq TeX-error-offset (cdr TeX-error-offset))
		   t)

		  ;; Hook to change line numbers
		  ((string-match "@offset<\\([---0-9]*\\)>" string)
		   (rplaca TeX-error-offset
			   (string-to-int (substring string
						     (match-beginning 1)
						     (match-end 1))))
		   t)

		  ;; Hook to change file name
		  ((string-match "@name<\\([^>]*\\)>" string)
		   (rplaca TeX-error-file (substring string
						     (match-beginning 1)
						     (match-end 1)))
		   t)

		  ;; No more errors.
		  (t
		   (message "No more errors.")
		   (beep)
		   (pop-to-buffer old)
		   nil))))))

(defun TeX-error ()
  "Display an error."

  (let* (;; We need the error message to show the user.
	 (error (progn
		  (re-search-forward "\\(.*\\)")
		  (TeX-match-buffer 1)))

	 ;; And the context for the help window.
	 (context-start (point))

	 ;; And the line number to position the cursor.
	 (line (if (re-search-forward "l\\.\\([0-9]+\\)" nil t)
		   (string-to-int (TeX-match-buffer 1))
		 1))
	 ;; And a string of the context to search for.
	 (string (progn
		   (beginning-of-line)
		   (re-search-forward " \\(\\([^ \t]*$\\)\\|\\($\\)\\)")
		   (TeX-match-buffer 1)))

	 ;; And we have now found to the end of the context. 
	 (context (buffer-substring context-start (progn 
						    (forward-line 1)
						    (end-of-line)
						    (point))))
	 ;; We may use these in another buffer.
	 (offset (car TeX-error-offset) )
	 (file (car TeX-error-file)))
	 
    ;; Remember where we was.
    (setq TeX-error-point (point))

    ;; Find the error.
    (find-file-other-window file)
    (goto-line (+ offset line))
    (if (not (string= string " "))
	(search-forward string nil t))

    ;; Explain the error.
    (if TeX-display-help
	(TeX-help-error error context)
      (message (concat "! " error)))))

(defun TeX-warning (string)
  "Display a warning for STRING.
Return nil if we gave a report."

  (let* ((error (concat "** " string))

	 ;; Get error-line (warning)
	 (line-start (progn
		       (re-search-backward " \\([0-9]*\\)--\\([0-9]*\\)")
		       (string-to-int (TeX-match-buffer 1))))
	 (line-end (string-to-int (TeX-match-buffer 2)))
	 
	 ;; Find the context
	 (context-start (progn (end-of-line) (point)))

	 (context (progn
		    (forward-line 1)
		    (end-of-line)
		    (while (equal (current-column) 79)
		      (forward-line 1)
		      (end-of-line))
		    (buffer-substring context-start (point))))

	 ;; This is where we want to be.
	 (error-point (point))

	 ;; Now find the error word.
	 (word (progn
		 (re-search-backward "[][\\W() ---]\\(\\w+\\)[][\\W() ---]*$"
				     context-start t)
		 (TeX-match-buffer 1)))

	 ;; We might use these in another file.
	 (offset (car TeX-error-offset))
	 (file (car TeX-error-file)))

    ;; This is where we start next time.
    (goto-char error-point)
    (setq TeX-error-point (point))

    ;; Go back to TeX-buffer
    (if TeX-debug-bad-boxes
	(progn
	  (find-file-other-window file)
	  ;; Find line and word
	  (goto-line (+ offset line-start))
	  (beginning-of-line 0)
	  (let ((start (point)))
	    (goto-line line-end)
	    (end-of-line)
	    (search-backward word start t)
	    (search-forward word nil t))
	  ;; Display help
	  (if TeX-display-help
	      (TeX-help-error error context)
	    (message (concat "! " error)))
	  nil)
      t)))

;;; @@@ Help

(defvar TeX-last-debug "dbg-none"
  "Language last used for debug messages.")

(defun TeX-help-error (error output)
  "Print ERROR in context OUTPUT in another window."

  (let ((language (TeX-style-check TeX-debug-language)))
    (if (equal language TeX-last-debug)
	()
      (load-library language)
      (setq TeX-last-debug language)))

  (let ((old-buffer (current-buffer))
	(log-file (TeX-active-master "log"))
	(TeX-error-pointer 1))

    ;; Find help text entry.
    (while (not (string-match (car (nth TeX-error-pointer 
					TeX-error-description-list))
			      error))
      (setq TeX-error-pointer (+ TeX-error-pointer 1)))

    (pop-to-buffer (get-buffer-create "*TeX Help*"))
    (erase-buffer)
    (insert "ERROR: " error
	    "\n\n--- TeX said ---"
	    output
	    "\n--- HELP ---\n"
	    (save-excursion
	      (if (and (string= (cdr (nth TeX-error-pointer
					  TeX-error-description-list))
				"No help available")
		       (let* ((log-buffer (find-file-noselect log-file)))
			 (set-buffer log-buffer)
			 (auto-save-mode nil)
			 (setq buffer-read-only t)
			 (goto-line (point-min))
			 (search-forward error nil t 1)))
		  (progn
		    (re-search-forward "^l.")
		    (re-search-forward "^ +$")
		    (forward-char 1)
		    (let ((start (point)))
		      (re-search-forward "^$")
		      (concat "From the .log file...\n\n"
			      (buffer-substring start (point)))))
		(cdr (nth TeX-error-pointer
			  TeX-error-description-list)))))
    (goto-char (point-min))
    (pop-to-buffer old-buffer)))
  

;;; @@ Emacs

(run-hooks 'TeX-after-tex-buf-hook)

;;; Local Variables:
;;; mode: emacs-lisp
;;; mode: outline-minor
;;; outline-regexp: ";;; @+\\|(......"
;;; End:
