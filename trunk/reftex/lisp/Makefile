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

BATCH=$(EMACS) -batch -q -l lpath.el
ELC=$(BATCH) -f batch-byte-compile
LISPFILES=reftex-vars.el reftex.el reftex-auc.el reftex-cite.el\
	reftex-global.el reftex-parse.el reftex-ref.el\
	reftex-sel.el reftex-toc.el reftex-dcr.el reftex-index.el
ELCFILES=$(LISPFILES:.el=.elc)

.PHONY: all install

all: lisp

lisp: $(LISPFILES)
	$(ELC) $(LISPFILES)

install: $(LISPFILES) $(ELCFILES)
	if [ ! -d $(lispdir) ]; then $(MKDIR) $(lispdir); else true; fi ;
	$(CP) $(LISPFILES) $(lispdir)
	$(CP) $(ELCFILES)  $(lispdir)
