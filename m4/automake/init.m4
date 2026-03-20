dnl -*- autoconf -*-

AC_DEFUN([AM_INIT_AUTOMAKE], [
    AUTOMAKE_OPTIONS="$1"
    : ${PREFIX:=/usr/local}
    AC_SUBST([AUTOMAKE_OPTIONS])
    AC_SUBST([PREFIX])
])

AC_DEFUN([AM_SILENT_RULES], [
    AM_CONDITIONAL([_AM_SILENT_RULES], [test "$1" = "yes" || test "$1" = 1])
])
