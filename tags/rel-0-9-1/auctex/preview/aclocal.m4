# serial 1

dnl this was once done by Katsumi Yamaoka <yamaoka@jpl.org>, but
dnl pretty much no original code remains.

dnl EMACS_LISP takes 5 arguments.  $1 is the name of the shell
dnl variable to assign a value, $2 is a Lisp expression placed into
dnl shell double quotes (which has consequences for quoting and
dnl variable expansion).  $3 is a list of Emacs options evaluated before
dnl the expression itself, $4 is a list of Elisp variables that is
dnl assigned from the command line arguments from $5.

AC_DEFUN(EMACS_LISP, [
  elisp="$2"
  OUTPUT=./conftest-$$
  echo "${EMACS}" -batch $3 -eval "(let* (patsubst([$4], [\w+], [(\&(pop command-line-args-left))])(x ${elisp})) (write-region (if (stringp x) x (prin1-to-string x)) nil \"${OUTPUT}\"))" $5 >& AC_FD_CC 2>&1
  "${EMACS}" -batch $3 -eval "(let* (patsubst([$4], [\w+], [(\&(pop command-line-args-left))])(x ${elisp})) (write-region (if (stringp x) x (prin1-to-string x)) nil \"${OUTPUT}\"))" $5 >& AC_FD_CC 2>&1
  $1="`cat ${OUTPUT}`"
  echo "=> ${1}" >& AC_FD_CC 2>&1
  rm -f ${OUTPUT}
])

