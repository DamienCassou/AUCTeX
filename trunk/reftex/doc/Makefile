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

TEXI2DVI=texi2dvi
TEXI2PDF=texi2dvi --pdf
MAKEINFO=makeinfo
MAKEINFO_PLAIN=-D rawfile --no-headers
TEXI2HTML=makeinfo --no-split --html --number-sections
DVIPS=dvips
INSTALL_INFO=install-info
DISTTEXTS=../CHANGES

.PHONY: all info dvi ps pdf html install dist clean maintainer-clean

all: info

info: reftex.info

dvi: reftex.dvi

ps: reftex.ps

pdf: reftex.pdf

html: reftex.html

reftex.info: reftex.texi
	$(MAKEINFO) --no-split reftex.texi

reftex.dvi: reftex.texi
	$(TEXI2DVI) reftex.texi

reftex.ps: reftex.dvi
	$(DVIPS) -o reftex.ps reftex.dvi

reftex.pdf: reftex.texi
	$(TEXI2PDF) reftex.texi

reftex.html: reftex.texi
	$(TEXI2HTML) reftex.texi

../CHANGES: changes.texi
	$(MAKEINFO) $(MAKEINFO_PLAIN) changes.texi --output $@

install: reftex.info
	if [ ! -d $(infodir) ]; then $(MKDIR) $(infodir); else true; fi ;
	$(CP) reftex.info $(infodir)
	-$(INSTALL_INFO) --info-dir=$(infodir) reftex.info

clean:
	rm -f *.aux *.cp *.cps *.dvi *.fn *.fns *.ky *.kys *.pg *.pgs
	rm -f *.toc *.tp *.tps *.vr *.vrs *.log *.html *.ps

maintainer-clean: clean
	rm -f $(DISTTEXTS) reftex.info

dist: $(DISTTEXTS) reftex.info
