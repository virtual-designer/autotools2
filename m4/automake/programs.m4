dnl -*- autoconf -*-

AC_DEFUN([AM_PROG_AR], [
    AS_MSG_CHECKING_CACHE_IFELSE([for ar], [
        AC_FIND_PROG([ar], [AR], [ar gar], [], [Unable to find ar], [1])
        AC_SUBST([AR])
        : ${ARFLAGS:=""}
        AC_SUBST([ARFLAGS])
    ], [])
])