# This generates a prefix variables $1 from the executable in $2.
# The executable is searched in PATH, and a potential bin/ or
# bin/architecture/ component is stripped from it.
AC_DEFUN(EMACS_PATH_PREFIX,[
  EMACS_LISP([$1],[[(condition-case nil (let*
    ((prefix (directory-file-name (file-name-directory (executable-find cmd))))
     (parent (directory-file-name (file-name-directory prefix))))
    (if (string= (file-name-nondirectory prefix) \"bin\")
        (setq prefix parent)
      (if (string= (file-name-nondirectory parent) \"bin\")
         (setq prefix (directory-file-name (file-name-directory parent)))))
    prefix) (error "NONE"))]],[[-no-site-file]],[[cmd]],[$2])])

AC_DEFUN(EMACS_PROG_EMACS, [
# Check for (X)Emacs, report its path, flavor and prefix

# Apparently, if you run a shell window in Emacs, it sets the EMACS
# environment variable to 't'.  Let's undo the damage.
if test "${EMACS}" = "t"; then
   EMACS=""
fi
AC_ARG_WITH(emacs,
  [  --with-emacs@<:@=PATH@:>@     Use Emacs to build (on PATH if given)],
  [if test "${withval}" = "yes"; then EMACS=emacs
   else if test "${withval}" = "no"; then EMACS=xemacs
   else EMACS="${withval}"; fi ; fi])
AC_ARG_WITH(xemacs,
  [  --with-xemacs@<:@=PATH@:>@    Use XEmacs to build (on PATH if given)],
  [if test "${withval}" = "yes"; then EMACS=xemacs;
   else if test "${withval}" = "no"; then EMACS=emacs
   else EMACS="${withval}"; fi ; fi])

# "${prefix}/bin" is for Windows users
AC_PATH_PROGS(EMACS, ${EMACS} emacs xemacs, "", ${PATH} "${prefix}/bin" )
if test -z "${EMACS}"; then
  AC_MSG_ERROR([(X)Emacs not found!  Aborting!])
fi

AC_MSG_CHECKING([if ${EMACS} is XEmacs])
EMACS_LISP(XEMACS,
	[[(if (featurep (quote xemacs)) \"yes\" \"no\")]],[[-no-site-file]])
if test "${XEMACS}" = "yes"; then
  EMACS_FLAVOR=xemacs
  EMACS_NAME="XEmacs"
else
  if test "${XEMACS}" = "no"; then
    EMACS_FLAVOR=emacs
    EMACS_NAME="Emacs"
  else
    AC_MSG_ERROR([Unable to run ${EMACS}!  Aborting!])
  fi
fi
  AC_MSG_RESULT(${XEMACS})
  AC_SUBST(XEMACS)
  AC_SUBST(EMACS_FLAVOR)
  AC_MSG_CHECKING([for ${EMACS_NAME} prefix])
  EMACS_PATH_PREFIX([[emacsprefix]],[["${EMACS}"]])
  AC_MSG_RESULT([["${emacsprefix}"]])
])

AC_DEFUN(EMACS_CHECK_VERSION, [
AC_MSG_CHECKING([if ${EMACS_NAME} is recent enough])
EMACS_LISP(result,[(cond ((< emacs-major-version $1) \"no\")
			 ((> emacs-major-version $1) \"yes\")
			 ((< emacs-minor-version 0$2) \"no\")
			 (t \"yes\"))],[[-no-site-file]])
AC_MSG_RESULT([${result}])
if test "${result}" != "yes"
then
  AC_MSG_ERROR([This package requires at least ${EMACS_NAME} version $1.$2  Aborting!])
fi
])

dnl Look for an installation directory under given prefixes.
dnl $1 is the variable name we are looking for.
dnl $2 is a list of prefixes to try as a list of shell words
dnl $3 is a Lisp expression giving a list of directory names
dnl    those should be be either nil or a relative path like "tex/latex".
dnl   Those names are tried in turn, and every one of them is matched
dnl   against the tail of each location in $4.  nil matches everything,
dnl   it is a wildcard.
dnl $4 is Lisp expression giving a list of locations where to find names.
dnl   A location is only considered if it is nonnil, an existing
dnl   absolute directory,
dnl   and is a subdirectory of one of the given prefixes.
dnl $5,$6,$7 are additional arguments for the elisp call
AC_DEFUN(EMACS_EXAMINE_INSTALLATION_DIR,
 [  for currentprefix in $2
  do
  expprefix="${currentprefix}"
  AC_FULL_EXPAND(expprefix)
  EMACS_LISP([$1],
    [(catch 22
       (let (reldir (dirs $4))
	  (dolist (name $3 \"NONE\")
	    (dolist (dir dirs)
	      (when (and dir
	      	         (setq dir (directory-file-name dir))
                         (file-name-absolute-p dir)
	      	         (file-directory-p dir)
	                 (not (string-match \"\\\\\`\\\\.\\\\.\"
                           (setq reldir (file-relative-name dir expanded))))
                         (let ((name name) (dir dir))
		           (while (and dir name
		                       (string= (file-name-nondirectory dir)
		                                (file-name-nondirectory name))
                              (setq dir (file-name-directory dir)
				   name (file-name-directory name))
			      (if (and dir name)
			         (setq dir (directory-file-name dir)
			              name (directory-file-name name)))))
		            (null name))
		   (throw 22
                      (if (string= reldir \".\") (directory-file-name prefix)
                        (concat (file-name-as-directory prefix)
                                reldir)))))))))],[$5],
  [prefix expanded $6],["${currentprefix}" "${expprefix}" $7])
  if test "[$]$1" != NONE; then break; fi; done])

AC_DEFUN(EMACS_PATH_PACKAGEDIR,
 [AC_ARG_WITH(packagedir,
    [  --with-packagedir=DIR   package DIR for XEmacs],
    [packagedir="`echo ${withval} | sed 's/^~\//${HOME}\//;s/[[\/\\]]$//'`"],
    [if test ${EMACS_FLAVOR} = xemacs; then
      AC_MSG_CHECKING([for XEmacs package directory])
      EMACS_EXAMINE_INSTALLATION_DIR(packagedir,
        [['${datadir}/xemacs/xemacs-packages' \
	  '${libdir}/xemacs/xemacs-packages' \
          '${datadir}' '${libdir}' "${emacsprefix}"]],
        [[(list \"xemacs/site-packages\" \"xemacs/xemacs-packages\"
                \"site-packages\" \"xemacs-packages\")]],
        [[(append late-packages last-packages early-packages)]])
      if test "x${packagedir}" = xNONE -o -z "${packagedir}"; then
        AC_MSG_ERROR([not found, exiting!])
      fi
      AC_MSG_RESULT(${packagedir})
    else
      packagedir=no
    fi])
  AC_SUBST(packagedir)])

AC_DEFUN(EMACS_PATH_LISPDIR, [
  AC_MSG_CHECKING([where lisp files go])
  AC_ARG_WITH(lispdir,
    [  --with-lispdir=DIR      Where to install the $1 file, note
                          that most of the package will be relative to it.],
    [[lispdir="${withval}"]],
    [if test "${EMACS_FLAVOR}" = 'emacs'; then
       # Test paths relative to prefixes
       EMACS_EXAMINE_INSTALLATION_DIR(lispdir,
         [['${datadir}/emacs' '${libdir}/emacs' "${emacsprefix}/share/emacs" \
           '${datadir}' '${libdir}' "${emacsprefix}"]],
	 [[(list \"emacs/site-lisp\" \"emacs/site-packages\"
	         \"site-lisp\" \"site-packages\")]], load-path)
       if test "${lispdir}" = "NONE"; then
	 # No? notify user.
	 AC_MSG_ERROR([Cannot locate lisp directory,
use  --with-lispdir, --datadir, or possibly --prefix to rectify this])
       fi
     else
       # XEmacs
       lispdir="${packagedir}/lisp"
     fi
    ])
  AC_MSG_RESULT([[${lispdir}]])
  AC_SUBST(lispdir)
])


AC_DEFUN(TEX_PATH_TEXMFDIR,
 [
AC_ARG_WITH(texmf-dir,[  --with-texmf-dir=DIR    TEXMF tree to install into],
 [ texmfdir="${withval}" ;
   AC_FULL_EXPAND(withval)
   if test ! -d "${withval}"  ; then
      AC_MSG_ERROR([--with-texmf-dir="${texmfdir}": Directory does not exist])
   fi
   previewtexmfdir='${texmfdir}/tex/latex/preview'
   previewdocdir='${texmfdir}/doc/latex/styles'
   ])

AC_ARG_WITH(tex-dir,
 [  --with-tex-dir=DIR      Location to install preview TeX sources],
 [ previewtexmfdir="${withval}" ;
   AC_FULL_EXPAND(withval)
   if test ! -d "${withval}"  ; then
      AC_MSG_ERROR([--with-tex-dir="${previewtexmfdir}": Directory does not exist])
   fi
   ])

AC_ARG_WITH(doc-dir,
  [  --with-doc-dir=DIR      Location to install preview.dvi],
  [ previewdocdir="${withval}" ;
   AC_FULL_EXPAND(withval)
   if test ! -d "${withval}"  ; then
      AC_MSG_ERROR([--with-doc-dir="${previewdocdir}": Directory does not exist])
   fi
   ])

# First check for docstrip.cfg information -- removed.  Too high
# likelihood to pick up a user preference instead of a system setting.

# Next
# kpsepath -n latex tex
# and then go for the following in its output:
# a) first path component in datadir/prefix ending in tex/latex// (strip trailing
# // and leading !!):  "Searching for TDS-compliant directory."  Install
# in preview subdirectory.
# b) first absolute path component ending in // "Searching for directory
# hierarchy"  Install in preview subdirectory.
# c) anything absolute.  Install both files directly there.

if test -z "${previewtexmfdir}" -o "${previewtexmfdir}" = no  ; then

AC_MSG_CHECKING([for prefix from kpsepath])

EMACS_PATH_PREFIX(texprefix,kpsepath)

if test "x${texprefix}" != "xNONE"
then

AC_MSG_RESULT([["${texprefix}"]])

AC_MSG_CHECKING([for TDS-compliant directory])

pathoutput="`kpsepath -n latex tex`"

EMACS_EXAMINE_INSTALLATION_DIR(texmfdir,
  [['${datadir}/texmf' "${texprefix}/share/texmf-local" "${texprefix}/share/texmf" "${texprefix}/texmf-local" "${texprefix}/texmf"]],
  [[(list nil)]],
  [[(mapcar (lambda(x)
              (and (string-match \"\\\\\`!*\\\\(.*\\\\)/tex/latex//+\\\\'\" x)
	           (match-string 1 x)))
      (append (split-string pathoutput \";\")
             (split-string pathoutput \":\")))]],
    [[-no-site-file]],
    [[pathoutput]],[["${pathoutput}"]])

if test -n "${texmfdir}" -a "${texmfdir}" != "NONE" ; then
   previewdocdir='${texmfdir}/doc/latex/styles'
   previewtexmfdir='${texmfdir}/tex/latex/preview'
fi

if test -z "${previewtexmfdir}" -o "${previewtexmfdir}" = no  ; then

AC_MSG_RESULT([no])
AC_MSG_CHECKING([for TeX directory hierarchy])

EMACS_EXAMINE_INSTALLATION_DIR(texmfdir,
  [['${datadir}/texmf' "${texprefix}/share/texmf-local" "${texprefix}/share/texmf" "${texprefix}/texmf-local" "${texprefix}/texmf" '${datadir}' "${texprefix}/share" "${texprefix}"]],
  [[(list nil)]],
  [[(mapcar (lambda(x)
              (and (string-match \"\\\\\`!*\\\\(.*[^/]\\\\)//+\\\\'\" x)
	           (match-string 1 x)))
      (append (split-string pathoutput \";\")
             (split-string pathoutput \":\")))]],
    [[-no-site-file]],
    [[pathoutput]],[["${pathoutput}"]])

if test -n "${texmfdir}" -a "${texmfdir}" != "NONE" ; then
   previewtexmfdir='${texmfdir}/preview'
   previewdocdir='${texmfdir}/preview'
fi
fi

if test -z "${previewtexmfdir}" -o "${previewtexmfdir}" = no  ; then

AC_MSG_RESULT([no])
AC_MSG_CHECKING([for TeX input directory])

EMACS_EXAMINE_INSTALLATION_DIR(texmfdir,
  [['${datadir}' "${texprefix}/share" "${texprefix}"]],
  [[(list nil)]],
  [[(mapcar (lambda(x)
              (and (string-match \"\\\\\`!*\\\\(.*[^/]\\\\)/?\\\\'\" x)
	           (match-string 1 x)))
      (append (split-string pathoutput \";\")
             (split-string pathoutput \":\")))]],
    [[-no-site-file]],
    [[pathoutput]],[["${pathoutput}"]])

if test -n "${texmfdir}" -a "${texmfdir}" != "NONE" ; then
   previewtexmfdir='${texmfdir}'
   previewdocdir='${texmfdir}'
fi
fi
fi
fi

if test -z "${previewtexmfdir}" -o "${previewtexmfdir}" = no  ; then

AC_MSG_RESULT([no])
	AC_MSG_ERROR([Cannot find the texmf directory!
Please use --with-texmf-dir=dir to specify where the preview tex files go])
fi

AC_MSG_RESULT(${texmfdir})

echo Preview will be placed in ${previewtexmfdir}
echo Preview docs will be placed in ${previewdocdir}
AC_SUBST(texmfdir)
AC_SUBST(previewtexmfdir)
AC_SUBST(previewdocdir)])

AC_DEFUN(AC_FULL_EXPAND,
[ __ac_tmp_oldprefix__="${prefix}"
 if test "x${prefix}" = x -o "x${prefix}" = "xNONE"
 then
   prefix="${ac_default_prefix}"
 fi
 while :;do case "[$]$1" in *\[$]*) __ac_tmp__='s/[[\`"-"]]/\\&/g'
eval "$1=`sed ${__ac_tmp__} <<EOF
[$]$1
EOF
`";; *) break ;; esac; done
  prefix="${__ac_tmp_oldprefix__}" ])



AC_DEFUN(AC_CHECK_PROG_REQUIRED, [
AC_CHECK_PROG($1, $2, NONE)
if test "${$1}"x = NONEx ; then
   AC_MSG_ERROR([$3])
fi
])

AC_DEFUN(AC_CHECK_PROGS_REQUIRED, [
AC_CHECK_PROGS($1, $2, NONE)
if test "${$1}"x = NONEx ; then
   AC_MSG_ERROR([$3])
fi
])


AC_DEFUN(AC_PATH_PROG_REQUIRED, [
AC_PATH_PROG($1, $2, NONE)
if test "${$1}"x = NONEx ; then
   AC_MSG_ERROR([$3])
fi
])

AC_DEFUN(AC_PATH_PROGS_REQUIRED, [
AC_PATH_PROGS($1, $2, NONE)
if test "${$1}"x = NONEx ; then
   AC_MSG_ERROR([$3])
fi
])


dnl
dnl Check whether a function exists in a library
dnl All '_' characters in the first argument are converted to '-'
dnl
AC_DEFUN(EMACS_CHECK_LIB, [
if test -z "$3"; then
	AC_MSG_CHECKING(for $2 in $1)
fi
library=`echo $1 | tr _ -`
EMACS_LISP(EMACS_cv_SYS_$1,(progn (fmakunbound '$2) (condition-case nil (progn (require '${library}) (fboundp '$2)) (error (prog1 nil (message \"${library} not found\"))))))
if test "${EMACS_cv_SYS_$1}" = "nil"; then
	EMACS_cv_SYS_$1=no
fi
if test "${EMACS_cv_SYS_$1}" = "t"; then
	EMACS_cv_SYS_$1=yes
fi
HAVE_$1=${EMACS_cv_SYS_$1}
AC_SUBST(HAVE_$1)
if test -z "$3"; then
	AC_MSG_RESULT(${HAVE_$1})
fi
])

dnl
dnl Check whether a library is require'able
dnl All '_' characters in the first argument are converted to '-'
dnl
AC_DEFUN(EMACS_CHECK_REQUIRE, [
if test -z "$2"; then
	AC_MSG_CHECKING(for $1)
fi
library=`echo $1 | tr _ -`
EMACS_LISP($1,
	[(condition-case nil (require '${library} ) \
	(error (prog1 nil (message \"${library} not found\"))))])
if test "$$1" = "nil"; then
	$1=no
fi
if test "$$1" = "${library}"; then
	$1=yes
fi
HAVE_$1=$$1
AC_SUBST(HAVE_$1)
if test -z "$2"; then
	AC_MSG_RESULT(${HAVE_$1})
fi
])

dnl
dnl Perform sanity checking and try to locate the auctex package
dnl
AC_DEFUN(EMACS_CHECK_AUCTEX, [
AC_MSG_CHECKING(for the location of AUCTeX's tex-site.el)
AC_ARG_WITH(tex-site,[  --with-tex-site=DIR     Location of AUCTeX's tex-site.el, if not standard],
 [ auctexdir="${withval}" ;
   AC_FULL_EXPAND(withval)
   if test ! -d "${withval}"  ; then
      AC_MSG_ERROR([--with-tex-site=${auctexdir}: Directory does not exist])
   fi
])
if test -z "${auctexdir}" ; then
  AC_CACHE_VAL(EMACS_cv_ACCEPTABLE_AUCTEX,[
    EMACS_LISP(EMACS_cv_ACCEPTABLE_AUCTEX,
	[[(condition-case nil
             (directory-file-name (file-name-directory
                (locate-library \"tex-site\")))
	    (error \"\"))]])
    if test -z "${EMACS_cv_ACCEPTABLE_AUCTEX}" ; then
	AC_MSG_ERROR([Can't find AUCTeX!  Please install it!
Check the PROBLEMS file for details.])
  fi
  ])
  auctexdir="${EMACS_cv_ACCEPTABLE_AUCTEX}"
fi
AC_MSG_RESULT(${auctexdir})
AC_SUBST(auctexdir)
])

dnl
dnl Check (X)Emacs supports Mule.
dnl
AC_DEFUN(EMACS_CHECK_MULE, [
AC_MSG_CHECKING(for mule support)
EMACS_CHECK_REQUIRE(mule,silent)
if test "${HAVE_mule}" = "yes"; then
  COMPILE_MULE="tex-jp.el"
  CONTRIB_MULEELC="tex-jp.elc"
  AC_MSG_RESULT(yes)
else
  AC_MSG_RESULT(no)
fi
AC_SUBST(COMPILE_MULE)
AC_SUBST(CONTRIB_MULEELC)
])

dnl
dnl MAKEINFO_CHECK_MACRO( MACRO, [ACTION-IF-FOUND
dnl					[, ACTION-IF-NOT-FOUND]])
dnl
AC_DEFUN(MAKEINFO_CHECK_MACRO,
[if test -n "${MAKEINFO}" -a "${makeinfo}" != ":"; then
  AC_MSG_CHECKING([if ${MAKEINFO} understands @$1{}])
  echo \\\\input texinfo > conftest.texi
  echo @$1{test} >> conftest.texi
  if ${MAKEINFO} conftest.texi > /dev/null 2> /dev/null; then
    AC_MSG_RESULT(yes)
    ifelse([$2], , :, [$2])
  else
    AC_MSG_RESULT(no)
    ifelse([$3], , :, [$3])
  fi
  rm -f conftest.texi conftest.info
fi
])

dnl
dnl MAKEINFO_CHECK_MACROS( MACRO ... [, ACTION-IF-FOUND
dnl					[, ACTION-IF-NOT-FOUND]])
dnl
AC_DEFUN(MAKEINFO_CHECK_MACROS,
[for ac_macro in $1; do
    MAKEINFO_CHECK_MACRO(${ac_macro}, $2,
	[MAKEINFO_MACROS="-D no-${ac_macro} ${MAKEINFO_MACROS}"
	$3])dnl
  done
AC_SUBST(MAKEINFO_MACROS)
])

AC_DEFUN(AC_SHELL_QUOTIFY,
[$1=["`sed 's/[^-0-9a-zA-Z_./:$]/\\\\&/g;s/[$]\\\\[{(]\\([^)}]*\\)\\\\[})]/${\\1}/g' <<EOF]
[$]$1
EOF
`"])

dnl
dnl Check if build directory is valid.
dnl The directory should not be part of `load-path'
dnl
AC_DEFUN(VALID_BUILD_DIR, [
  AC_MSG_CHECKING([if build directory is valid])
  EMACS_LISP(valid_build_dir,
    [[(if (or (member (directory-file-name default-directory) load-path)\
	      (member (file-name-as-directory default-directory) load-path))\
	 \"no\" \"yes\")]])
  if test "${valid_build_dir}" = "no"; then
    AC_MSG_ERROR([Build directory inside load-path!  Aborting!])
  else
    AC_MSG_RESULT([yes])
  fi
])

# AUCTEX_AUTO_DIR
# ---------------
# Set the directory containing AUCTeX automatically generated global style
# hooks.
AC_DEFUN(AUCTEX_AUTO_DIR,
[AC_MSG_CHECKING([where automatically generated global style hooks go])
 AC_ARG_WITH(auto-dir,
	     [  --with-auto-dir=DIR     directory containing AUCTeX automatically generated
			  global style hooks],
	     [autodir="${withval}"
	      autodir_expanded="${autodir}"
	      AC_FULL_EXPAND(autodir_expanded)],
	     [autodir='${localstatedir}/auctex'
	      autodir_expanded="${autodir}"
	      AC_FULL_EXPAND(autodir_expanded)
])
 AC_MSG_RESULT([${autodir}, expanded to ${autodir_expanded}])
 AC_SUBST(autodir)
 AC_SUBST(autodir_expanded)
])

# AC_LISPIFY_DIR
# First argument is a variable name where a lisp expression is to be
# substituted with AC_SUBST and "lisp" prepended.
# If the expression is not an absolute path, it is evaluated relative
# to the current file name.
AC_DEFUN(AC_LISPIFY_DIR,[
 tmpdir="[$]{$1}"
 AC_FULL_EXPAND(tmpdir)
EMACS_LISP([lisp$1],[[(progn (setq path (directory-file-name path))
  (unless (string= (car load-path) (directory-file-name (car load-path)))
    (setq path (file-name-as-directory path)))
  (prin1-to-string
   (if (file-name-absolute-p path)
     (expand-file-name path)
    (backquote (expand-file-name (, path)
       (file-name-directory load-file-name))))))]],-no-site-file,path,["${tmpdir}"])
   AC_SUBST([lisp$1])])

# AC_MAKE_FILENAME_ABSOLUTE
# This makes variable $1 absolute if it is not already so, by prepending
# $2 as a string.  This won't work in Windows with drive-relative path names.
# Just don't use them.
AC_DEFUN(AC_MAKE_FILENAME_ABSOLUTE,[
     tmpdir="[$]{$1}"
     AC_FULL_EXPAND(tmpdir)
     case "${tmpdir}" in
       [[\\/]]* | ?:[[\\/]]* ) # Absolute
          ;;
       *)
          $1=$2"[$]{$1}";;
     esac
     AC_SUBST([$1])])

AC_DEFUN(EMACS_LISP_RELATIVE,[
  AC_ARG_WITH($1,[[  --with-$1=DIR    Where to find $2,
        relative to the Lisp startup file.]],
    [$1=["${withval}"]])
  AC_LISPIFY_DIR([$1])])
