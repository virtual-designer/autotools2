dnl -*- autoconf -*-

AC_DEFUN([AC_CACHE_INIT], [
    AC_ARG_OPT([cache-file], [], [AS_HELP_STRING([--cache-file=FILE], [Cache configuration test results in FILE])], [1] [ac_cache_file="${optval}"], [ac_cache_file=""])
    AC_ARG_OPT([config-cache], [C], [AS_HELP_STRING([-C, --config-cache], [Alias for '--cache-file=config.cache'])], [-1], [ac_cache_file="config.cache"], [])

ac_cache_cleanup ()
{
    test -z "$ac_cache_file" && return
    test "$ac_cache_loaded" = 1 && return
    if test "$[1]" -ne 0; then
        rm -f "$ac_cache_file"
    else
        as_printf "${as_nl}}${as_nl}" >> "$ac_cache_file"
    fi
}

    as_cleanup_cb_add ac_cache_cleanup

    AS_IF([test -n "$ac_cache_file"], [
        AS_IF([test -f "$ac_cache_file" && test -x "$ac_cache_file"], [
            ac_cache_file_abs=`as_realpath "$ac_cache_file"`
            . "$ac_cache_file_abs"

            if test "$ac_var_configure_path" != "$as_configure_path" || test "$ac_var_configure_args" != "$as_configure_args" || test "$ac_var_top_builddir" != "$top_builddir" || test "$ac_var_top_srcdir" != "$top_srcdir"; then
               ac_gen_cache_file=1
           else
               ac_config_cache_init
               ac_cache_loaded=1
           fi
        ], [ac_gen_cache_file=1])

        AS_IF([test "$ac_gen_cache_file" = 1], [
            as_printf "[]AS_SHEBANG[]\n" > "$ac_cache_file" || exit 1
            as_printf "ac_var_configure_path='%s'\n" "$as_configure_path" >> "$ac_cache_file"
            as_printf "ac_var_configure_args='%s'\n" "$as_configure_args" >> "$ac_cache_file"
            as_printf "ac_var_top_builddir='%s'\n" "$top_builddir" >> "$ac_cache_file"
            as_printf "ac_var_top_srcdir='%s'\n" "$top_srcdir" >> "$ac_cache_file"
            as_printf "${as_nl}ac_config_cache_init ()${as_nl}{${as_nl}" >> "$ac_cache_file"
            chmod a+x "$ac_cache_file" || exit 1
        ])
    ])
])

AC_DEFUN([AC_CACHE_VALUE_SET], [
    AC_CACHE_CURRENT_VAR[]="$1"

    AS_IF([test -n "$ac_cache_file" && test "$ac_cache_loaded" != 1], [
        as_printf '%s='"'"'%s'"'"'\n' "[]AC_CACHE_CURRENT_VAR[]" "$1" >> "$ac_cache_file"
    ])
])

AC_DEFUN([AC_CACHE_CURRENT_IFELSE], [
    AS_IF([test -n "$ac_cache_[]_cache_name[]"], [$1], [$2])
])

AC_DEFUN([AC_CACHE_NAME_ESCAPE], [m4_patsubst(m4_patsubst([$1], [[-$(\)\+\#\%]+], [_]), [\s+], [_])])

AC_DEFUN([AC_CACHE_SET_NAME], [
    m4_define([_cache_name], AC_CACHE_NAME_ESCAPE([$1]))
    ac_check_name="[]_cache_name[]"
])

AC_DEFUN([AC_CACHE_CURRENT_VAR], [ac_cache_[]_cache_name])
AC_DEFUN([AC_CACHE_CURRENT_VALUE], [[$]AC_CACHE_CURRENT_VAR])
