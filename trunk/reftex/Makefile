# Makefile for the RefTeX distribution.

# Maintainer: auctex-devel@gnu.org

# Copyright (C) 2007 Free Software Foundation, Inc.

# This file is part of RefTeX.

# RefTeX is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# RefTeX is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with RefTeX; see the file COPYING.  If not, write to the Free
# Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

# Commentary:

# To install RefTeX, edit the Makefile, type `make', then `make install'.
# To create the PostScript documentation file reftex.ps, type `make ps'.
# To create the HTML documentation file reftex.html, type `make html'.

##----------------------------------------------------------------------
##  YOU MUST EDIT THE FOLLOWING LINES 
##----------------------------------------------------------------------

# Where local software is found
prefix=/usr/local

# Where info files go.
infodir=$(prefix)/share/info

# Where local lisp files go.
lispdir=$(prefix)/share/emacs/site-lisp/reftex

# Name of your emacs binary
EMACS=emacs

##----------------------------------------------------------------------
## YOU MAY NEED TO EDIT THESE
##----------------------------------------------------------------------

# How to create directories
MKDIR=mkdir -p

# How to move the byte compiled files to their destination.  
MV=mv

# How to copy the lisp files to their distination.
CP=cp -p

##----------------------------------------------------------------------
##  BELOW THIS LINE ON YOUR OWN RISK!
##----------------------------------------------------------------------

SHELL=/bin/sh

.SUFFIXES: .el .elc .texi

.PHONY: all install lisp info dvi ps pdf html dist

all: lisp

lisp:
	cd lisp && make EMACS="$(EMACS)" lisp

install:
	cd lisp && make CP="$(CP)" MKDIR="$(MKDIR)" lispdir="$(lispdir)" install
	cd doc && make CP="$(CP)" MKDIR="$(MKDIR)" infodir="$(infodir)" install

info:
	cd doc && make info

dvi:
	cd doc && make dvi

ps:
	cd doc && make ps

pdf:
	cd doc && make pdf

html:
	cd doc && make ps

# Call `make dist' either with `TAG=X.Y' or `TAG=YYYYMMDD'.  (You can
# use `TAG=`date +%Y%m%d`' for automatic creation of the current date.)
# Calling the `dist' target will create a subdirectory `reftex-$(TAG)'
# with a clean checkout from CVS, generate info docs, and package
# the directory in a gzipped tar file.
dist:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	rm -rf reftex-$(TAG)
	mkdir reftex-$(TAG)
	cvs export -d reftex-$(TAG) \
          "`echo $(TAG) | sed -e '/^\([-0-9]*[0-9]\)[-a-z]*$$/s//-D \1T2359/' \
                             -e '/[.]/{s/^/-r release_/;s/[.]/_/g}'`" reftex
	cd reftex-$(TAG)/doc && make dist
	chmod -R go-w+rX reftex-$(TAG)
	tar -cf - --owner=root --group=root reftex-$(TAG) | \
	  gzip --best > reftex-$(TAG).tar.gz


# =====================================================================
# From original import below this point.

# The following variables need to be defined by the maintainer
FTPDIR     = /home/dominik/public_html/Tools/reftex
HTMLDIR    = /home/dominik/public_html

# An alternative installation point
MY_INFODIR = /home/strw/dominik/lib/emacs/info
MY_LISPDIR = /home/strw/dominik/lib/emacs/lisp

DISTFILES=  README INSTALL CHANGES COPYING Makefile\
	    $(LISPFILES) reftex.texi $(INFOFILES) lpath.el

XEMACSDISTFILES= CHANGES COPYING README \
	$(LISPFILES) $(TEXIFILES) Makefile.xemacs-package \
	package-info.in

reftex.elc: reftex.el
	$(ELC) reftex.el

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

