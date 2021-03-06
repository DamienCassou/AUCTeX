;; bib-cite.el - Display \cite, \ref or \label / Extract refs from BiBTeX file.

;; Copyright (C) 1994, 1995 Peter S. Galbraith
 
;; Author:    Peter S. Galbraith <rhogee@bathybius.meteo.mcgill.ca>
;; Created:   06 July 1994
;; Version:   2.00 (27 March 95)
;; Keywords:  bibtex, cite, auctex 

;; Everyone is granted permission to copy, modify and redistribute this
;; file provided:
;;   1. All copies contain this copyright notice.
;;   2. All modified copies shall carry a prominant notice stating who
;;      made modifications and the date of such modifications.
;;   3. The name of the modified file be changed.
;;   4. No charge is made for this software or works derived from it.
;;      This clause shall not be construed as constraining other software
;;      distributed on the same medium as this software, nor is a
;;      distribution fee considered a charge.

;; LCD Archive Entry:
;; bib-cite.el|Peter Galbraith|galbraith@mixing.qc.dfo.ca
;; |Display \cite, \ref or \label / Extract refs from BiBTeX file.
;; Mar 27 1995|2.00||

;; ----------------------------------------------------------------------------
;;; Commentary:

;; New versions of this package (if they exist) may be found at:
;;   ftp://bathybius.meteo.mcgill.ca/pub/users/rhogee/elisp/bib-cite.el
;;   ftp://mixing.qc.dfo.ca/pub/emacs-add-ons/bib-cite.el

;; Operating Systems:
;;  Works in unix, DOS and OS/2.  Developped under Linux.
;;  VMS: I have no clue if this works under VMS. I don't know how emacs handle 
;;  logical names (i.e. for BIBINPUTS) but I am willing to fix this package for
;;  VMS if someone if willing to test it and answer questions.

;; Description:
;; ~~~~~~~~~~~
;; This package is used in various TeX modes to display or edit references
;; associated with \cite commands, or matching \ref and \label commands.
;; (so I actually overstep BiBTeX bounds here...)
;; These are the functions:
;;    
;;    bib-display bib-display-mouse
;;                           - Display citation, \ref or \label under point
;;    bib-find    bib-find-mouse
;;                           - Edit citation, \ref or \label under point
;;    bib-make-bibliography  - Make BiBTeX file containing only cite keys used.
;;    bib-apropos            - Search BiBTeX source files for keywords.
;;    bib-etags              - Refreshes (or builds) the TAGS files for 
;;                             multi-file documents.
;;    bib-create-auto-file   - Used in bibtex-mode to create cite key 
;;                             completion .el file for auctex.
;;    bib-highlight-mouse    - Highlight \cite, \ref and \label commands in 
;;                             green when the mouse is over them.

