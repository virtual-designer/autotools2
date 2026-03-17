dnl -*- autoconf -*-

AC_DEFUN([AM_CONDITIONAL], [
    AS_IF([$2], [
        AC_SUBST([__COND_]$1, [1])
    ], [
        AC_SUBST([__COND_]$1, [0])
    ])
])
