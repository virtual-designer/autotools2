dnl -*- autoconf -*-
dnl
AC_DEFUN([AC_CORE_LOG_FILE], ["$as_logfile"])

AC_DEFUN([AC_CORE_LOG_INIT], [
as_logfile="$as_builddir/config.log"

as_printf "" > "$as_logfile"

ac_log_printf ()
{
    fmt="$[1]"
    shift
    as_printf "$fmt" "$[@]" >> "$as_logfile"
}

ac_log_boundary ()
{
    ac_log_printf "==========================================================\n"
}

ac_log_heading ()
{
    ac_log_boundary
    ac_log_printf "$[1]\n"
    ac_log_boundary
    ac_log_printf "\n"
}

ac_log_init ()
{
    ac_log_heading "Configuration started -- $as_pkg_name $as_pkg_version"
    ac_log_printf "Start time:   %s\n" "$as_date_start"
    ac_log_printf "abs_builddir: %s\n" "$as_abs_builddir"
    ac_log_printf "abs_builddir: %s\n" "$as_abs_builddir"
    ac_log_printf "\n\n"
}

ac_log_cleanup ()
{
    ac_log_heading "Configuration finished -- $as_pkg_name $as_pkg_version"
    ac_log_printf "Exit time: %s\n" "$(as_now)"
    ac_log_printf "Exit code: %d\n" "$as_code"
    ac_log_printf "\n\n"
}

as_cleanup_cb_add ac_log_cleanup
ac_log_init
])