;; About Cite Commands and related functions:
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;  Various flavors of \cite commands are allowed (as long as they contain
;;  the word `cite') and they may optionally have bracketed [] options.
;;  Cross-references are displayed, and @string abbreviations are
;;  substituted or included.
;;
;;  The reference text is found (by emacs) in the bibtex source files listed in
;;  the \bibliography command.  The BiBTeX files can be located in a search
;;  path defined by an environment variable (typically BIBINPUTS, but you can
;;  change this).
;;
;;  All citations used in a buffer can also be listed in a new bibtex buffer
;;  by using bib-make-bibliography.  This is useful to make a bibtex file for a
;;  document from a large bibtex database.  In this case, cross-references are
;;  included, as well as the @string commands used. The @string abbreviations
;;  are not substituted.
;;
;;  The bibtex files can also be searched for entries matching a regular
;;  expression using bib-apropos.

;; Usage instructions:
;; ~~~~~~~~~~~~~~~~~~
;;  bib-display  (Bound to Shift-Mouse-1)
;;
;;   bib-display will show the bibtex entry or the corresponding label or
;;   ref commands from anywhere within a document.
;;    With cursor on the \cite command itslef 
;;        -> display all citations of the cite command from the BiBTeX source.
;;    With cursor on a particular cite key within the brackets 
;;        -> display that citation's text from the BiBTeX source file(s).
;;
;;       Example:
;;
;;       \cite{Wadhams81,Bourke.et.al87,SchneiderBudeus94}
;;         ^Cursor -> Display-all-citations    ^Cursor -> Display-this-citation
;;
;;    With cursor on a \label command
;;        -> Display first matching \ref command in the document
;;    With cursor on a \ref command
;;        -> Display environment associated with the matching \label command.
;;
;;   Finding a ref or label within a multi-file document requires a TAGS file,
;;   which is automatically generated for you.  This enables you to then use 
;;   any tags related emacs features.
;;
;;  bib-find  (Bound to Shift-Mouse-2)
;;
;;    bib-find will select the buffer and move point to the BiBTeX source
;;    file at the proper citation for a cite command, or move point to
;;    anywhere within a document for a label or ref command.  The ref
;;    chosen is the first occurrance within a document (using a TAGS file).
;;    If point is moved within the same buffer, mark is set before the move
;;    and a message stating so is given.  If point is moved to another
;;    file, this is done in a new window using tag functions.  Within a
;;    plain file, the search pattern is set for another similar \ref
;;    command (since TAGS file are not used).  Within a multi-file document
;;    the following tag functions are appropriately setup:
;;
;;     C-u M-.     Find next alternate definition of last tag specified.
;;
;;     C-u - M-.   Go back to previous tag found.
;;
;;
;;    For multi-file documents, you must be using auctex (so that bib-cite
;;    can find the master file) and all \input and \include commands must be 
;;    first on a line (not preceeded by any non-white text).
;;
;;  imenu support  (Bound to Shift-Mouse-3)
;;
;;    S-Mouse-3 is bound to the imenu facility to move point to a LaTeX
;;    section (or chapter) division or to a label declaration.
;;    When editing a multi-file document, all such declarations within 
;;    the document are displayed in the menu (again using a TAGS file).
;;    If you do not want to load imenu.el and use these features, set 
;;    bib-use-imenu to nil.
;;
;;  bib-make-bibliography:
;;
;;   Extract citations used in the current document from the \bibliography{}
;;   file(s).  Put them into a new suitably-named buffer.
;;   In a auctex multi-file document, the .aux files are used to find the
;;   cite keys (for speed).  You will be warned if these are out of date.
;;
;;   This buffer is not saved to a file.  It is your job to save it to
;;   whatever name you wish.  Note that auctex has a unique name space for
;;   LaTeX and BiBTeX files, so you should *not* name the bib file
;;   associated with example.tex as example.bib!  Rather, name it something
;;   like example-bib.bib.
;;
;;  bib-apropos:
;;
;;   Searches the \bibliography{} file(s) for entries containing a keyword
;;   and display them in the *help* buffer.  You can trim down your search
;;   by using bib-apropos in the *Help* buffer after the first invocation.
;;   the current buffer is also searched for keyword matches if it is in
;;   bibtex-mode. 
;;   
;;   It doesn't display cross-references nor does it substitute or display
;;   @string commands used.  It could easily be added, but it's faster this
;;   way.  Drop me a line if this would be a useful addition.
;;
;;   If you find yourself entering a cite command and have forgotten which
;;   key you want, but have entered a few initial characters as in 
;;   `\cite{Gal', then invoke bib-apropos.  It will take that string (in
;;   this case `Gal') as an initial response to the apropos prompt.  You are
;;   free to edit it, or simply press carriage return.
;;
;;  bib-etags:
;;
;;   Creates a TAGS file for auc-tex's multi-file document (or refreshes it).
;;   This is used by bib-find when editing multi-file documents.  The TAGS
;;   file is created automatically, but it isn't refreshed automatically.
;;   So if bib-find can't find something, try running bib-etags again.
;;   The *rescan* in imenu (S-Mouse-3) also calls bib-etags to refresh the 
;;   TAGS file, so that is another way to generate it.
;;
;;  bib-create-auto-file:
;;
;;   Use this when editing a BiBTeX buffer to generate the auc-tex .el file
;;   which tell emacs about all its cite keys.  I've added this command to
;;   bibtex-mode pull-down menu.
;;
;;  bib-highlight-mouse:    
;;
;;   Highlights \cite, \ref and \label commands in green when the mouse is 
;;   over them.  By default, a call to this function is added to 
;;   LaTeX-mode-hook.  But you may want to run this command to refresh the
;;   highlighting for newly edited text.
 
;; Installation instructions:
;; ~~~~~~~~~~~~~~~~~~~~~~~~~
;;  All you need to do is add this line to your .emacs file (optionally in 
;;  your LaTeX-mode-hook for later loading):
;;
;;    (require 'bib-cite)
;;
;;  It can be used with auctex, or stand-alone.  If used with auctex on a
;;  multi-file document (and auctex's parsing is used), then all \bibliography
;;  commands in the document will be found and used.
;;  ---
;;  The following variable can be unset (like shown) to tell bib-cite to
;;  not give advice messages about which commands to use to find the next
;;  occurrence of a search: 
;;
;;    (setq bib-novice nil)
;;  ---
;;  The imenu features will be disabled if you set this variable to nil
;;
;;    (setq bib-use-imenu nil)
;;
;;  ---
;;  If you use hilit19 (or hl319), then bib-display will use it to highlight 
;;  the display unless you turn this off with:
;;
;;    (setq bib-hilit-if-available nil)
;;
;;    You are welcome to tell me how to do the same using font-lock.
;;  ---
;;  The following variable determines whether we will attempt to highlight
;;  citation, ref and label commands in green when they are under the mouse.
;;  This has no functional purpose.  It just looks good, and reminds the 
;;  user about the availability of bib-cite commands.  If you use a mode 
;;  other than LaTeX-mode, you'll want to call bib-highlight-mouse with a
;;  hook (See how we do this later in this file).
;;
;;    (setq bib-highlight-mouse-t nil)
;;  ---
;;  If you use DOS or OS/2, you may have to set the following variable:
;;
;;    (setq bib-dos-or-os2-variable t)
;;
;;    if bib-cite.el fails to determine that you are using DOS or OS/2.
;;  Try `C-h v bib-dos-or-os2-variable' to see if it needs to be set manually.
;;  ---
;;  bib-cite needs to call the etags program with its output file option
;;  and also with the append option (usually -a).
;;  I figured that DOS and OS/2 would use "etags /o=" instead of the unix
;;  variant "etags -o ", but users have reported differently.  So while the
;;  unix notation is used here, you can reset it if you need to like so:
;;
;;    (setq bib-etags-command        "etags /o=")
;;    (setq bib-etags-append-command "etags /a /o=")
;;  ---
;;  For multi-file documents, a TAGS file is generated by etags.  
;;  By default, its name is TAGS.  You can change this like so:
;;
;;    (setq bib-etags-filename "TAGSLaTeX")
;;  ---
;;  If your environment variable to find BiBTeX files is not BIBINPUTS, then
;;  reset it with the following variable (here, assuming it's TEXBIB instead):
;;
;;    (setq bib-bibtex-env-variable "TEXBIB")
;;  ---
;;  If you do not wish bib-display to substitute @string abbreviations, 
;;  then set the following variable like so:
;;
;;    (setq bib-substitute-string-in-display nil)
;;  ---
;;  Warnings are given when @string abbreviations are not defined in your bib
;;  files.  The exception is for months, usually defined in style files. If you
;;  use other definitions in styles file (e.g. journals), then you may add them
;;  to the `bib-substitute-string-in-display' list variable.

;; Defining keys:
;; ~~~~~~~~~~~~~
;;  The problem is what to choose for key defs!
;;  auctex uses all C-c C-letter combos except for letters o p t v y
;;   
;;  If you wanted to bind bib-display to C-c C-p, you'd use:
;;   
;;    (define-key LaTeX-mode-map "\C-c\C-p" 'bib-display)
;;   
;;  *******************************************************************
;;  NOTE:  I could make bib-cite into a minor-mode with it's own keymap
;;  *******************************************************************
;;
;;  Of course, all the `C-c letter' keys (no control prefix on the second
;;  letter) are reserved for you, the end-user.  So, define whatever you want!
;;  Here are my suggestions:
;;   
;;    (define-key LaTeX-mode-map "\C-ca" 'bib-apropos)
;;    (define-key LaTeX-mode-map "\C-cb" 'bib-make-bibliography)
;;    (define-key LaTeX-mode-map "\C-cd" 'bib-display)
;;    (define-key LaTeX-mode-map "\C-cf" 'bib-find)
;;    (define-key LaTeX-mode-map "\C-ch" 'bib-highlight-mouse)
;;   
;;  The only catch is that LaTeX-mode-map only exists after auc-tex is loaded.
;;  If you don't load auctex in your .emacs , but rather load it later as you
;;  need it using an auto-load, then you'll need to put these key definitions
;;  in a hook:
;;   
;;  (defun extra-LaTeX-mode-hook ()
;;    "My hook for auc-tex's LaTeX-mode-hook"
;;    (define-key LaTeX-mode-map "\C-ca" 'bib-apropos)
;;    (define-key LaTeX-mode-map "\C-cb" 'bib-make-bibliography)
;;    (define-key LaTeX-mode-map "\C-cd" 'bib-display)
;;    (define-key LaTeX-mode-map "\C-cf" 'bib-find)
;;    (define-key LaTeX-mode-map "\C-ch" 'bib-highlight-mouse)
;;    ;; Also set auto-fill-mode... what the heck!
;;    (auto-fill-mode t))
;;   
;;  (add-hook 'LaTeX-mode-hook 'extra-LaTeX-mode-hook)
;;
;;  If you don't use auc-tex, but rather emacs' tex-mode, then use the above,
;;  but substitute the following: LaTeX-mode-map by tex-mode-map
;;  LaTeX-mode-hook by tex-mode-hook

;; If you find circumstances in which this package fails, please let me know.

;; Things for me to do in later versions:
;; - For menu definitions:
;;   use "eval-after-load" in GNU Emacs to delay the code.
;; - prompt for \cite as well as \label and \ref 
;;    (and use auctex's completion list)
;; - implement string concatenation, with #[ \t\n]*STRING_NAME
;; - Create new command to substitute @string text in any bibtex buffer.

;; ----------------------------------------------------------------------------
;;; Change log:
;; V2.00  Mar 27 95 - Peter Galbraith
;;   - bib-find and bib-display replace bib-edit-citation and 
;;      bib-display-citation
;;   - bib-apropos now take initial guess from start of cite argument at point.
;;   - Multi-file support for bib-make-bibliography using .aux files.
;;   - \label and \ref functionality for bib-find and bib-display:
;;     - \label may appear within an \begin\end or to label a (sub-)section.
;;     - Cursor on \label, goto first \ref, set next i-search to pattern.
;;     - Cursor on \ref, goto \label or display it's environment or section.
;;     - Works on hidden code!
;; V1.08  Jan 16 95 - Peter Galbraith
;;     bib-apropos can be used within *Help* buffer to trim a search.
;; V1.07  Dec 13 94 - Peter Galbraith
;;   - Fixed: multi-line @string commands in non-inserted display.
;;   - Fixed: quoted \ character in @string commands.
;;   - BiBTeX comments should not affect bib-cite
;;   - Fixed bib-apropos (from Christoph Wedler <wedler@fmi.uni-passau.de>)
;;      Faster now, and avoids infinite loops.
;;   - Added bib-edit-citation to edit a bibtex files about current citation.
;;   - Allow space and newlines between citations: \cite{ entry1, entry2}
;;   - Added bib-substitute-string-in-display,  bib-string-ignored-warning
;;     and bib-string-regexp.
;;   - bib-display-citation (from Markus Stricker <stricki@vision.ee.ethz.ch>)
;;      Could not find entry with trailing spaces
;; V1.06  Nov 20 94 - Peter Galbraith
;;   - Fixed bib-apropos for:
;;        hilighting without invoking bibtex mode. 
;;        display message when no matches found.
;;        would search only last bib file listed (forgot to `goto-char 1')
;;   - Fixed bib-make-bibliography that would only see first citation in a 
;;     multi-key \cite command (found by Michail Rozman <roz@physik.uni-ulm.de>
;;   - bib-make-bibliography didn't see \cite[A-Z]* commands.
;;     Found by Richard Stanton <stanton@haas.berkeley.edu>
;;     ************************************************** 
;;   - * Completely rewritten code to support crossrefs *
;;     **************************************************
;;   - autodetection of OS/2 and DOS for bib-dos-or-os2-variable
;;   - Created bib-display-citation-mouse
;;   - bib-apropos works in bibtex-mode on the current buffer
;;   - bibtex entry may have comma on next line (!)
;;       @ARTICLE{Kiryati-91
;;         , YEAR          = {1991    }
;;         ...
;; V1.05  Nov 02 94 - Peter Galbraith
;;   - bug fix by rossmann@TI.Uni-Trier.DE (Jan Rossmann) 
;;     for (boundp 'TeX-check-path) instead of fboundp.  Thanks!
;;   - Translate environment variable set by bib-bibtex-env-variable.
;;     (suggested by Richard Stanton <stanton@haas.berkeley.edu>)
;;   - add bib-dos-or-os2-variable to set environment variable path separator
;;   - Add key-defs for any tex-mode and auc-tex menu-bar entries. 
;;       [in auc-tec TeX-mode-map is common to both TeX and LaTeX at startup
;;        (but TeX-mode-map is only copied to LaTeX-mode-map at initilisation)
;;        in plain emacs, use tex-mode-map for both TeX and LaTeX.]
;;   - Add key def for bibtex-mode to create auc-tex's parsing file.
;;   - Fix bugs found by <thompson@loon.econ.wisc.edu>
;;     - fix bib-get-citation for options 
;;     - fix bib-get-citation for commas preceeded citation command
;;     - better regexp for citations and their keys.
;;     - Added @string support for any entry (not just journal entries).
;;       (I had to disallow numbers in @string keys because of years.  
;;        Is that ok?)
;;   - added bib-apropos
;; V1.04  Oct 24 94 - Peter Galbraith 
;;   - Don't require dired-aux, rather define the function we need from it.
;;   - Regexp-quote the re-search for keys.
;;   - Name the bib-make-bibliography buffer diffently than LaTeX buffer
;;     because auc-tex's parsing gets confused if same name base is used.
;; V1.03  Oct 24 94 - Peter Galbraith - require dired-aux for dired-split
;; V1.02  Oct 19 94 - Peter Galbraith
;;   - If using auc-tex with parsing activated, use auc-tex's functions
;;     to find all \bibliography files in a multi-file document.
;;   - Find bib files in pwd, BIBINPUTS environment variable path and
;;     TeX-check-path elisp variable path.
;;   - Have the parser ignore \bibliography that is on a commented `%' line.
;;     (patched by Karl Eichwalder <karl@pertron.central.de>)
;;   - Allow for spaces between entry type and key in bib files:
;;     (e.g  @Article{  key} )
;;     (suggested by Nathan E. Doss <doss@ERC.MsState.Edu>)
;;   - Allows options in \cite command (e.g. agu++ package \cite[e.g.][]{key})
;;   - Includes @String{} abbreviations for `journal' entries
;; V1.01 July 07 94 - Peter Galbraith - \bibliography command may have list of
;;                                      BibTeX files.  All must be readable.
;; V1.00 July 06 94 - Peter Galbraith - Created
;; ----------------------------------------------------------------------------
;;; Code:

;;>>>>>>User-Modifiable variables start here:

(defvar bib-novice t
  "*Give advice to novice users about what commands to use next.")

(defvar bib-use-imenu t
  "*Use imenu package bound to S-mouse-3 for LaTeX modes (coded in bib-cite).")

(defvar bib-hilit-if-available t
  "*Use hilit19 or hl319 to hilit bib-display if available")

(defvar bib-highlight-mouse-t t
  "*Add bib-highlight-mouse to LaTeX-mode-hook to add fancy green highlight.")

(defvar bib-bibtex-env-variable "BIBINPUTS"
  "*Environment variable setting the path where BiBTeX input files are found.
BiBTeX 0.99b manual says this should be TEXBIB.
Another version says it should BSTINPUTS.  I don't know anymore!

The colon character (:) is the default path separator in unix, but you may
use semi-colon (;) for DOS or OS/2 if you set bib-dos-or-os2-variable to `t'.")

(defvar bib-dos-or-os2-variable (or (equal 'emx system-type)
                                    (equal 'ms-dos system-type))
;; Under OS/2 system-type equals emx
;; Under DOS  system-type equals ms-dos
  "*`t' if you use DOS or OS/2 for bib-make-bibliography/bib-display

It tells bib-make-bibliography and bib-display to translate
the BIBINPUTS environment variable using the \";\" character as
a path separator and to translate DOS' backslash to slash.
  
e.g. Use a path like \"c:\\emtex\\bibinput;c:\\latex\\bibinput\"

(You can change the environment variable which is searched by setting the 
elisp variable bib-bibtex-env-variable)")

(defvar bib-etags-command "etags -o "
  "*Variable for the etags command and its output option.
In unix, this is usually \"etags -o \"
In DOS and OS/2, this *may* be \"etags /o=\"  If so, set it this variable.")

(defvar bib-etags-append-command "etags -a -o "
  "*Variable for the etags command and its append and output option.
In unix, this is usually \"etags -a -o \"
In DOS and OS/2, this *may* be \"etags /a /o=\"  If so, set it this variable.")

(defvar bib-etags-filename "TAGS"
   "*Variable for the filename generated by etags, by defaults this TAGS
but you may want to change this to something like TAGSLaTeX such that it can
coexist with some other tags file in your master file directory.")

(defvar bib-substitute-string-in-display t
  "*Determines if bib-display will substitute @string definitions.
If t, then the @string text is substituted.
If nil, the text is not substituted but the @string entry is included.")

(defvar bib-string-ignored-warning 
  '("jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "sept" "oct" "nov" 
   "dec")
  "*List of @string abbreviations for which a warning is given if not defined.
These are usually month abbreviations (or journals) defined in a style file.")

;;<<<<<<User-Modifiable variables end here.

;; @string starts with a letter and does not contain any of ""#%'(),={}
;; Here we do not check that the field contains only one string field and
;; nothing else.
(defvar bib-string-regexp
      "^[, \t]*[a-zA-Z]+[ \t]*=[ \t]*\\([a-zA-Z][^#%'(),={}\" \t\n]*\\)"
      "Regular expression for field containing a @string")

(defun bib-display ()
  "Display BibTeX citation or matching \\ref or \\label command under point.

If text under cursor is a \\cite command, then display its BibTeX info from
\\bibliography input file.
   Example with cursor located over cite command or arguments:
     \cite{Wadhams81,Bourke.et.al87,SchneiderBudeus94}
        ^Display-all-citations          ^Display-this-citation

If text under cursor is a \\ref command, then display environment associated 
with its matching \\label command. 

If text under cursor is a \\label command, then display the text around
the first matching \\ref command.

The user is prompted for a \\label or \\ref is nothing suitable is found under
the cursor.  The first prompt is for a label. If you answer with an empty 
string, a second prompt for a ref will be given.

A TAGS file is created and used for multi-file documents under auctex."
  (interactive)
  (let ((cite))
    (save-excursion
      (if (not (looking-at "\\\\"))
          (re-search-backward "[ \\\n]"))
      (if (looking-at "\\\\[a-zA-Z]*cite")
          (setq cite t)))
    (if cite
        (bib-display-citation)
      (bib-display-label))))

(defun bib-find ()
  "Edit BibTeX citation or find matching \\ref or \\label command under point.

For multi-entry cite commands, the cursor should be on the actual cite key
desired (otherwise a random entry will be selected).
e.g.: \cite{Wadhams81,Bourke.et.al87,SchneiderBudeus94}
                        ^Display-this-citation

If text under cursor is a \\ref command, then point is moved to its matching 
\\label command. 

If text under cursor is a \\label command, then point is moved to the first 
matching \\ref command.

The user is prompted for a \\label or \\ref is nothing suitable is found under
the cursor.  The first prompt is for a label. If you answer with an empty 
string, a second prompt for a ref will be given.

A TAGS file is created and used for multi-file documents under auctex."
  (interactive)
  (let ((cite))
    (save-excursion
      (if (not (looking-at "\\\\"))
          (re-search-backward "[ \\\n]"))
      (if (looking-at "\\\\[a-zA-Z]*cite")
          (setq cite t)))
    (if cite
        (bib-edit-citation)
      (bib-find-label))))

(defun bib-display-mouse (EVENT)
  "Display BibTeX citation or matching \\ref or \\label command under mouse.
See bib-display."
  (interactive "e")
  (mouse-set-point EVENT)
  (bib-display))

(defun bib-find-mouse (EVENT)
  "Edit BibTeX citation or find matching \\ref or \\label command under mouse.
See bib-find."
  (interactive "e")
  (mouse-set-point EVENT)
  (bib-find))

(defun bib-apropos ()
  "Display BibTeX entries containing a keyword from bibliography file.
The files specified in the \\bibliography command are searched unless
the current buffer is in bibtex-mode or is the Help buffer.  In those
cases, *it* is searched.  This allows you to trim down a search further 
by using bib-apropos sequentially."
  ;;(interactive "sBibTeX apropos: ")
  (interactive)
  (let* ((keylist (and (fboundp 'LaTeX-bibitem-list) ;Use this if using auctex
                       (LaTeX-bibitem-list)))
         (keyword (bib-apropos-keyword-at-point))
         (keyword (completing-read "BiBTeX apropos: " keylist nil nil keyword))
         (the-text)(key-point)(start-point)
         (new-buffer-f (and (not (string-match "^bib" mode-name))
                            (not (string-equal "*Help*" (buffer-name)))))
         (bib-buffer (or (and new-buffer-f (bib-get-bibliography nil))
                         (current-buffer))))
    (save-excursion
      (set-buffer bib-buffer)
      (goto-char (point-min))
      (while (and (re-search-forward "^[ \t]*@" nil t)
                  (re-search-forward keyword nil t))
        (setq key-point (point))        ;To make sure this is within entry
        (re-search-backward "^[ \t]*@" nil t)
        (setq start-point (point))
        (forward-list 1)
        (if (< (point) key-point)       ;And this is that test...
            (goto-char key-point)       ;Not within entry, skip it.
          (setq the-text 
                (cons (concat (buffer-substring start-point (point)) "\n")
                      the-text))))
      (if (not the-text)
          (message "Sorry, no matches found.")
        (with-output-to-temp-buffer "*Help*" 
          (mapcar 'princ (nreverse the-text)))
        (if bib-novice
            (message
             (substitute-command-keys
              (concat "Use \\[bib-apropos] again in the *help* buffer"
                      " to trim the search"))))
        (if (and bib-hilit-if-available
                 (fboundp 'hilit-highlight-region))
            (progn
              (set-buffer "*Help*")
              (hilit-highlight-region 
               (point-min) (point-max) 'bibtex-mode t))))
      (if new-buffer-f
          (kill-buffer bib-buffer)))))

(defun bib-make-bibliography ()
  "Extract citations used in the current document from \bibliography{} file(s).
Put them into a buffer named after the current buffer, with extension .bib.

In an auc-tex multi-file document, parsing must be on and the citation keys
are extracted from the .aux files.

In a plain LaTeX buffer (not multi-file), the cite keys are extracted from 
the text itself.  Therefore the text need not have been previously processed
by LaTeX.  

This function is useful when you want to share a LaTeX file, and therefore want
to create a bibtex file containing only the references used in the document."
  (interactive)
  (let* ((the-keys-obarray (or (bib-document-citekeys-obarray)
                               (bib-buffer-citekeys-obarray)))
                                        ;1st in case of error
         (new-buffer 
          (create-file-buffer 
           (concat (substring (buffer-name) 0 
                              (or (string-match "\\." (buffer-name))
                                  (length (buffer-name))))
                   "-bib.bib")))
         (bib-buffer (bib-get-bibliography nil))
         (the-warnings (bib-get-citations the-keys-obarray
                                          bib-buffer
                                          new-buffer
                                          nil)))
    (kill-buffer bib-buffer)
    (switch-to-buffer new-buffer)
    (bibtex-mode)
    (if (and bib-hilit-if-available
             (fboundp 'hilit-highlight-region))
        (hilit-highlight-buffer t))
    (if (or bib-document-citekeys-obarray-warnings
            the-warnings)
        (progn
          (with-output-to-temp-buffer "*Help*" 
            (princ bib-document-citekeys-obarray-warnings
                   the-warnings))
          (setq bib-document-citekeys-obarray-warnings nil) ;Reset
          (if bib-novice
              (message
               (substitute-command-keys
                "Use \\[save-buffer] to save this buffer to a file.")))
          (if (and bib-hilit-if-available
                   (fboundp 'hilit-region-set-face))
              (save-excursion
                (set-buffer "*Help*")
                (hilit-region-set-face 
                 1 (point-max)
                 (cdr (assq 'error hilit-face-translation-table)))))))))

(defun bib-etags (&optional masterdir)
  "Invoke etags on all tex files of the document, storing the TAGS file
in the master-directory.  Expect errors if you use this outside of auctex
or within a plain single-file document.
Also makes sure that the TAGS buffer is updated.
See variables bib-etags-command and bib-etags-filename"
  (interactive)
  (let* ((the-file-list (bib-document-TeX-files))
         (the-file (car the-file-list))
         (dir (or masterdir (bib-master-directory)))
         (the-tags-file (expand-file-name bib-etags-filename dir))
         (the-tags-buffer (get-file-buffer the-tags-file)))
    ;; Create TAGS file with first TeX file (master file)
    (shell-command (concat bib-etags-command the-tags-file " " the-file))
    (setq the-file-list (cdr the-file-list))
    ;; Append to TAGS file for all other TeX files.
    (while the-file-list
      (setq the-file (car the-file-list)) 
      (shell-command 
       (concat bib-etags-append-command the-tags-file " " the-file))
      (setq the-file-list (cdr the-file-list)))
    (if the-tags-buffer                 ;buffer existed; we must refresh it.
        (save-excursion
          (set-buffer the-tags-buffer)
          (revert-buffer t t)))

    ;; Check value of tags-file-name against the-tags-file
    (or (equal the-tags-file  tags-file-name) ;make sure it's current
        (visit-tags-table the-tags-file)) 

    ;(set (make-local-variable 'tags-file-name) the-tags-file))
    ;; above should not be needed

    ;; Weird Bug:
    ;;  (visit-tags-table-buffer) seems to get called twice when called by 
    ;;  find-tag on an undefined tag. The second time, it's in the TAGS 
    ;;  buffer and returns an error because TAGS buffer does have 
    ;;  tags-file-name set.
    ;;  To get around this.  I'm setting this variable in the TAGS buffer.
    (save-excursion
      (set-buffer (get-file-buffer the-tags-file))
      (set (make-local-variable 'tags-file-name) the-tags-file)))


  (if bib-document-TeX-files-warnings   ;free variable loose in emacs!
      (progn
        (with-output-to-temp-buffer "*Help*" 
          (princ bib-document-TeX-files-warnings))
        (setq bib-document-TeX-files-warnings nil) ;Reset
        (if (and bib-hilit-if-available
                 (fboundp 'hilit-region-set-face))
            (save-excursion
              (set-buffer "*Help*")
              (hilit-region-set-face 
               1 (point-max)
               (cdr (assq 'error hilit-face-translation-table))))))))

(defun bib-Is-hidden ()
  "Return true is current point is hidden"
  (if (not selective-display)
      nil                               ;Not hidden if not using this...
    (save-excursion
      (if (not (re-search-backward "[\n\^M]" nil t))
          nil                           ;Play safe
        (if (string-equal (buffer-substring (match-beginning 0)(match-end 0))
                          "\n")
            nil
          t)))))

(defun bib-highlight-mouse ()
  "Make that nice green highlight when the mouse is over LaTeX commands"
  (interactive)
  (if (or (not bib-highlight-mouse-t)
          (not window-system))
      nil                               ;Do nothing unless under X
    (save-excursion
      (goto-char (point-min))
      (while 
        (re-search-forward 
       "\\\\\\(ref\\|label\\|[A-Za-z]*cite[A-Za-z]*\\(\\[.*\\]\\)?\\){[^}]*}"
          nil t)
        (put-text-property (match-beginning 0) (match-end 0) 
                           'mouse-face 'highlight)))))

(if bib-highlight-mouse-t               ;If user wants this automatically
    (add-hook 'LaTeX-mode-hook 'bib-highlight-mouse))

;;----------------------------------------------------------------------------
;; Routines to display or edit a citation's bibliography

(defun bib-display-citation ()
  "Do the displaying of cite info.  Returns t if found cite key, nil otherwise.
Example with cursor located over cite command or arguments:
\cite{Wadhams81,Bourke.et.al87,SchneiderBudeus94}
   ^Display-all-citations          ^Display-this-citation"
  (save-excursion
    (let* ((the-keys-obarray (bib-get-citekeys-obarray)) ;1st in case of error
           (work-buffer (get-buffer-create "*bibtex-work*"))
           (bib-buffer (bib-get-bibliography nil))
           (the-warnings (bib-get-citations 
                          the-keys-obarray
                          bib-buffer
                          work-buffer
                          bib-substitute-string-in-display))
           (the-warn-point))
      (if the-warnings
          (progn 
            (set-buffer work-buffer)
            (goto-char 1)
            (insert the-warnings)
            (setq the-warn-point (point))))
      (with-output-to-temp-buffer 
          "*Help*" 
        (set-buffer work-buffer)
        (princ (buffer-substring 1 (point-max))))
      (if (and bib-hilit-if-available
               (fboundp 'hilit-highlight-region))
          (progn
            (set-buffer "*Help*")
            (hilit-highlight-region 
             (point-min) (point-max) 'bibtex-mode t)
            (if the-warn-point
                (hilit-region-set-face 
                 1 the-warn-point 
                 (cdr (assq 'error hilit-face-translation-table))))))
      (kill-buffer bib-buffer)
      (kill-buffer work-buffer))))

(defun bib-edit-citation ()
  "Do the edit of cite info.  Returns t if found cite key, nil otherwise.
Find and and put edit point in bib file associated with a BibTeX citation
under cursor from \bibliography input file.
In a multi-entry cite command, the cursor should be on the actual cite key
desired (otherwise a random entry will be selected). 
e.g.: \cite{Wadhams81,Bourke.et.al87,SchneiderBudeus94}
                        ^Display-this-citation"
  (let ((the-keys-obarray (bib-get-citekeys-obarray)) ;1st in case of error
        (bib-buffer (bib-get-bibliography t))
        (the-key)(the-file))
    (save-excursion
      (mapatoms                     ;Do this for each cite-key found...
       (function (lambda (cite-key) 
                   (setq the-key (symbol-name cite-key))))
       the-keys-obarray)
      (set-buffer bib-buffer)
      (goto-char (point-min))
      (if (not (re-search-forward 
                (concat "@[^{]+{[\t ]*" the-key "[ ,\n]") nil t))
          (progn 
            (kill-buffer bib-buffer)
            (error "Sorry, could not find bib entry for %s" the-key))
        (re-search-backward "%%%Filename: \\([^\n]*\\)" nil t)
        (setq the-file (buffer-substring (match-beginning 1)(match-end 1)))
        (kill-buffer bib-buffer)))
    (find-file the-file)
    (re-search-forward (concat "@[^{]+{[\t ]*" the-key "[ ,\n]") nil t)))

;;--------------------------------------------------------------------------
;; Function for bib-apropos

(defun bib-apropos-keyword-at-point ()
  ;; Returns the keyword under point for initial input to bib-apropos prompt
  (save-excursion
    (let ((here (point)))
      (and (re-search-backward "[\n{, ]" nil t)
           (string-equal "{" (buffer-substring (match-beginning 0)
                                               (match-end 0)))
           (buffer-substring (1+ (point)) here)))))

;;--------------------------------------------------------------------------
;; Functions for Displaying or moving to matching \ref or \label command

(defun bib-display-label ()
;;  "Display environment associated with a label or first ref assoc. with label
;;The label or ref name is extracted from the text under the cursor, or the
;;user is prompted is nothing suitable is found.  The first prompt is for a
;;label. If you answer with an empty string, a second prompt for a ref will
;;be given."
  (let ((the-name (bib-guess-or-prompt-for-label)))
    (if (not the-name)
        (message "No name given")
      (bib-display-or-find-label the-name t))))

(defun bib-find-label ()
  "Move to a label, or the first occurance of a ref.
The label or ref name is extracted from the text under the cursor. 
;;If nothing suitable is found, the user is prompted. The first prompt is for a
;;label. If you answer with an empty string, a second prompt for a ref will be 
;;given.
;;
;;If within a single file document:
;;  You can move back with C-x C-x as the mark is set before moving.
;;  You can search for next occurrances of a ref command with C-s C-s.
;;
;;If within a multi-file document (in auctex only)
;;  You can move back with C-x C-x if within the same buffer.  If not, just
;;  select your previous buffer.
;;  You can search for next occurrances of a ref command with tag commands:
;;     C-u M-.     Find next alternate definition of last tag specified.
;;     C-u - M-.   Go back to previous tag found."
  (let ((the-name (bib-guess-or-prompt-for-label)))
    (if (not the-name)
        (message "No name given")
      (bib-display-or-find-label the-name nil))))

;;--------------------------------------------------------------------------
;; Functions for Displaying or moving to matching \ref or \label command

(defun bib-display-or-find-label (the-name displayf)
;; work horse for bib-find-label and bib-display-label
  (let* ((masterfile (bib-master-file))
         (masterdir (and masterfile
                         (file-name-directory masterfile)))
         (new-point)(new-buffer))
    (save-excursion
      ;; Now we are either in a simple file, or with a multi-file document
      (cond
       (masterfile                   ;Multi-file document
        (cond 
         (displayf                  ;Display only
          (set-buffer (bib-etags-find-noselect the-name masterdir))
          (re-search-forward the-name nil t) ;'cos tags puts point line begin
          (if (string-match "^\\\\label" the-name)
              (bib-display-this-environment) ;display the label's environment
            (bib-display-this-ref)))    ;     display the ref's context
         (t                         ;Move to it
          (setq new-buffer (bib-etags-find-noselect the-name masterdir))
          (if bib-novice
              (message
               (substitute-command-keys
                (concat "Use C-u \\[find-tag] to find the next occurrence; "
                        "Use C-u - \\[find-tag] to find the previous."))))
          (if (equal new-buffer (current-buffer))
              (setq new-point (point))) ;Moving with the same buffer
          (and (string-match "^\\\\ref" the-name)
               (setq search-ring (cons the-name search-ring))))))
       (t                           ;Single-file document
        (goto-char (point-min))
        (if (search-forward the-name nil t)
            (if displayf
                (if (string-match "^\\\\label" the-name)
                    (bib-display-this-environment)   ;Display the environment
                  (bib-display-this-ref)) ;           display the ref's context
              (setq new-point (match-beginning 0))  ;or move there
              (if bib-novice
                  (message
                   (substitute-command-keys
                    (concat 
                     "Use \\[isearch-forward] \\[isearch-forward] to find the "
                     "next occurrence; Use C-x C-x to go back."))))
              (if (string-match "^\\\\ref" the-name)
                  (setq search-ring (cons the-name search-ring))
                (setq search-ring (cons (concat "\\ref" (substring the-name 6))
                                        search-ring))))
          (message "Sorry, cannot find %s" the-name)))))
    (if new-point
        (progn
          (push-mark (point) t nil)   ;We've moving there... push mark
          (goto-char new-point))
      (if new-buffer                    ;We've changing buffer
          (switch-to-buffer new-buffer)))
    (if (bib-Is-hidden)
        (save-excursion
          (beginning-of-line)
          (show-entry)))))

(defun bib-guess-or-prompt-for-label ()
  ;; Guess from context, or prompt the user for a label command
  (save-excursion
    (if (not (looking-at "\\\\"))        ;If not on beginning of a command
             (re-search-backward "[ \\]"))
    (cond
     ((looking-at "\\\\ref{")           ;On \ref, looking for matching \label
      (re-search-forward "{[ \n]*\\([^,} \n]+\\)" nil t)
      (concat "\\label{" (buffer-substring (match-beginning 1)(match-end 1)) 
              "}"))
     ((looking-at "\\\\label{")         ;On \label, looking for matching \ref
      (re-search-forward "{[ \n]*\\([^,} \n]+\\)" nil t)
      (concat "\\ref{" (buffer-substring (match-beginning 1)(match-end 1)) 
              "}"))
     (t                                 ;Prompt the user
      (let* ((the-alist (create-alist-from-list (car LaTeX-label-list)))
        ;; LaTeX-label-list example: '(("label1" "label2") nil)
        ;; so let's lget rid of that nil part in embedded list.
             (the-name 
              (if (string-equal "18" (substring emacs-version 0 2))
                  (completing-read "Label: " the-alist nil nil nil)
                (completing-read "Label: " the-alist nil nil nil 
                                 'LaTeX-find-label-hist-alist))))
        (if (not (equal the-name ""))
            (concat "\\label{" the-name "}")
          ;; else try to get a \ref
          (if (string-equal "18" (substring emacs-version 0 2))
              (setq the-name (completing-read "Ref: " the-alist nil nil nil))
            (setq the-name (completing-read "Ref: " the-alist nil nil nil 
                                            'LaTeX-find-label-hist-alist)))
          (if (not (equal the-name ""))
              (concat "\\ref{" the-name "}")
            nil)))))))

(defun bib-display-this-ref ()
  "Display a few lines around current point"
  (cond ((bib-Is-hidden)
         (with-output-to-temp-buffer "*BiBTemp*" 
           (princ 
            (buffer-substring 
             (save-excursion
               (let ((i 3))
                 (while (and (> i 0)
                             (re-search-backward "[\n\^M]" nil t)
                             (setq i (1- i)))))
               (point))
             (save-excursion
               (let ((i 3))
                 (while (and (> i 0)
                             (re-search-forward "[\n\^M]" nil t)
                             (setq i (1- i)))))
               (point)))))
         (set-buffer "*BiBTemp*")
         (while (search-forward "\^M" nil t)
           (replace-match "\n" nil t))
         (goto-char 1)
         (if (looking-at "\n")  ;Remove first empty line...
             (delete-char 1))
         (with-output-to-temp-buffer "*Help*" 
           (princ (buffer-substring 1 (point-max))))
         (kill-buffer "*BiBTemp*"))
        (t 
         (with-output-to-temp-buffer ;     display the ref's context
             "*Help*" 
           (princ 
            (buffer-substring (save-excursion (forward-line -2)(point))
                              (save-excursion (forward-line 3)(point))))))))

(defun bib-display-this-environment ()
  "Display the environment associated with a label, or its section name
Assumes point is already on the label.
Does not save excursion."
;; Bugs:  The method used here to detect the environment is *not* foolproof.
;;        It will get confused, for example, between two figure environments,
;;        picking out both instead of the section label above them.  But since
;;        users typically puts their labels next to the section declaration,
;;        I'm satisfied with this... for now.
;; I could have used the following auc-tex functions:
;;  LaTeX-current-environment
;;    Function: Return the name (a string) of the enclosing LaTeX environment.
;;  LaTeX-current-section
;;    Function: Return the level of the section that contain point.
;; but then this code would only work as part of auc-tex...
  (let ((the-point (point))
        (end-point (point))
        (the-environment)(foundf))
    (while (and (not foundf)
                (goto-char end-point) ;Past end of last search
                (re-search-forward "\\(^\\|\^M\\)[ \t]*\\\\end{\\([^}]*\\)}" 
                                   nil t))
      (setq end-point (point))
      (setq the-environment (buffer-substring (match-beginning 2)
                                              (match-end 2)))
      (and (not (string-match "document" the-environment))
           (re-search-backward (concat "\\(^\\|\^M\\)[ \t]*\\\\begin{" 
                                       (regexp-quote the-environment) "}"))
           (<= (point) the-point)
           (setq foundf t)))
    (if foundf                          ;A good environment
        (progn
          (cond ((bib-Is-hidden)        ;Better way is: replace-within-string
                 (with-output-to-temp-buffer "*BiBTemp*" 
                   (princ (buffer-substring (point) end-point)))
                 (set-buffer "*BiBTemp*")
                 (while (search-forward "\^M" nil t)
                   (replace-match "\n" nil t))
                 (goto-char 1)
                 (if (looking-at "\n")  ;Remove first empty line...
                     (delete-char 1))
                 (with-output-to-temp-buffer "*Help*" 
                   (princ (buffer-substring 1 (point-max))))
                 (kill-buffer "*BiBTemp*"))
                (t
                 (with-output-to-temp-buffer "*Help*" 
                   (princ (buffer-substring (point) end-point)))))
          (if (and bib-hilit-if-available
                   (fboundp 'hilit-highlight-region))
              (progn
                (set-buffer "*Help*")
                (hilit-highlight-region 
                 (point-min) (point-max) 'latex-mode t))))
      ;; Just find the section declaration
      (goto-char the-point)
      (if (re-search-backward
           "\\(^\\|\^M\\)[ \t]*\\\\\\(sub\\)*section{\\([^}]*\\)}" nil t)
          (message (buffer-substring (match-beginning 0)(match-end 0)))
        (error 
         "Sorry, could not find an environment or section declaration")))))

(defvar LaTeX-find-label-hist-alist nil "History list for LaTeX-find-label")
(defvar LaTeX-label-list nil "Used by auc-tex to store label names")

(defun create-alist-from-list (the-list)
  (let ((work-list the-list)(the-alist))
    (setq the-alist (list (list (car work-list))))
    (setq work-list (cdr work-list))
    (while work-list
      (setq the-alist (append the-alist (list (list (car work-list)))))
      (setq work-list (cdr work-list)))
    the-alist))
          
;; -------------------------------------------------------------------------
;; Routines to extract cite keys from text

;;    ... is truly remarkable, as shown in \citeN{Thomson77,Test56}. Every
;; \cite[{\it e.g.}]{Thomson77,Test56}

(defun bib-get-citations (keys-obarray bib-buffer new-buffer substitute)
  "Put citations of KEYS-OBARRAY from BIB-BUFFER into NEW-BUFFER,
Substitute strings if SUBSTITUTE is t
Return the-warnings as text."
  (let ((the-warnings)                  ;The only variable to remember...
        (case-fold-search t))           ;All other results go into new-buffer
    ;; bibtex is not case-sensitive for keys.
    (save-excursion
      (let ((the-text))
        (set-buffer bib-buffer)
        (mapatoms                         ;Do this for each cite-key found...
         (function 
          (lambda (cite-key) 
            (goto-char (point-min))
            (if (re-search-forward 
                 (concat "@[^{]+{[\t ]*" 
                         (regexp-quote (symbol-name cite-key)) 
                         "\\([, ]\\\|$\\)")
                ;;            ^^     ^  comma, space or end-of-line
                 nil t)
                (setq the-text (concat the-text
                                       (buffer-substring 
                                        (progn (beginning-of-line)(point))
                                        (progn (forward-sexp 2)(point)))
                                       "\n\n"))
              (setq the-warnings (concat the-warnings 
                                         "Cannot find entry for: " 
                                         (symbol-name cite-key) "\n")))))
         keys-obarray)
        (if (not the-text) 
            (error "Sorry, could not find any of the references"))
        ;; Insert the citations in the new buffer
        (set-buffer new-buffer)
        (insert the-text)
        (goto-char 1))

      ;; We are at beginning of new-buffer.
      ;; Now handle crossrefs
      (let ((crossref-obarray (make-vector 201 0)))
        (while (re-search-forward
                "[, \t]*crossref[ \t]*=[ \t]*\\(\"\\|\{\\)" nil t)
          ;;handle {text} or "text" cases
          (if (string-equal "{" (buffer-substring (match-beginning 1)
                                                  (match-end 1)))
              (re-search-forward "[^\}]+" nil t)
            (re-search-forward "[^\"]+" nil t))
          (intern (buffer-substring (match-beginning 0)(match-end 0)) 
                  crossref-obarray))
        ;; Now find the corresponding keys,
        ;; but add them only if not already in `keys-obarray'
        (set-buffer bib-buffer)
        (goto-char 1)
        (let ((the-text))
          (mapatoms                     ;Do this for each crossref key found...
           (function
            (lambda (crossref-key)
              (if (not (intern-soft (symbol-name crossref-key) keys-obarray))
                  (progn
                    ;; Not in keys-obarray, so not yet displayed.
                    (goto-char (point-min))
                    (if (re-search-forward 
                         (concat "@[^{]+{[\t ]*" 
                                 (regexp-quote (symbol-name crossref-key)) 
                                 "\\(,\\|$\\)") 
                         nil t)
                        (setq the-text 
                              (concat the-text
                                      (buffer-substring 
                                       (progn (beginning-of-line)(point))
                                       (progn (forward-sexp 2)(point)))
                                      "\n\n"))
                      (setq the-warnings 
                            (concat the-warnings 
                                    "Cannot find crossref entry for: " 
                                    (symbol-name crossref-key) "\n")))))))
           crossref-obarray)
          ;; Insert the citations in the new buffer
          (set-buffer new-buffer)
          (goto-char (point-max))
          (if the-text
              (insert the-text)))
        (goto-char 1))

      ;; Now we have all citations in new-buffer, collect all used @String keys
      ;; Ex:  journal =      JPO,
      (let ((strings-obarray (make-vector 201 0)))
        (while (re-search-forward bib-string-regexp nil t)
          (intern (buffer-substring (match-beginning 1)(match-end 1)) 
                  strings-obarray))
        ;; Now find the corresponding @String commands
        ;; Collect either the @string commands, or the string to substitute
        (set-buffer bib-buffer)
        (goto-char 1)
        (let ((string-alist)
              (the-text))
          (mapatoms                     ;Do this for each string-key found...
           (function
            (lambda (string-key)
              (goto-char (point-min))
              ;; search for @string{ key = {text}} or @string{ key = "text"}
              (if (re-search-forward
                   (concat "^[ \t]*@string{"
                           (regexp-quote (symbol-name string-key))
                           "[\t ]*=[\t ]*\\(\"\\|\{\\)")
                   nil t)
                  (progn
                    ;;handle {text} or "text" cases
                    (forward-char -1)
                    (if (string-equal "{" (buffer-substring (match-beginning 1)
                                                            (match-end 1)))
                        (re-search-forward "[^\}]+}" nil t)
                      (re-search-forward "[^\"]+\"" nil t))
                    (if substitute      ;Collect substitutions
                        (setq string-alist
                              (append
                               string-alist
                               (list 
                                (cons (symbol-name string-key) 
                                      (regexp-quote
                                       (buffer-substring 
                                        (1- (match-beginning 0))
                      ;;                 ^ this grabs the leading quote/bracket
                                        (match-end 0)))))))
                      ;;Collect the strings command themseves
                      (setq the-text
                            (concat the-text 
                                    (buffer-substring 
                                     (progn (forward-char 1)(point))
                                     (re-search-backward "^[ \t]*@string{" 
                                                         nil t))
                                    "\n"))))
                ;; @string entry not found
                (if (not (member (symbol-name string-key) 
                                 bib-string-ignored-warning))
                    (setq the-warnings 
                          (concat the-warnings 
                                  "Cannot find @String entry for: " 
                                  (symbol-name string-key) "\n"))))))
           strings-obarray)
          ;; Now we have `the-text' of @string commands, 
          ;; or the `string-alist' to substitute.
          (set-buffer new-buffer)
          (if substitute
              (while string-alist
                (goto-char 1)
                (let ((the-key (car (car string-alist)))
                      (the-string (cdr (car string-alist))))
                  (while (re-search-forward 
                          (concat "\\(^[, \t]*[a-zA-Z]+[ \t]*=[ \t]*\\)" 
                                  the-key 
                                  "\\([, \t\n]\\)")
                          nil t)
                    (replace-match (concat "\\1" the-string "\\2") t)))
                (setq string-alist (cdr string-alist)))
            ;; substitute is nil; Simply insert text of @string commands
            (goto-char 1)
            (if the-text 
                (insert the-text "\n")))
          (goto-char 1))))

    ;; We are done!
    ;; Return the warnings...
    the-warnings))

(defun bib-get-citekeys-obarray ()
  "Return obarray of citation key (within curly brackets) under cursor."
  (save-excursion
    ;; First find *only* a key *within a cite command
    (let ((the-point (point))
          (keys-obarray (make-vector 201 0)))
      ;; First try to match a cite command
      (if (and (skip-chars-backward "\\\\a-zA-Z")
               (looking-at "\\\\[a-zA-Z]*cite[a-zA-Z]*"))
          (progn
            ;;skip over any optional arguments to \cite[][]{key} command
            (skip-chars-forward "\\\\a-zA-Z")
            (while (looking-at "\\[")
                (forward-sexp 1))
            (re-search-forward "{[ \n]*\\([^,} \n]+\\)" nil t)
            (intern (buffer-substring (match-beginning 1)(match-end 1))
                    keys-obarray)
            (while (and (skip-chars-forward " \n") ;no effect on while
                        (looking-at ","))
              (forward-char 1)
              ;;The following re-search skips over leading spaces
              (re-search-forward "\\([^,} \n]+\\)" nil t) 
              (intern (buffer-substring (match-beginning 1)(match-end 1))
                      keys-obarray)))
            
        ;; Assume we are on the keyword
        (goto-char the-point)
        (let ((the-start (re-search-backward "[\n{, ]" nil t))
              (the-end (progn (goto-char the-point)
                              (re-search-forward "[\n}, ]" nil t))))
          (if (and the-start the-end)
              (intern (buffer-substring (1+ the-start) (1- the-end))
                      keys-obarray)
            ;; Neither...
            (error "Sorry, can't find a reference here"))))
      keys-obarray)))

(defun bib-buffer-citekeys-obarray ()
  "Extract citations keys used in the current buffer"
  (let ((keys-obarray (make-vector 201 0)))
    (save-excursion
      (goto-char (point-min))
      ;; Following must allow for \cite[e.g.][]{key} !!!
      ;; regexp for \cite{key1,key2} was "\\\\[a-Z]*cite[a-Z]*{\\([^,}]+\\)"
      (while (re-search-forward "\\\\[a-zA-Z]*cite[a-zA-Z]*\\(\\[\\|{\\)" 
                                nil t)
        (backward-char 1)
        (while (looking-at "\\[")       ; ...so skip all bracketted options
          (forward-sexp 1))
        ;; then lookup first key
        (if (looking-at "{[ \n]*\\([^,} \n]+\\)")
            (progn
              (intern (buffer-substring (match-beginning 1)(match-end 1)) 
                      keys-obarray)
              (goto-char (match-end 1))
              (while (and (skip-chars-forward " \n")
                          (looking-at ","))
                (forward-char 1)
                (re-search-forward "\\([^,} \n]+\\)" nil t) 
                (intern (buffer-substring (match-beginning 1)(match-end 1))
                        keys-obarray)))))
      (if keys-obarray
          keys-obarray
        (error "Sorry, could not find any citation keys in this buffer.")))))

;;---------------------------------------------------------------------------
;; Multi-file document programming requirements:
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; bib-make-bibliography
;;    bib-document-citekeys-obarray needs the master .aux file to extract
;;   citation keys.
;;    Included .aux files (corresponding to \include'd LaTeX files) are 
;;   then specified relative to the master-file-directory.
;;
;; bib-get-bibliography (used by interactive commands to extract bib sources)
;;  
;;    bibtex source filenames are returned from (LaTeX-bibliography-list)
;;   unformatted.  Since only a single \bibliogragrphy command is allowed 
;;   by BiBTeX in a document, it is safe to assume that their path is 
;;   relative to the master file's directory (since the path is relative 
;;   to where the BiBTeX program is actually ran).
;;
;; imenu
;;
;;    Requires list of all tex files (complete with paths) to call etags on 
;;   them.
;;    I used (TeX-style-list) to get the list of possible tex files, but
;;   they are not in sorted order.  Therefore the imenu would be somewhat
;;   confusing. I'll have to do the scan myself, except that I'll only be 
;;   looking at the master file for \include statements.

;; (See TeX-check-files, used in TeX-save-document.  All documents related 
;;  files are returned by (TeX-style-list) and stored in TeX-active-styles.  
;;  Original idea was to search TeX-check-path for files listed in 
;;  TeX-active-styles (with possible relative or full paths) that end in .tex.)

(defun bib-master-directory ()
;; Returns the directory associated with the master file.
;; If no master file, then return current default.
  (let ((masterfile (bib-master-file)))
    (if masterfile 
        (file-name-directory (expand-file-name (TeX-master-file)))
      default-directory)))

(defun bib-master-file ()
;; return master file full path, or nil if not a multi-file document
;; I wish there were a better way to tell about non multi-file documents...
  (let ((master
         (cond
          ((not (boundp 'TeX-master))
           ;; This buffer doesn't know what a master file is, so return now.
           nil)
          ((and TeX-master              ;Set, but not to t
                (not (eq TeX-master 't))) ; then we have an actual name
           (expand-file-name TeX-master))
          ((and (eq TeX-master 't)      ;Test if master file itself
                (progn                  ;But also require at least one \include
                  (save-excursion
                    (goto-char 1)       ;Too bad I have to do this search...
                    ;; Require that user uses \input{file}
                    ;; rather than            \input file
                    (re-search-forward "^[ \t]*\\\\\\(include\\|input\\){" 
                                       nil t))))
           (buffer-file-name))
          (t
           nil))))
    (cond
     ((not master)
      nil)
     ((string-match ".tex$" master)
      master)
     (t
      (concat master ".tex")))))

;; I don't use this one because files are not returned in order...
;; (defun bib-document-TeX-files ()
;; ;; Return all tex input files associated with a known multi-file document.
;;   (let ((master-directory (bib-master-directory))
;;         (the-list (cons (file-name-nondirectory (TeX-master-file)) 
;;                         (TeX-style-list)))
;;      ;; TeX-style-list returns "../master" for the main file if TeX-master
;;      ;; was set like that.  "../master" would not be found relative
;;      ;; to the master-directory!  So let's add it to the list w/o directory.
;;         (the-result)
;;         (the-file))
;;     (while the-list
;;       (setq the-file (expand-file-name (car the-list) master-directory))
;;       (setq the-list (cdr the-list))
;;       (and (not (string-match ".tex$" the-file))
;;            (setq the-file (concat the-file ".tex")))
;;       (and (file-readable-p the-file)
;;            (not (member the-file the-result)) ;listed already?
;;            (setq the-result (cons the-file the-result))))
;;     the-result))

(defun bib-document-TeX-files ()
  ;; For a multi-file document in auctex only.
  ;; Return all tex input files associated with a *known* multi-file document.
  ;; No checking is done that this is a real multi-file document.

  ;; sets global variable bib-document-TeX-files-warnings
  
  (setq bib-document-TeX-files-warnings nil)
  (let* ((masterfile (bib-master-file))
         (dir (and masterfile (file-name-directory masterfile)))
         (tex-buffer (get-buffer-create "*tex-document*"))
         (the-list (list masterfile))
         (the-file))
    (if (not masterfile)
        (progn
          (kill-buffer tex-buffer)
          (error 
           "Sorry, but this is not a multi-file document (Try C-u C-c C-n if using auctex)")))
    (save-excursion
      (set-buffer tex-buffer)
      ;; set its directory so relative includes work without expanding
      (setq default-directory dir)
      (insert-file-contents masterfile)
      (goto-char (point-min))
      (while (re-search-forward "^[ \t]*\\\\\\(input\\|include\\){\\(.*\\)}"
                                nil t)
        (let ((the-file (buffer-substring (match-beginning 2)(match-end 2))))
          (if (not (string-match ".tex$" the-file))
              (setq the-file (concat the-file ".tex")))
          (setq the-file (expand-file-name the-file dir))
          (if (not (file-readable-p the-file))
              (setq bib-document-TeX-files-warnings
                    (concat 
                     bib-document-TeX-files-warnings
                     (format "Warning: File not found: %s" the-file)))
            (setq the-list (cons (expand-file-name the-file dir) the-list))
            (end-of-line)(insert "\n")
            (insert-file-contents the-file)))))
    (kill-buffer tex-buffer)
    (nreverse the-list)))

(defun bib-document-citekeys-obarray ()
;; Return cite keys obarray for multi-file document, or nil if not a multi-file
;; document.  This is a auc-tex supported feature only.
;; Also, see bib-buffer-citekeys-obarray.
;; Sets global variable bib-document-citekeys-obarray-warnings.
  (setq bib-document-citekeys-obarray-warnings nil)
  (let ((master-tex (bib-master-file))
        (master-aux))
    (if (not master-tex)
        nil                             ;Not a multifile document.  No need...
      (setq master-aux (bib-return-aux-file-from-tex master-tex "aux"))
      (or (file-readable-p master-aux)
          (error "Sorry, cannot read file %s" master-aux))
      (and (file-newer-than-file-p master-tex master-aux)
           (setq bib-document-citekeys-obarray-warnings
                 (format "Warning: %s is out of date relative to %s.\n" 
                         master-aux master-tex)))
      (let ((work-buffer (get-buffer-create "*bib-cite-work*"))
            (keys-obarray (make-vector 201 0)))
        (save-excursion
          (set-buffer work-buffer)
          (insert-file-contents master-aux)
          ;; Because we will be looking for \input statements, we need to set
          ;; the default directory to that of the master file.
          (setq default-directory (file-name-directory master-tex))
          ;; bib-make-bibliography will need this also to find .bib files
          ;; look for \@input{chap1/part1.aux}
          (while (re-search-forward "^\\\\@input{\\(.*\\)}$" nil t)
            (let* ((auxfile (buffer-substring(match-beginning 1)(match-end 1)))
                   (texfile (bib-return-aux-file-from-tex auxfile "tex")))
              (if (not (file-readable-p auxfile))
                  (setq bib-document-citekeys-obarray-warnings
                        (concat 
                         bib-document-citekeys-obarray-warnings
                         (format "Warning: %s is not found or readable.\n" 
                                 auxfile)))
                (if (file-newer-than-file-p texfile auxfile)
                    (setq bib-document-citekeys-obarray-warnings
                          (concat 
                           bib-document-citekeys-obarray-warnings
                           (format 
                            "Warning: %s is out of date relative to %s.\n" 
                            auxfile texfile))))
                (end-of-line)(insert "\n")
                (insert-file-contents (buffer-substring (match-beginning 1)
                                                        (match-end 1))))))
          (goto-char 1)
          ;; look for \citation{gertsenshtein59}
          (while (re-search-forward "^\\\\citation{\\(.*\\)}$" nil t)
            (intern (buffer-substring (match-beginning 1)(match-end 1))
                    keys-obarray)))
        (kill-buffer work-buffer)
        keys-obarray))))

(defun bib-return-aux-file-from-tex (texname ext)
;; given name.name.XXX return name.name.ext
  (concat (substring texname 0 -3) ext)) 

(defun bib-etags-find-noselect (tag &optional masterdir)
;; Returns a buffer with point on `tag'.  buffer is not selected.
;; Makes sure TAGS file exists, etc.
  (let* ((master (or masterdir (bib-master-directory)))
         (the-buffer (current-buffer))
         (new-buffer)
         (the-tags-file-name (expand-file-name bib-etags-filename master)))
    (or (file-exists-p the-tags-file-name) ;make sure TAGS exists
        (bib-etags master))
    (or (equal the-tags-file-name tags-file-name) ;make sure it's current
        (visit-tags-table the-tags-file-name)) 
    ;; find-tag-noselect should set the TAGS file for the new buffer
    ;; that's what C-h f visit-tags-table says...
    (setq new-buffer (find-tag-noselect tag)) ;Seems to set buffer to TAGS
    (set-buffer the-buffer)
    new-buffer))

;;---------------------------------------------------------------------------
;; imenu stuff
;; All of this should only be loaded if imenu is *already* loaded because
;; we redine imenu here.

(cond
 (bib-use-imenu
  (require 'imenu)
  (require 'cl)
  (add-hook 'LaTeX-mode-hook 'LaTeX-hook-setq-imenu)

  (defun LaTeX-hook-setq-imenu ()
    ;; User who *never* use multi-file documents could change this to:
    ;;                                  'imenu--craete-LaTeX-index-for-buffer
    (setq imenu-create-index-function 'imenu--create-LaTeX-index))

  (defun imenu--create-LaTeX-index ()
    ;; dispatch to proper function, depending on whether a multi-file document.
    (let ((masterfile (bib-master-file)))
      (if masterfile
          (imenu--create-LaTeX-index-for-document masterfile)
        (imenu--create-LaTeX-index-for-buffer))))

  (defun imenu--create-LaTeX-index-for-document (masterfile)
    ;; For a multi-file document in auctex only.
    ;; Create imenu--index-alist for master file buffer and use the same
    ;; for all input files?  This would be faster...  Maybe in next version?
    (bib-etags)                         ;Create a new TAGS file, user needs it.
    (let ((tex-buffer (get-buffer-create "*imenu-tex*"))
          (index-alist '())
          (index-label-alist '())
          (prev-pos))
      (save-excursion
        (set-buffer tex-buffer)
        ;; set its directory so relative includes work without expanding
        (setq default-directory (file-name-directory masterfile))
        (insert-file-contents masterfile)
        (goto-char (point-min))
        (while (re-search-forward 
                "^[ \t]*\\\\\\(input\\|include\\){\\([^}]*\\)}" nil t)
          (let ((the-file (buffer-substring (match-beginning 2)(match-end 2))))
            (if (not (string-match ".tex$" the-file))
                (setq the-file (concat the-file ".tex")))
            (end-of-line)(insert "\n")
            (insert-file-contents the-file)))
        ;; Now, the document is like any other tex file
        (setq bib-imenu-document-counter -99) ;IDs menu entries start at -100
        (goto-char (point-max))
        (imenu-progress-message prev-pos 0)
        (while (re-search-backward  
                "\\\\\\(\\(sub\\)*section\\|chapter\\|label\\){[^}]+}" nil t)
          (imenu-progress-message prev-pos nil t)
          (save-match-data
            (save-excursion
              (cond
               ((looking-at "\\\\\\\(s\\|c\\)")
                (search-forward "}" nil t)
                (push (imenu--LaTeX-name-and-etags)
                      index-alist))
               (t
                (search-forward "}" nil t)
                (push (imenu--LaTeX-name-and-etags)
                      index-label-alist))))))
        (kill-buffer tex-buffer)
        (imenu-progress-message prev-pos 100)
        (and index-label-alist
             (push (cons (imenu-create-submenu-name "Labels") 
                         index-label-alist)
                   index-alist))
        index-alist)))

  (defun imenu--create-LaTeX-index-for-buffer ()
    ;; For non-multi-file documents.
    (let ((index-alist '())
          (index-label-alist '())
          prev-pos)
      (setq bib-imenu-document-counter -99) ;IDs menu entries starting at -100
      (goto-char (point-max))
      (imenu-progress-message prev-pos 0)
      (while (re-search-backward  
              "\\\\\\(\\(sub\\)*section\\|chapter\\|label\\){[^}]+}" nil t)
        (imenu-progress-message prev-pos nil t)
        (save-match-data
          (save-excursion
            (cond
             ((looking-at "\\\\\\\(s\\|c\\)")
              (search-forward "}" nil t)
              (push (imenu--LaTeX-name-and-position)
                    index-alist))
             (t
              (search-forward "}" nil t)
              (push (imenu--LaTeX-name-and-position)
                    index-label-alist))))))
      (imenu-progress-message prev-pos 100)
      (and index-label-alist
           (push (cons (imenu-create-submenu-name "Labels") index-label-alist)
                 index-alist))
      index-alist))

  (defun imenu--LaTeX-name-and-position ()
    (save-excursion
      (search-backward "\\" nil t)
      (let ((beg (point))
            (end (search-forward "}" nil t))
            (marker (make-marker)))
        (set-marker marker beg)
        (cons (buffer-substring beg end)
              marker))))

  (defun imenu--LaTeX-name-and-etags ()
    (save-excursion
      (setq bib-imenu-document-counter (1- bib-imenu-document-counter))
      (cons (buffer-substring (search-backward "\\" nil t) 
                              (search-forward "}" nil t))
            bib-imenu-document-counter)))

  (defun imenu ()
    "Jump to a place in the buffer chosen using a buffer menu or mouse menu.
See `imenu-choose-buffer-index' for more information."
    ;; Edited to use tags if necessary.
    (interactive)
    (require 'imenu)                    ;PSG added this also. Not an autoload.
    (let ((index-item (imenu-choose-buffer-index)))
      (and index-item
           (progn
             (push-mark)
             (cond
              ((markerp (cdr index-item))
               (goto-char (marker-position (cdr index-item))))
              ((and (numberp (cdr index-item))
                    (< (cdr index-item) -99))
               (find-tag (car index-item)))
              (t
               (goto-char (cdr index-item))))))))

;;; end of bib-use-imenu stuff
))
;; --------------------------------------------------------------------------
;; The following routines make a temporary bibliography buffer 
;; holding all bibtex files found.

(defun bib-get-bibliography (include-filenames-f)
  "Returns a new bibliography buffer holding all bibtex files in the document.

If using auc-tex, and either TeX-parse-self is set or C-c C-n is used to 
parse the document, then the entire multifile document will be searched 
for \bibliography commands.

If this fails, the current buffer is searched for the first \bibliography 
command.

If include-filenames-f is true, include as a special header the filename
of each bib file.

Puts the buffer in text-mode such that forward-sexp works with german \" 
accents embeeded in bibtex entries."
  (let ((bib-list (or (and (fboundp 'LaTeX-bibliography-list)
                           (boundp 'TeX-auto-update)
                           (LaTeX-bibliography-list))
;; LaTeX-bibliography-list (if bound) returns an unformatted list of
;; bib files used in the document, but only if parsing is turned on
;; or C-c C-n was used.
                      (bib-bibliography-list)))
        (bib-buffer (get-buffer-create "*bibtex-bibliography*"))
        ;; Path is relative to the master directory
        (default-directory (bib-master-directory))
        (the-name)(the-warnings)(the-file))
    (save-excursion
      (set-buffer bib-buffer)
      (text-mode)) ;such that forward-sexp works with embeeded \" in german
    ;;We have a list of bib files
    ;;Search for them, include them, list those not readable
    (while bib-list
      (setq the-name (car (car bib-list))) ;Extract the string only
      (setq bib-list (cdr bib-list))
      (setq the-name 
            (substring the-name 
                       (string-match "[^ ]+" the-name) ;remove leading spaces
                       (string-match "[ ]+$" the-name))) ;remove trailing space 
      (if (not (string-match "\\.bib$" the-name))
          (setq the-name (concat the-name ".bib")))
      (setq the-file
            (or
             (and (file-readable-p (expand-file-name (concat "./" the-name)))
                  (expand-file-name (concat "./" the-name)))
             (psg-checkfor-file-list the-name 
                                     (psg-list-env bib-bibtex-env-variable))
             (and (boundp 'TeX-check-path)
                  (psg-checkfor-file-list the-name TeX-check-path))))
      (if the-file
          (progn 
            (save-excursion
              (set-buffer bib-buffer)
              (goto-char (point-max))
              (if include-filenames-f
                  (insert "%%%Filename: " the-file "\n"))
              (insert-file-contents the-file nil)
              (goto-char 1)))
        (setq the-warnings 
              (concat the-warnings "Could not read file: " the-name "\n"))))
    (if the-warnings
        (progn
          (with-output-to-temp-buffer "*Help*" 
            (princ the-warnings))
          (kill-buffer bib-buffer)
          (error 
           "Sorry, can't find all bibtex files in \\bibliography command"))
      bib-buffer)))

(defun bib-bibliography-list ()
  "Return list of bib files listed in first \\bibliography command in buffer
Similar output to auc-tex's LaTeX-bibliography-list
The first element may contain trailing whitespace (if there was any in input)
although BiBTeX doesn't allow it!"
  (save-excursion
    (goto-char 1)
    (if (not (re-search-forward "^[ \t]*\\\\bibliography{[ \t]*\\([^},]+\\)" 
                                nil t))
        (error "Sorry, can't find \\bibliography command anywhere")
      (let ((the-list (list (buffer-substring 
                             (match-beginning 1)(match-end 1))))
            (doNext t))
        (while doNext
          (if (looking-at ",")
              (setq the-list
                    (append the-list
                            (list (buffer-substring 
                                   (progn (skip-chars-forward ", ")(point))
                                   (progn (re-search-forward "[,}]" nil t)
                                          (backward-char 1)
                                          (skip-chars-backward ", ")
                                          (point))))))
            (setq doNext nil)))
        (mapcar 'list the-list)))))

;; ---------------------------------------------------------------------------
;; Key definitions start here... (but not for xemacs!)

;; BibTeX-mode key def to create auc-tex's parsing file. 
(defun bib-create-auto-file ()
  "Force the creation of the auc-tex auto file for a bibtex buffer"
  (interactive)
  (if (not (require 'latex))
      (error "Sorry, This is only useful if you have auc-tex")) 
  (let ((TeX-auto-save t))
    (TeX-auto-write)))

;;; >>>This section can be removed if incorporated into auctex
;;; >>>by defining the menus in auc-tex (with auto-loads)
;;; pull-down menu key defs

(if (and (not (string-match "XEmacs\\|Lucid" emacs-version))
         (string-equal "19" (substring emacs-version 0 2))
         window-system)
    (progn
      ;; to auc-tex auto file for a bibtex buffer
      (if (boundp 'bibtex-mode-map)
          (progn
            (define-key-after 
              (lookup-key bibtex-mode-map [menu-bar move/edit]) 
              [bib-nil]
              '("---" . nil)
              '"--")
            (define-key-after 
              (lookup-key bibtex-mode-map [menu-bar move/edit]) 
              [bib-apropos]
              '("Search Apropos" . bib-apropos)
              'bib-nil)
            (define-key-after 
              (lookup-key bibtex-mode-map [menu-bar move/edit]) 
              [auc-tex-parse]
              '("Create auc-tex auto parsing file" . bib-create-auto-file)
              'bib-apropos))
        (if (and (fboundp 'add-hook) (fboundp 'remove-hook))
            (progn
              (defun bib-bibtex-mode-hook ()
                "hook created by bib-cite.el"
                (define-key-after 
                  (lookup-key bibtex-mode-map [menu-bar move/edit]) 
                  [bib-nil]
                  '("---" . nil)
                  '"--")
                (define-key-after 
                  (lookup-key bibtex-mode-map [menu-bar move/edit]) 
                  [bib-apropos]
                  '("Search Apropos" . bib-apropos)
                  'bib-nil)
                (define-key-after 
                  (lookup-key bibtex-mode-map [menu-bar move/edit]) 
                  [auc-tex-parse]
                  '("Create auc-tex auto parsing file" . 
                    bib-create-auto-file)
                  'bib-apropos)
                (remove-hook 'bibtex-mode-hook 'bib-bibtex-mode-hook))
              (add-hook 'bibtex-mode-hook 'bib-bibtex-mode-hook))))

      ;;for plain tex-mode
      (if (boundp 'tex-mode-map)
          (progn                        ; ...already loaded
            (define-key tex-mode-map [S-mouse-1] 'bib-display-mouse)
            (define-key tex-mode-map [S-mouse-2] 'bib-find-mouse)
            (define-key tex-mode-map [menu-bar tex bib-display]
              '("Display citation or matching \\ref or \\label" 
                . bib-display))
            (define-key tex-mode-map [menu-bar tex bib-find]
              '("Find BiBTeX citation or matching \\ref or \\label" 
                . bib-find))
            (define-key tex-mode-map [menu-bar tex bib-make-bibliography]
              '("Make BiBTeX bibliography buffer" . bib-make-bibliography))
            (define-key tex-mode-map [menu-bar tex bib-apropos]
              '("Search apropos BiBTeX files" . bib-apropos)))
        ;; tex-mode is not already loaded, so put into a hook for later loading
        (if (and (fboundp 'add-hook) (fboundp 'remove-hook))
            (progn
              (defun bib-tex-mode-hook ()
                "hook created by bib-cite.el"
                (define-key tex-mode-map [S-mouse-1] 'bib-display-mouse)
                (define-key tex-mode-map [S-mouse-2] 'bib-find-mouse)
                (define-key tex-mode-map [menu-bar tex bib-display]
                  '("Display citation or matching \\ref or \\label" 
                    . bib-display))
                (define-key tex-mode-map [menu-bar tex bib-find]
                  '("Find BiBTeX citation or matching \\ref or \\label" 
                    . bib-find))
                (define-key tex-mode-map [menu-bar tex bib-make-bibliography]
                  '("Make BiBTeX bibliography buffer" . bib-make-bibliography))
                (define-key tex-mode-map [menu-bar tex bib-apropos]
                  '("Search apropos BiBTeX files" . bib-apropos))
                (remove-hook 'tex-mode-hook 'bib-tex-mode-hook))
              (add-hook 'tex-mode-hook 'bib-tex-mode-hook))))

      ;;for loaded auc-tex's LaTeX-mode
      ;; Use define-key-after (must be compatible with alpha version as well)
      (if (boundp 'LaTeX-mode-map)
          (progn
            (define-key LaTeX-mode-map [S-mouse-1] 'bib-display-mouse)
            (define-key LaTeX-mode-map [S-mouse-2] 'bib-find-mouse)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
              [bib-nil]
              '("---" . nil)
              '"--")
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
              [bib-make-bibliography]
              '("Make BiBTeX bibliography buffer" . bib-make-bibliography)
              'bib-nil)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
              [bib-display]
              '("Display citation or matching \\ref or \\label" . bib-display)
              'bib-make-bibliography)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
              [bib-find]
              '("Find BiBTeX citation or matching \\ref or \\label" . bib-find)
              'bib-display)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
              [bib-apropos]
              '("Search apropos BiBTeX files" . bib-apropos)
              'bib-find)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
              [bib-etags]
              '("Build TAGS file for multi-file document" . bib-etags)
              'bib-apropos)
            (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
              [bib-highlight-mouse]
              '("Refresh \\cite, \\ref and \\label mouse highlight" 
                . bib-highlight-mouse)
              'bib-etags))

        ;; not already loaded, so put into a hook for later loading
        (if (and (fboundp 'add-hook) (fboundp 'remove-hook))
            (progn
              (defun bib-LaTeX-mode-hook ()
                "hook created by bib-cite.el"
                (define-key LaTeX-mode-map [S-mouse-1] 'bib-display-mouse)
                (define-key LaTeX-mode-map [S-mouse-2] 'bib-find-mouse)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
                  [bib-nil]
                  '("---" . nil)
                  '"--")
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
                  [bib-make-bibliography]
                  '("Make BiBTeX bibliography buffer" . bib-make-bibliography)
                  'bib-nil)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
                  [bib-display]
                  '("Display citation or matching \\ref or \\label" . 
                    bib-display)
                  'bib-make-bibliography)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX]) 
                  [bib-find]
                  '("Find BiBTeX citation or matching \\ref or \\label" . 
                    bib-find)
                  'bib-display)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
                  [bib-apropos]
                  '("Search apropos BiBTeX files" . bib-apropos)
                  'bib-find)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
                  [bib-etags]
                  '("Build TAGS file for multi-file document" . bib-etags)
                  'bib-apropos)
                (define-key-after (lookup-key LaTeX-mode-map [menu-bar LaTeX])
                  [bib-highlight-mouse]
                  '("Refresh \\cite, \\ref and \\label mouse highlight" 
                    . bib-highlight-mouse)
                  'bib-etags)
                (remove-hook 'LaTeX-mode-hook 'bib-LaTeX-mode-hook))
              (add-hook 'LaTeX-mode-hook 'bib-LaTeX-mode-hook))))

;;;>>>This doesn't work... why?
      ;;if auc-tex's LaTeX-mode is not loaded.  It will get the key defs
      ;;from auc-tec's TeX-mode-map.  Is this a problem?
;;;<<<This doesn't work... why?
      (if (boundp 'TeX-mode-map)
          (progn
            (define-key TeX-mode-map [S-mouse-1] 'bib-display-mouse)
            (define-key TeX-mode-map [S-mouse-2] 'bib-find-mouse)
            (define-key TeX-mode-map [menu-bar TeX bib-display]
              '("Display citation or matching \\ref or \\label" 
                . bib-display))
            (define-key TeX-mode-map [menu-bar TeX bib-find]
              '("Find BiBTeX citation or matching \\ref or \\label" 
                . bib-find))
            (define-key TeX-mode-map [menu-bar TeX bib-make-bibliography]
              '("Make BiBTeX bibliography buffer" . bib-make-bibliography))
            (define-key TeX-mode-map [menu-bar TeX bib-apropos]
              '("Search apropos BiBTeX files" . bib-apropos))
            (define-key TeX-mode-map [menu-bar TeX bib-etags]
              '("Build TAGS file for multi-file document" . bib-etags))
            (define-key TeX-mode-map [menu-bar TeX bib-highlight-mouse]
              '("Refresh \\cite, \\ref and \\label mouse highlight"
                . bib-highlight-mouse)))
        (if (and (fboundp 'add-hook) (fboundp 'remove-hook))
            (progn
              (defun bib-TeX-mode-hook ()
                "hook created by bib-cite.el"
                (define-key TeX-mode-map [S-mouse-1] 'bib-display-mouse)
                (define-key TeX-mode-map [S-mouse-2] 'bib-find-mouse)
                (define-key TeX-mode-map [menu-bar TeX bib-display]
                  '("Display citation or matching \\ref or \\label" 
                    . bib-display))
                (define-key TeX-mode-map [menu-bar TeX bib-find]
                  '("Find BiBTeX citation or matching \\ref or \\label" 
                    . bib-find))
                (define-key TeX-mode-map [menu-bar TeX bib-make-bibliography]
                  '("Make BiBTeX bibliography buffer" . bib-make-bibliography))
                (define-key TeX-mode-map [menu-bar TeX bib-apropos]
                  '("Search apropos BiBTeX files" . bib-apropos))
                (define-key TeX-mode-map [menu-bar TeX bib-etags]
                  '("Build TAGS file for multi-file document" . bib-etags))
                (define-key TeX-mode-map [menu-bar TeX bib-highlight-mouse]
                  '("Refresh \\cite, \\ref and \\label mouse highlight"
                    . bib-highlight-mouse))
                (remove-hook 'TeX-mode-hook 'bib-TeX-mode-hook))
              (add-hook 'TeX-mode-hook 'bib-TeX-mode-hook))))))

;;; <<<This section can be removed if incorporated into auctex
;;; <<<by defining the menus in auc-tex (with auto-loads)

;; --------------------------------------------------------------------------
;; The following routines are also defined in other packages...

;; Must be in sync with function of same name in ff-paths.el
(defun psg-checkfor-file-list (filename list)
  "Check for presence of FILENAME in directory LIST. Return 1st found path."
  ;;USAGE: (psg-checkfor-file-list "gri.cmd" (psg-list-env "PATH"))
  ;;USAGE: (psg-checkfor-file-list "gri-mode.el" load-path)
  ;;USAGE: (psg-checkfor-file-list "gri.cmd" (psg-translate-ff-list "gri.tmp"))
  (let ((the-list list) 
        (filespec))
    (while the-list
      (if (not (car the-list))          ; it is nil
          (setq filespec (concat "~/" filename))
        (setq filespec 
              (concat (file-name-as-directory (car the-list)) filename)))
      (if (file-exists-p filespec)
            (setq the-list nil)
        (setq filespec nil)
        (setq the-list (cdr the-list))))
    filespec))

(or (fboundp 'dired-replace-in-string)
    ;; This code is part of GNU emacs
    (defun dired-replace-in-string (regexp newtext string)
      ;; Replace REGEXP with NEWTEXT everywhere in STRING and return result.
      ;; NEWTEXT is taken literally---no \\DIGIT escapes will be recognized.
      (let ((result "") (start 0) mb me)
        (while (string-match regexp string start)
          (setq mb (match-beginning 0)
                me (match-end 0)
                result (concat result (substring string start mb) newtext)
                start me))
        (concat result (substring string start)))))


;; Could use fset here to equal TeX-split-string to dired-split if only 
;; dired-split is defined.  That would eliminate a check in psg-list-env.
(and (not (fboundp 'TeX-split-string))
     (not (fboundp 'dired-split))
     ;; This code is part of auc-tex
     (defun TeX-split-string (char string)
       "Returns a list of strings. given REGEXP the STRING is split into 
sections which in string was seperated by REGEXP.

Examples:

      (TeX-split-string \"\:\" \"abc:def:ghi\")
          -> (\"abc\" \"def\" \"ghi\")

      (TeX-split-string \" *\" \"dvips -Plw -p3 -c4 testfile.dvi\")

          -> (\"dvips\" \"-Plw\" \"-p3\" \"-c4\" \"testfile.dvi\")

If CHAR is nil, or \"\", an error will occur."
       
       (let ((regexp char)
             (start 0)
             (result '()))
         (while (string-match regexp string start)
           (let ((match (string-match regexp string start)))
             (setq result (cons (substring string start match) result))
             (setq start (match-end 0))))
         (setq result (cons (substring string start nil) result))
         (nreverse result))))

;; Must be in sync with function of same name in ff-paths.el
;; (See also PC-include-file-path in standard emacs ditsribution.)
(defun psg-list-env (env)
  "Return a list of directory elements in ENVIRONMENT variable (w/o leading $)
argument may consist of environment variable plus a trailing directory, e.g.
HOME or HOME/bin (trailing directory not supported in dos or OS/2).

bib-dos-or-os2-variable affects:
  path separator used (: or ;)
  whether backslashes are converted to slashes"
  (let* ((value (if bib-dos-or-os2-variable
                    (dired-replace-in-string "\\\\" "/" (getenv env))
                  (getenv env)))
         (sep-char (or (and bib-dos-or-os2-variable ";") ":"))
         (entries (and value 
                       (or (and (fboundp 'TeX-split-string)
                                (TeX-split-string sep-char value))
                           (dired-split sep-char value))))
         entry
	 answers)
    (while entries
      (setq entry (car entries))
      (setq entries (cdr entries))
      (if (file-directory-p entry)
          (setq answers (cons entry answers))))
    (nreverse answers)))

;; If bib-cite.el is loaded in LaTeX-mode-hook the bib-highlight-mouse is not
;; called on this buffer... so invoke it now for .tex buffers.  Same for imenu.
(if (string-match ".tex$" (buffer-name))
    (progn
      (LaTeX-hook-setq-imenu)
      (bib-highlight-mouse)))

(provide 'bib-cite)
;;; bib-cite.el ends here

