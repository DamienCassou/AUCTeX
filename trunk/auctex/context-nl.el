;;; context-nl.el --- Support for the ConTeXt dutch interface.
;;
;; Maintainer: Berend de Boer <berend@pobox.com>
;; Version: 11.14
;; Keywords: wp
;; X-URL: http://www.gnu.org/software/auctex/
;; Copyright 2003 Free Software Foundation

;; Last Change: $Date: 2004-04-15 22:46:26 $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


;;; Notes:

;; This file is loaded by context.el when required.


;; Build upon ConTeXt
(require 'context)


;;; ConText macro names

(defvar ConTeXt-environment-list-nl
  '("achtergrond" "alinea" "bloktekst" "buffer" "citaat" "combinatie"
    "commentaar" "deelomgeving" "document" "doordefinitie"
    "doornummering" "figuur" "formule" "gegeven" "interactiemenu"
    "kadertekst" "kantlijn" "kleur" "kolommen" "legenda" "lokaal"
    "lokalevoetnoten" "margeblok" "naamopmaak" "naast"
    "opelkaar" "opmaak" "opsomming" "overlay" "overzicht"
    "positioneren" "profiel" "regel" "regelcorrectie" "regelnummeren"
    "regels" "smaller" "symboolset" "synchronisatie" "tabel"
    "tabellen" "tabulatie" "tekstlijn" "typen" "uitlijnen"
    "uitstellen" "vanelkaar" "verbergen" "versie"
		;; project structure
		"omgeving" "onderdeel" "produkt" "project"
		;; flowcharts, if you have loaded this module
		"FLOWcell" "FLOWchart"
		;; typesetting computer languages
		"EIFFEL" "JAVA" "JAVASCRIPT" "MP" "PASCAL" "PERL" "SQL" "TEX" "XML"
		;; some metapost environments
		"MPpositiongraphic" "useMPgraphic" "MPcode" "reusableMPgraphic"
		"uniqueMPgraphic")
    "List of the ConTeXt en interface start/stop pairs.")

(defvar ConTeXt-setup-list-nl
  '("achtergronden" "achtergrond" "alineas" "arrangeren" "blanko"
    "blok" "blokjes" "blokkopje" "blokkopjes" "boven" "boventeksten"
    "brieven" "buffer" "buttons" "citeren" "clip" "combinaties"
    "commentaar" "doordefinieren" "doornummeren" "doorspringen"
    "dunnelijnen" "externefiguren" "formules" "formulieren"
    "hoofd" "hoofdteksten" "inmarge" "inspringen" "interactiebalk"
    "interactie" "interactiemenu" "interactiescherm" "interlinie"
    "invullijnen" "invulregels" "items" "kaderteksten" "kantlijn"
    "kapitalen" "kleuren" "kleur" "kolommen" "kop" "kopnummer"
    "koppelteken" "koppen" "koptekst" "korps" "korpsomgeving"
    "labeltekst" "layout" "legenda" "lijndikte" "lijn" "lijst"
    "margeblokken" "markering" "naastplaatsen" "nummeren" "omlijnd"
    "onder" "onderstrepen" "onderteksten" "opmaak" "opsomming"
    "paginanummer" "paginanummering" "paginaovergangen" "palet"
    "papierformaat" "papier" "paragraafnummeren" "plaatsblok"
    "plaatsblokken" "plaatsblokkensplitsen" "positioneren" "profielen"
    "programmas" "publicaties" "rasters" "referentielijst" "refereren"
    "regelnummeren" "regels" "register" "roteren" "samengesteldelijst"
    "sectieblok" "sectie" "sheets" "smaller" "sorteren" "spatiering"
    "stickers" "strut" "strut" "subpaginanummer" "symboolset"
    "synchronisatiebalk" "synchronisatie" "synoniemen" "systeem"
    "taal" "tabellen" "tab" "tabulatie" "tekst" "tekstlijnen"
    "tekstpositie" "tekstteksten" "tekstvariabele" "tolerantie" "type"
    "typen" "uitlijnen" "uitvoer" "url" "velden" "veld" "versies"
    "voet" "voetnootdefinitie" "voetnoten" "voetteksten" "witruimte")
	"List of the names of ConTeXt en interface  macro's that setup things.")

(defun ConTeXt-setup-command-nl (what)
	"The ConTeXt en interface way of creating a setup command."
	(concat "stel" what "in")
	)

(defvar ConTeXt-project-structure-list-nl
	'("project" "omgeving" "produkt" "onderdeel")
	"List of the names of ConTeXt project structure elements for its en interface. List should be in logical order.")

(defvar ConTeXt-section-block-list-nl
	'("inleidingen" "hoofdteksten" "bijlagen" "uitleidingen")
	"List of the names of ConTeXt section blocks for its nl interface. List should be in logical order.")


;; TODO:
;; ConTeXt has alternative sections like title and subject. Currently
;; the level is used to find the section name, so the alternative
;; names are never found. Have to start using the section name instead
;; of the number.
(defvar ConTeXt-section-list-nl
	'(("deel" 0)
		("hoofdstuk" 1)
		("paragraaf" 2)
		("subparagraaf" 3)
		("subsubparagraaf" 4)
;; 		("title" 1)
;; 		("subject" 2)
;; 		("subsubject" 3)
;; 		("subsubsubject" 4)
		)
	"List of the names of ConTeXt sections for its nl interface."
)

(defvar ConTeXt-text-nl "tekst"
	"The ConTeXt nl interface body text group.")

(defvar ConTeXt-item-list-nl
	'("som" "its" "mar" "ran" "sub" "sym")
	"The ConTeXt macro's that are variants of item")

;; Emacs en menu names and labels should go here
;; to be done


;;; Mode

(defun ConTeXt-nl-mode-initialization ()
  "ConTeXt dutch interface specific initialization."
  (mapcar 'ConTeXt-add-environments (reverse ConTeXt-environment-list-nl))

	(TeX-add-symbols
	 '("but" ConTeXt-arg-define-ref (TeX-arg-literal " "))
	 '("som" ConTeXt-arg-define-ref (TeX-arg-literal " "))
	 '("items" (ConTeXt-arg-setup t) (TeX-arg-string "Comma separated list"))
	 '("its" ConTeXt-arg-define-ref (TeX-arg-literal " "))
	 '("nop" (TeX-arg-literal " "))
	 '("ran" TeX-arg-string (TeX-arg-literal " "))
	 '("sub" ConTeXt-arg-define-ref (TeX-arg-literal " "))
	 '("sym" (TeX-arg-string "Symbol") (TeX-arg-literal " "))
	 )
)

;;;###autoload
(defun context-nl-mode ()
	"Major mode for editing files for ConTeXt using its dutch interface.

Special commands:
\\{ConTeXt-mode-map}

Entering context-mode calls the value of text-mode-hook,
then the value of TeX-mode-hook, and then the value
of context-mode-hook."
  (interactive)

  ;; set the ConTeXt interface
	(set (make-local-variable 'ConTeXt-current-interface) "nl")

  ;; initialization
  (ConTeXt-mode-common-initialization)
  (ConTeXt-nl-mode-initialization)

  ;; set mode line
	(setq mode-name "ConTeXt-nl")
)

(provide 'context-nl)

;;; context-nl.el ends here