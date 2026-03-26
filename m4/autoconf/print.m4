dnl -*- autoconf -*-

AC_DEFUN([AC_CORE_PRINT_INIT], [
as_printf ()
{
    fmt="$[1]"
    shift
    printf -- "$fmt" "$[@]"
}

as_me_println ()
{
    fmt="$[1]"
    shift
    printf -- "$as_me: $fmt\n" "$[@]"
}

as_me_warn ()
{
    fmt="$[1]"
    shift
    printf -- "$as_me: warning: $fmt\n" "$[@]" >&2
}

as_me_error ()
{
    fmt="$[1]"
    shift
    printf -- "$as_me: error: $fmt\n" "$[@]" >&2
}
])

AC_DEFUN([AC_MSG_CHECKING], [
AC_CACHE_SET_NAME([$1])
as_printf "checking %s... " "$1"
])

AC_DEFUN([AC_MSG_RESULT], [
    AC_CACHE_CURRENT_IFELSE([
        as_printf "%s (cached)\n" "[$]AC_CACHE_CURRENT_VAR[]"
    ], [
        as_printf "%s\n" "$1"
        AC_CACHE_VALUE_SET([$1])
    ])
])

AC_DEFUN([AS_MSG_CHECKING_CACHE], [
AC_MSG_CHECKING([$1])
AC_CACHE_SET_NAME([$1])
])

AC_DEFUN([AC_MSG_CHECKING_CACHE_IFELSE], m4_defn([AS_MSG_CHECKING_CACHE_IFELSE]))
AC_DEFUN([AS_MSG_CHECKING_CACHE_IFELSE], [
    AC_MSG_CHECKING([$1])
    AC_CACHE_SET_NAME([$1])
    AC_CACHE_CURRENT_IFELSE([
        :
        m4_ifelse([$3], [], [AC_MSG_RESULT([])], [$3])
    ], [
        :
        $2
    ])
])

AC_DEFUN([AC_MSG_ERROR], [
if command -v ac_log_heading; then
    ac_log_heading "Error occurred"
    ac_log_printf "error: %s" "$1"
    ac_log_printf "\n"
fi

as_me_println "error: %s" "$1" >&2
exit 1
])

AC_DEFUN([AC_MSG_WARN], [
if command -v ac_log_heading; then
    ac_log_heading "Warning emitted"
    ac_log_printf "warning: %s" "$1"
    ac_log_printf "\n"
fi

as_me_println "%s" "$1" >&2
])

AC_DEFUN([AC_MSG_INFO], [
as_me_println "%s" "$1"
])

AC_DEFUN([AC_MSG_NOTICE], [
as_me_println "%s" "$1"
])
