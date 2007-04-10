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
# Analogously you can use the targets `pdf', `html', or `dvi' to
# generate documentation as PDF, HTML, or DVI file.

##----------------------------------------------------------------------
##  YOU MIGHT HAVE TO EDIT THE FOLLOWING LINES
##  (or pass your own values for them to make)
##----------------------------------------------------------------------

# Where local software is found
prefix=/usr/local

# Where info files go.
infodir=$(prefix)/share/info

# Where local lisp files go.
lispdir=$(prefix)/share/emacs/site-lisp/reftex

# Name of your emacs binary
EMACS=emacs

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

.PHONY: all install lisp info dvi ps pdf html dist clean maintainer-clean \
	release-commit release-sign release-upload

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
	cd doc && make html

clean:
	cd lisp && make clean
	cd doc && make clean

maintainer-clean:
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'
	cd lisp && make clean
	cd doc && make maintainer-clean

# Call `make dist' either with `TAG=X.Y' or `TAG=YYYYMMDD'.  (You can
# use `TAG=`date +%Y%m%d`' for automatic creation of the current
# date.)  It is assumed that there is a `release_XY' tag in CVS if
# `TAG=X.Y' is used.
#
# Calling the `dist' target will create a subdirectory `reftex-$(TAG)'
# with a clean checkout from CVS, generate info docs, and package the
# directory in a gzipped tar file.
dist:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	rm -rf reftex-$(TAG)
	mkdir reftex-$(TAG)
	cvs export -d reftex-$(TAG) \
          "`echo $(TAG) | sed -e '/^\([-0-9]*[0-9]\)[-a-z]*$$/s//-D \1T2359/' \
                             -e '/[.]/{s/^/-rrelease_/;s/[.]/_/g}'`" reftex
	cd reftex-$(TAG)/lisp && make dist
	cd reftex-$(TAG)/doc && make dist
	chmod -R go-w+rX reftex-$(TAG)
	tar -cf - --owner=root --group=root reftex-$(TAG) | \
	  gzip --best > reftex-$(TAG).tar.gz

##----------------------------------------------------------------------
##  RELEASE
##----------------------------------------------------------------------

# Steps for making a release:
# 1) release-commit: Tag the release.
# 2) dist: Create the tar ball.
# 3) release-sign: Sign the tar ball and create directive files for upload.
# 4) release-upload: Upload tar ball, signature, and directive file.

COMMITTER="Ralf Angeli  <angeli@caeruleus.net>"

release-commit:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	mv ChangeLog ChangeLog.old
	echo `date "+%Y-%m-%d "`" "${COMMITTER} > ChangeLog
	echo >> ChangeLog
	echo "	* Version" $(TAG) released. >> ChangeLog
	echo >> ChangeLog
	cat ChangeLog.old >> ChangeLog
	cvs commit -m 'release_$(TAG)' ChangeLog
	cvs tag release_`echo $(TAG) | sed -e 's/[.]/_/g'`

release-sign:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	read -sp "Enter pass phrase: " phrase ; \
	echo "$$phrase" | \
	  gpg --passphrase-fd 0 --detach-sign reftex-$(TAG).tar.gz ; \
	echo "version: 1.1\ndirectory: reftex\nfilename: reftex-$(TAG).tar.gz" \
	  >reftex-$(TAG).tar.gz.directive; \
	echo "$$phrase" | \
	  gpg --passphrase-fd 0 --clearsign reftex-$(TAG).tar.gz.directive ; \
	rm reftex-$(TAG).tar.gz.directive

release-upload:
	@if [ "X$(TAG)" = "X" ]; then echo "*** No tag ***"; exit 1; fi
	ncftpput ftp-upload.gnu.org /incoming/ftp reftex-$(TAG).tar.gz*
