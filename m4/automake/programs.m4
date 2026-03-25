dnl -*- autoconf -*-

AC_DEFUN([AM_PROG_AR], [
    AS_MSG_CHECKING_CACHE_IFELSE([for ar], [
        AC_FIND_PROG([ar], [AR], [ar], [], [Unable to find ar], [1])
        AC_SUBST([AR])
        : ${ARFLAGS:=""}
        AC_SUBST([ARFLAGS])
    ], [])
])

AC_DEFUN([AM_PROG_RANLIB], [
    AS_MSG_CHECKING_CACHE_IFELSE([for ranlib], [
        AC_FIND_PROG([ranlib], [RANLIB], [ranlib], [], [Unable to find ranlib], [1])
        AC_SUBST([RANLIB])
    ], [])
])
