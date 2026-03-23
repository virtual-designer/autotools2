dnl -*- autoconf -*-

AC_DEFUN([AC_CONFIG_FILES], [
    ac_config_files="m4_patsubst([$1], [\s+], [ ])"
])

AC_DEFUN([AC_OUTPUT], [
    AS_IF([test "$top_srcdir" = "$top_builddir"], [
        AC_SUBST([top_srcdir], ["'$(top_builddir)'"])
    ], [
        top_srcdir=`as_realpath "$top_srcdir"`
        AC_SUBST([top_srcdir], [$top_srcdir])
    ])

    AC_SUBST([AUTOCONF], AUTOCONF_PATH)

    AC_SUBST([PACKAGE], [$PACKAGE_NAME])
    AC_SUBST([PACKAGE_NAME])
    AC_SUBST([PACKAGE_FULLNAME])
    AC_SUBST([PACKAGE_VERSION])
    AC_SUBST([PACKAGE_BUGREPORT])
    AC_SUBST([PACKAGE_TARNAME])
    AC_SUBST([PACKAGE_URL])

    AC_SUBST([_AC_CONFIG_VALUE_AUX_DIR], [$as_build_aux_dir])
    AC_SUBST([_AC_CONFIG_VALUE_MACRO_DIR], [$as_config_macro_dir])

    as_macro_files=`ls "$as_config_macro_dir"/*.m4` || {
        AC_MSG_ERROR([Unable to read macro directory: $as_config_macro_dir])
    }

    as_aux_files="AS_FOREACH([_it], [_ac_aux_files], [$as_build_aux_dir/][_it ])"

    AC_SUBST([_AC_CONFIG_VALUE_MACRO_FILES], [$as_macro_files])
    AC_SUBST([_AC_CONFIG_VALUE_AUX_FILES], [$as_aux_files])

    config_status="$as_builddir/config.status"
    as_me_println "creating %s" "$config_status"

    AC_SUBST_BUFFER
    AC_STATUS_INIT(["$config_status"], [$as_pkg_name], [$as_pkg_version], [$as_pkg_bugreport_addr], [$as_pkg_tarname], [$as_pkg_url])

    cat >> "$config_status" <<AS_EOF
ac_config_files="${ac_config_files}"
AC_SUBST_STATUS_INIT
AC_SUBST_STATUS_BUFFER
AS_EOF_END

    cat >> "$config_status" <<'AS_EOF'
ac_config_files_to_emit=""

AS_FOR([conffile], [$ac_config_files], [
    is_in_args=0

    AS_IF([test "$[#]" -eq 0], [
        is_in_args=1
    ], [
        AS_FOR([arg], ["$[@]"], [
            arg_rp=`as_realpath -x "$arg"`
            conffile_rp=`as_realpath -x "$conffile"`

            AS_IF([test "$arg_rp" = "$conffile_rp"], [
                is_in_args=1
                break
            ])
        ])
    ])

    test "$is_in_args" -eq 0 && continue
    test -n "$ac_config_files_to_emit" && ac_config_files_to_emit="${ac_config_files_to_emit} "
    ac_config_files_to_emit="${ac_config_files_to_emit}${conffile}"
])

AS_IF([test -n "$ac_config_files_to_emit"], [
    AS_FOR([conffile], [$ac_config_files_to_emit], [
        conffile_in="${conffile}.in"
        as_me_println "creating %s" "$conffile"
        dirname=`dirname "$conffile"`
        test -d "$dirname" || mkdir -p "$dirname"
        AC_SUBST_FILE([$as_srcdir/$conffile_in], [$conffile])
        AS_IF([test $? -ne 0], [
            AC_MSG_ERROR([Unable to create $conffile from $conffile_in])
        ])
    ])
])
AS_EOF_END

    chmod a+x "$as_builddir/config.status"
    : ${SHELL:=sh}
    $SHELL "$as_builddir/config.status"
])
