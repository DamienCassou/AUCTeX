# Makefile - for the RefTeX distribution.
#
# Maintainer: Carsten Dominik <dominik@science.uva.nl>
# Version: 4.31 
#
# To install RefTeX, edit the Makefile, type `make', then `make install'.
# To create the postscript documentation file reftex.ps, type `make ps'.
# To create the HTML documentation file reftex.html, type `make html'.

##----------------------------------------------------------------------
##  YOU MUST EDIT THE FOLLOWING LINES 
##----------------------------------------------------------------------

# Where local software is found
prefix=/usr/local

# Where info files go.
infodir = $(prefix)/info

# Where local lisp files go.
lispdir = $(prefix)/share/emacs/site-lisp

# Name of your emacs binary
EMACS=xemacs

##----------------------------------------------------------------------
## YOU MAY NEED TO EDIT THESE
##----------------------------------------------------------------------

# Using emacs in batch mode.
BATCH=$(EMACS) -batch -q -l lpath.el

# Specify the byte-compiler for compiling RefTeX files
ELC= $(BATCH) -f batch-byte-compile

# How to make a dvi file from a texinfo file
TEXI2DVI = texi2dvi

# How to make a pdf file from a texinfo file
TEXI2PDF = texi2dvi --pdf

# How to create directories
MKDIR = mkdir -p

# How to make a postscript file from a dvi file
DVIPS = dvips

# How to create the info files from the texinfo file
MAKEINFO = makeinfo

# How to create the HTML file
#TEXI2HTML = texi2html -monolithic -number
TEXI2HTML = makeinfo --no-split --html --number-sections

# How to move the byte compiled files to their destination.  
MV = mv

# How to copy the lisp files to their distination.
CP = cp -p

##----------------------------------------------------------------------
##  BELOW THIS LINE ON YOUR OWN RISK!
##----------------------------------------------------------------------

# The following variables need to be defined by the maintainer
LISPFILES  = reftex-vars.el reftex.el reftex-auc.el reftex-cite.el\
             reftex-global.el reftex-parse.el reftex-ref.el\
             reftex-sel.el reftex-toc.el reftex-dcr.el reftex-index.el
ELCFILES   = $(LISPFILES:.el=.elc)
TEXIFILES  = reftex.texi
INFOFILES  = reftex
FTPDIR     = /home/dominik/public_html/Tools/reftex
HTMLDIR    = /home/dominik/public_html

# An alternative installation point
MY_INFODIR = /home/strw/dominik/lib/emacs/info
MY_LISPDIR = /home/strw/dominik/lib/emacs/lisp

.SUFFIXES: .el .elc .texi
SHELL = /bin/sh

DISTFILES=  README INSTALL CHANGES COPYING Makefile\
	    $(LISPFILES) reftex.texi $(INFOFILES) lpath.el

XEMACSDISTFILES= CHANGES COPYING README \
	$(LISPFILES) $(TEXIFILES) Makefile.xemacs-package \
	package-info.in

EMACSDISTFILES= $(LISPFILES) $(TEXIFILES) ChangeLog

all:	lisp

install: install-lisp install-info

lisp:	$(LISPFILES)
	$(ELC) $(LISPFILES)

compile: $(LISPFILES)
	$(ELC) $(LISPFILES)

info:	$(INFOFILES)

dvi:    reftex.dvi

view:   
	xdvi reftex.dvi&

ps:	reftex.ps

pdf:	reftex.pdf

html:	reftex.html

nutshell: reftex.nutshell

install-lisp: $(LISPFILES) $(ELCFILES)
	if [ ! -d $(lispdir) ]; then $(MKDIR) $(lispdir); else true; fi ;
	$(CP) $(LISPFILES) $(lispdir)
	$(CP) $(ELCFILES)  $(lispdir)

install-info: $(INFOFILES)
	if [ ! -d $(infodir) ]; then $(MKDIR) $(infodir); else true; fi ;
	$(CP) $(INFOFILES) $(infodir)

