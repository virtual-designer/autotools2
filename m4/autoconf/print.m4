dnl -*- autoconf -*-

AC_DEFUN([AC_CORE_PRINT_INIT], [
])

AC_DEFUN([AC_MSG_CHECKING], [
as_printf "checking %s... " "$1"
])

AC_DEFUN([AC_MSG_RESULT], [
if test -z "$as_cache_[]_cache_name"; then
    as_printf "%s\n" "$1"
    as_cache_[]_cache_name="$1"
else
    as_printf "%s (cached)\n" "$as_cache_[]_cache_name"
fi
])

AC_DEFUN([AS_MSG_CHECKING_CACHE], [
AC_MSG_CHECKING([$1])
m4_define([_cache_name], m4_patsubst(m4_patsubst([$1], [[-$(\)]+], [_]), [\s+], [_]))
as_check_name="[]_cache_name[]"
])

AC_DEFUN([AS_MSG_CHECKING_CACHE_IFELSE], [
AC_MSG_CHECKING([$1])
m4_define([_cache_name], m4_patsubst(m4_patsubst([$1], [[-$(\)]+], [_]), [\s+], [_]))
as_check_name="[]_cache_name[]"
if test -z "$as_cache_[]_cache_name"; then
    :
    $2
else
    :
    m4_ifelse([$3], [], [AC_MSG_RESULT([])], [$3])
fi
])

AC_DEFUN([AC_MSG_ERROR], [
as_me_println "error: %s" "$1" >&2
exit 1
])

AC_DEFUN([AC_MSG_WARN], [
as_me_println "%s" "$1" >&2
])

AC_DEFUN([AC_MSG_INFO], [
as_me_println "%s" "$1"
])
