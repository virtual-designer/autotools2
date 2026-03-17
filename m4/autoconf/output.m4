dnl -*- autoconf -*-

AC_DEFUN([AC_CONFIG_FILES], [
    ac_config_files="$1"
])

AC_DEFUN([AC_OUTPUT], [
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
AS_FOR([conffile], [$ac_config_files], [
    conffile_in="${conffile}.in"
    as_me_println "creating %s" "$conffile"
    AC_SUBST_FILE([$conffile_in], [$conffile])
    AS_IF([test $? -ne 0], [
        AC_MSG_ERROR([Unable to create $conffile from $conffile_in])
    ])
])
AS_EOF_END

    chmod a+x "$as_builddir/config.status"
    : ${SHELL:=sh}
    $SHELL "$as_builddir/config.status"
])
