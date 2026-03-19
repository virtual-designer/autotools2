dnl -*- autoconf -*-

AC_DEFUN([AM_INIT_AUTOMAKE], [
    AUTOMAKE_OPTIONS=""
    : ${PREFIX:=/usr/local}
    AC_SUBST([AUTOMAKE_OPTIONS])
    AC_SUBST([PREFIX])
])
