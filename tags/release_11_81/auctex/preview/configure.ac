AC_INIT(preview-latex,0.9.1,bug-auctex@gnu.org)

AC_SET_MAKE
AC_PROG_INSTALL

# Import unquoted variables.
packagedir="$packagedir_unquoted"
packagedatadir="$packagelispdir_unquoted"
packagedatadir="$packagedatadir_unquoted"
EMACS="$EMACS_UNQUOTED"

EMACS_PROG_EMACS

if test ${EMACS_FLAVOR} = xemacs
then
  EMACS_CHECK_VERSION(21,4)
else
  EMACS_CHECK_VERSION(21,1)
fi

# The Debian package uses `--disable-build-dir-test'; normal users should
# never need to modify the default behavior.
AC_ARG_ENABLE([build-dir-test],
  [  --enable-build-dir-test test for build directory inside `load-path'
			  (on by default)],
  [if ! [[ "X-${enableval}" = "X-no" ]]
     then VALID_BUILD_DIR
   fi],
  [VALID_BUILD_DIR])

if test ${EMACS_FLAVOR} = "xemacs"  ; then
   PLAT_LISP=prv-xemacs.el
   EMACS_PATH_PACKAGEDIR([preview],[preview])
else
   PLAT_LISP=prv-emacs.el
   packagedir=no
fi

if test "X${packagedir}" = Xno
then
   EMACS_PATH_LISPDIR
   AC_MSG_CHECKING(what file to use for preview startup)
   AC_ARG_WITH(previewstartfile,
   [[  --with-preview-startfile=FILE    What file to use for preview startup.]],
   [[ previewstartfile="${withval}" ]],
   [ _tmpdir_="${lispdir}"
     AC_FULL_EXPAND(_tmpdir_)
     if test -d "${_tmpdir_}/site-start.d"
     then
       previewstartfile="${lispdir}/site-start.d/preview-latex.el"
     else
       previewstartfile="${lispdir}/preview-latex.el"
     fi])
   AC_MSG_RESULT([[${previewstartfile}]])
   test "X$packagelispdir" = X && packagelispdir="${lispdir}/preview"
   test "X$packagedatadir" = X && packagedatadir="${packagelispdir}"
else
   #lispdir is only used for determining relative files.
   lispdir="${packagedir}"
   test "X$packagelispdir" = X && packagelispdir="${packagedir}/lisp/preview"
   previewstartfile="${packagelispdir}"/auto-autoloads.el
   test "X$packagedatadir" = X && packagedatadir="${packagedir}/etc/preview"
   infodir="${packagedir}/info"
   INSTALL_INFO=:
fi

AC_SUBST(previewstartfile)

AC_MSG_CHECKING([where the package lisp files go])
AC_ARG_WITH(packagelispdir,
[[  --with-packagelispdir=DIR
                        Directory for the package lisp files.]],
  [packagelispdir=["${withval}"]])
AC_LISPIFY_DIR(packagelispdir,"${previewstartfile}")
AC_MSG_RESULT([[${packagelispdir}]])

AC_MSG_CHECKING([where the data files go])
AC_ARG_WITH(packagedatadir,
[[  --with-packagedatadir=DIR         Where the data files go.]],
  [packagedatadir=["${withval}"]])
AC_LISPIFY_DIR(packagedatadir,"${previewstartfile}")
AC_MSG_RESULT([[${packagedatadir}]])

AC_MSG_CHECKING(where the info files go)
AC_MSG_RESULT([[${infodir}]])

AC_SUBST(PLAT_LISP)
AC_SUBST(packagedir)

EMACS_CHECK_AUCTEX
AC_SUBST(auctexdir)

AC_ARG_VAR(GS,[Ghostscript executable for batch operation])
AC_CHECK_PROGS_REQUIRED(GS, gs GSWIN32C.EXE, 
[Ghostscript not found!  Aborting!  
You need Ghostscript in your PATH for preview to work.])

EMACS_LISP([[lispGS]],[[(if (string= dir \"gs\") \"\" \`(defvar preview-gs-command ,dir))]],-no-site-file,[[dir]],[["${GS}"]])
AC_SUBST(lispGS)

dnl check to see if GS supports -dTextAlphaBits and -dGraphicsAlphaBits
dnl Check to see if specific drivers are built in.
dnl Need table of mappings, with priority

AC_PATH_PROG_REQUIRED(LATEX, latex, [LaTeX not found, aborting!
You must install LaTeX for preview to work.])

AC_PATH_PROG(PDFLATEX, pdflatex)

# Determine which latex-style components to install
# To match .sty, .def, .cfg, but _not_ .drv
TEXMFGEN=[`sed -n 's/^%<installer>.*file[{]\\([^}.]*\\.[sdc][tef][yfg]\\)[}].*/\\1/p' latex/preview.dtx`]
# Replace newlines with spaces.
TEXMFGEN="`echo ${TEXMFGEN}`"
AC_SUBST(TEXMFGEN)

AC_PATH_PROG_REQUIRED(TEX, tex, NONE)

TEX_PATH_TEXMFDIR

if test "x${texmfdir}" = "xno"
then
  AC_MSG_CHECKING([kpathsea directory separator])
  AC_ARG_WITH(kpathseaseparator,
  [  --with-kpathsea-sep=@<:@:|;@:>@
                      directory separator for kpathsea],
  [[kpathseaseparator="${withval}"]],
  [test "x${pathoutput}" != x || pathoutput="`kpsepath -n latex tex`"
    case "${pathoutput}" in *\;*) kpathseaseparator=";" ;;
      *:*) kpathseaseparator=":" ;;
      *) AC_MSG_ERROR([Can't determine kpathsea directory separator!
Please use --with-kpathsea-sep=@<:@:|;@>:@ to specify it!])
    esac])
  AC_MSG_RESULT([["${kpathseaseparator}"]])
  packagetexstyles="${packagedatadir}/latex"
  AC_LISPIFY_DIR(packagetexstyles,"${previewstartfile}")
  lisppackagetexstyles="(defvar preview-TeX-style-dir (concat \".${kpathseaseparator}\" ${lisppackagetexstyles} \"${kpathseaseparator}\"))"
  test "X${TEXHASH}" = X && TEXHASH=:
else
  lisppackagetexstyles=
fi
AC_SUBST(lisppackagetexstyles)

# Be very careful about assuming things about the available hash programs
# MikTeX comes with a braindead link to mktexlsr, apparently, so first
# try the regular utility from them.
AC_ARG_VAR(TEXHASH,[command to update the TeX filename database.
Set to : to skip updating the database on installation.
This is the default for --without-texmf-dir])

AC_PATH_PROG(TEXHASH, texhash)
AC_CHECK_PROG(TEXHASH, initexmf, initexmf -u)
if test "X${TEXHASH}" = X
then
   AC_PATH_PROGS(TEXHASH, mktexlsr MakeTeXls-R, :)
fi

AC_MSG_CHECKING([[for glaring installation conflicts]])
exppackagelispdir="$packagelispdir"
AC_FULL_EXPAND(exppackagelispdir)
exppreviewstartfile="$previewstartfile"
AC_FULL_EXPAND(exppreviewstartfile)

EMACS_LISP(shadows,[[
  (concat
    (and (setq tmp (locate-library \"preview.elc\"))
         (not (string= (file-truename tmp)
	               (file-truename (expand-file-name \"preview.elc\"
                                      packagelispdir))))
         (format \"Conflicting previous installation in \`%s' found!\n\"
                 (file-name-directory tmp)))
    (and (setq tmp (locate-library \"preview-latex.el\"))
         (not (string= (file-truename tmp)
                       (file-truename previewstartfile)))
         (format \"Conflicting previous startup file \`%s' found!\n\" tmp)))]],,
  [[packagelispdir previewstartfile]],[["${exppackagelispdir}" "${exppreviewstartfile}"]])
if test "NONE${shadows}" != NONE
then
  conflictsmsg="Conflicts with previous installations have been detected.
Please fix them before continuing.
"
  AC_MSG_RESULT([[ouch!
]])
AC_MSG_WARN([[${shadows}
]])
else
  conflictsmsg=
  AC_MSG_RESULT([[probably none]])
fi


AC_SHELL_QUOTIFY(texmfdir)
AC_SHELL_QUOTIFY(prefix)
AC_SHELL_QUOTIFY(exec_prefix)
AC_SHELL_QUOTIFY(libdir)
AC_SHELL_QUOTIFY(previewtexmfdir)
AC_SHELL_QUOTIFY(previewdocdir)
AC_SHELL_QUOTIFY(packagedir)
AC_SHELL_QUOTIFY(packagelispdir)
AC_SHELL_QUOTIFY(previewstartfile)
AC_SHELL_QUOTIFY(lispdir)
AC_SHELL_QUOTIFY(packagedatadir)
AC_SHELL_QUOTIFY(infodir)
AC_SHELL_QUOTIFY(auctexdir)
AC_SHELL_QUOTIFY(datadir)
AC_SHELL_QUOTIFY(GS)
AC_SHELL_QUOTIFY(TEXHASH)
AC_SHELL_QUOTIFY(EMACS)
AC_SHELL_QUOTIFY(TEX)
AC_SHELL_QUOTIFY(LATEX)
AC_SHELL_QUOTIFY(PDFLATEX)

AC_OUTPUT(Makefile auto.el latex/Makefile)
cat >&2 <<EOF

Congratulations!  Configuration of preview is complete.
${conflictsmsg}
EOF
