dnl -*- autoconf -*-

AC_DEFUN([AM_PROG_AR], [
    AS_MSG_CHECKING_CACHE_IFELSE([for ar], [
        AC_FIND_PROG([ar], [AR], [ar], [], [Unable to find ar], [1])
        AC_SUBST([AR])
        : ${ARFLAGS:=""}
        AC_SUBST([ARFLAGS])
        AC_ARG_VAR([AR], [AS_HELP_STRING([AR], [The archiver program.])])
        AC_ARG_VAR([ARFLAGS], [AS_HELP_STRING([ARFLAGS], [Flags for the archiver program.])])
    ], [])
])

AC_DEFUN([AM_PROG_RANLIB], [
    AS_MSG_CHECKING_CACHE_IFELSE([for ranlib], [
        AC_FIND_PROG([ranlib], [RANLIB], [ranlib], [], [Unable to find ranlib], [1])
        AC_SUBST([RANLIB])
        AC_ARG_VAR([RANLIB], [AS_HELP_STRING([RANLIB], [The ranlib program.])])
    ], [])
])