reftex.elc: reftex.el
	$(ELC) reftex.el

reftex: reftex.texi
	$(MAKEINFO) --no-split reftex.texi

reftex.dvi: reftex.texi
	$(TEXI2DVI) reftex.texi

reftex.ps: reftex.dvi
	$(DVIPS) -o reftex.ps reftex.dvi

reftex.pdf: reftex.texi
	$(TEXI2PDF) reftex.texi

reftex.html: reftex.texi
	$(TEXI2HTML) reftex.texi

reftex.nutshell: reftex.html
	perl nutshell.pl reftex.html > reftex.nutshell

wcompile:
	xemacs -batch -q -l lpath-warn.el -f batch-byte-compile $(LISPFILES)

ecompile:
	emacs -batch -q -l lpath-warn.el -f batch-byte-compile $(LISPFILES)

ccompile:
	xemacs -batch -q -l lpath-compatible.el -f batch-byte-compile $(LISPFILES)

myinstall: $(LISPFILES) $(ELCFILES) $(INFOFILES)
	if [ ! -d $(MY_LISPDIR) ]; then $(MKDIR) $(MY_LISPDIR); else true; fi ;
	$(CP) $(LISPFILES) $(MY_LISPDIR)
	$(CP) $(ELCFILES)  $(MY_LISPDIR)
	if [ ! -d $(MY_INFODIR) ]; then $(MKDIR) $(MY_INFODIR); else true; fi ;
	$(CP) $(INFOFILES) $(MY_INFODIR)

