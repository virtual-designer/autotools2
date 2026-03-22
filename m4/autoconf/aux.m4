dnl            -*- mode: autoconf; -*-

AC_DEFUN([AC_REQUIRE_AUX_FILE], [
    AS_IF([test -f "${as_build_aux_dir}/$1"], [], [
        AC_MSG_ERROR([Missing required auxiliary script: ${as_build_aux_dir}/$1])
    ])

AS_DISCARD_START
    m4_ifdef([_ac_require_]$1, [], [
        m4_define([_ac_require_]$1, [1])
        m4_esyscmd([printf '%s|%d|]m4_ifdef([_ac_config_build_aux_dir], [_ac_config_build_aux_dir]/, [])[%s\n' ']m4___file__[' ']m4___line__[' ']$1[' > ]_AC_AUX_INSTALL_LIST_PIPE)
    ])
AS_DISCARD_END
])