distfile:
	make info
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	rm -rf reftex-$(TAG)
	$(MKDIR) reftex-$(TAG)
	cp $(DISTFILES) reftex-$(TAG)/
	perl -pi -e 's/\sVERSIONTAG\b/ $(TAG)/' reftex-$(TAG)/*
	gtar zcvf reftex-$(TAG).tar.gz reftex-$(TAG)

# Note: XTAG must be tag of the current XEmacs package.  The version
#       number will be increased automatically by the XEmacs people.
xemacsdistfile:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	@if [ "X$(XTAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	rm -rf reftex-$(TAG)
	mkdir reftex-$(TAG)
	cp $(XEMACSDISTFILES) reftex-$(TAG)/
	mv reftex-$(TAG)/Makefile.xemacs-package reftex-$(TAG)/Makefile
	perl -pi -e 's/\sVERSIONTAG\b/ $(TAG)/' reftex-$(TAG)/*
	perl -pi -e 's/\sXVERSIONTAG\b/ $(XTAG)/' reftex-$(TAG)/*

xemacspatch:
	make xemacsdistfile TAG=$(TAG) XTAG=$(XTAG)
	(cd xemacs-reftex;cvs up)
	-diff -c --exclude ChangeLog xemacs-reftex reftex-$(TAG) \
		> xemacs-patch

dist:
	make distfile TAG=$(TAG)
	cp reftex-$(TAG).tar.gz $(FTPDIR)
	rm -f $(FTPDIR)/reftex.tar.gz
	rm -f $(FTPDIR)/reftex-alpha.tar.gz
	(cd $(FTPDIR); ln -s reftex-$(TAG).tar.gz reftex.tar.gz)
	(cd $(FTPDIR); ln -s reftex-$(TAG).tar.gz reftex-alpha.tar.gz)
	make ps
	make pdf
	make html
	gtar zcvf reftex.info.tar.gz $(INFOFILES)
	cp reftex.html $(HTMLDIR)/Tools/reftex/
	cp reftex.pdf $(HTMLDIR)/Tools/reftex/
	gzip -c reftex.ps > $(FTPDIR)/reftex.ps.gz
	gzip -c reftex.texi > $(FTPDIR)/reftex.texi.gz
	cp reftex.info.tar.gz $(FTPDIR)
	cp CHANGES $(HTMLDIR)/Tools/reftex/
	 #make nutshell
	 #cp reftex.nutshell $(HTMLDIR)/Tools/reftex/reftex.nutshell

alphadist:
	make distfile TAG=$(TAG)
	cp reftex-$(TAG).tar.gz $(FTPDIR)
	cp CHANGES $(HTMLDIR)/Tools/reftex/
	rm -f $(FTPDIR)/reftex-alpha.tar.gz
	(cd $(FTPDIR); ln -s reftex-$(TAG).tar.gz reftex-alpha.tar.gz)

distfile_emacs:
	rm -rf distributions/Emacs/reftex
	$(MKDIR) distributions/Emacs/reftex
	cp $(LISPFILES) reftex.texi etcNEWS distributions/Emacs/reftex
submit_emacs:
	make distfile_emacs
	cp -r distributions/Emacs/reftex distributions/Emacs/reftex-submitted
	cvs tag -F submit_emacs
patch_emacs:
	make distfile_emacs
	cp -r distributions/Emacs/reftex distributions/Emacs/reftex-submitted
	(cd distributions/Emacs; diff -c -r reftex.orig reftex>patch)
	cvs tag -F submit_emacs
accept_emacs:
	cp -r distributions/Emacs/reftex-submitted distributions/Emacs/reftex.orig
	cvs rtag -r submit_emacs -F accept_emacs

distfile_xemacs:
	rm -rf distributions/XEmacs/reftex
	$(MKDIR) distributions/XEmacs/reftex
	cp $(LISPFILES) reftex.texi etcNEWS distributions/XEmacs/reftex
submit_xemacs:
	make distfile_xemacs
	cp -r distributions/XEmacs/reftex distributions/XEmacs/reftex-submitted
	cvs tag -F submit_xemacs
patch_xemacs:
	make distfile_xemacs
	cp -r distributions/XEmacs/reftex distributions/XEmacs/reftex-submitted
	(cd distributions/XEmacs; diff -c -r reftex.orig reftex>patch)
	cvs tag -F submit_xemacs
accept_xemacs:
	cp -r distributions/XEmacs/reftex-submitted distributions/XEmacs/reftex.orig
	cvs rtag -r submit_xemacs -F accept_xemacs


package_xemacs:
	rm -rf distributions/XEmacs/package
	$(MKDIR) distributions/XEmacs/package
	$(MKDIR) distributions/XEmacs/package/lisp/reftex
	$(MKDIR) distributions/XEmacs/package/info/reftex
	$(MKDIR) distributions/XEmacs/package/pgkinfo
	$(MKDIR) distributions/XEmacs/package/man
	cp $(LISPFILES) $(ELCFILES) distributions/XEmacs/package/lisp/reftex
	cp $(INFOFILES) distributions/XEmacs/package/info/reftex
	cp $(TEXIFILES) distributions/XEmacs/package/man
	(cd distributions/XEmacs/package/;ls -1 > pgkinfo/MANIFEST.reftex)

clean:
	rm -f $(ELCFILES)
	rm -f *~ 
	rm -f *.aux *.cp *.cps *.dvi *.fn *.fns *.ky *.kys *.pg *.pgs
	rm -f *.toc *.tp *.tps *.vr *.vrs *.log *.html *.ps

veryclean:
	rm -f $(LISPFILES) $(ELCFILES) REFTEX.elc
	rm -f *~ reftex reftex-[1-9]
	rm -f *.aux *.cp *.cps *.dvi *.fn *.fns *.ky *.kys *.pg *.pgs
	rm -f *.toc *.tp *.tps *.vr *.vrs *.log *.html *.ps
	rm -f reftex-emacs.el reftex.el.orig reftex.texi.orig reftex.tar.gz
	rm -f reftex.info.tar.gz reftex.nutshell *-patch-*
	rm -f *.rel


linkelc:
	rm ../lisp/reftex*.elc
	(cd ../lisp;ln -s ../reftex/reftex*.elc .)

unlinkelc:
	rm ../lisp/reftex*.elc

.el.elc:
	$(ELC) $<

