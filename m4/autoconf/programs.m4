dnl -*- autoconf -*-

AC_DEFUN([_AC_FIND_PROG_TRY], [
    AS_PUSH_VAR([IFS], [":"])

    for as_path in $PATH; do
        as_prog="$1"
        test "${as_prog#/}" = "${as_prog}" && as_exec="$as_path/$as_prog" && as_cmd="$as_prog"
        test "${as_prog#/}" != "${as_prog}" && as_exec="$as_prog" && as_cmd="$as_prog"

        m4_ifelse([$2], [], [test -f "$as_exec" && test -x "$as_exec"], [$2])

        if test $? -eq 0; then
            as_prog_path="$as_exec"
            as_prog_name="$as_prog"
            as_prog_cmd="$as_cmd"
            break
        fi
    done

    AS_POP_VAR([IFS])
])

AC_DEFUN([AC_FIND_PROG], [
    AC_FIND_PROG_IFELSE([$1], [$2], [$3], [$4], [
        m4_ifelse([$6], [1], [AC_MSG_RESULT([$as_prog_cmd])], [])
    ], [
        m4_ifelse([$6], [1], [AC_MSG_RESULT([none])], [])
        m4_ifelse([$5], [], [:], [
            AC_MSG_ERROR([$5])
        ])
    ])
])

AC_DEFUN([AC_FIND_PROG_IFELSE], [
    as_prog_name=""
    as_prog_path=""
    as_prog_cmd=""

    AS_IF([test -n "$$2"], [
        _AC_FIND_PROG_TRY([$$2], [$4])
    ])

    AS_IF([test -z "$as_prog_name"], [
        AS_FOREACH([as_prog_it], [$3], [
            if test -z "$as_prog_name"; then
                _AC_FIND_PROG_TRY(as_prog_it, [$4])
            fi
        ])
    ])

    AS_IF([test -n "$as_prog_name"], [
        $2="$as_prog_cmd"
        $5
    ], [
        $6
        :
    ])
])

AC_DEFUN([AC_RUN_PROG], [
    ac_log_heading "Running program: $1 $2"
    ac_log_printf "Command: $1 $2\n"
    ac_log_printf "Output:\n\n"
    $1 $2 >> AC_CORE_LOG_FILE 2>&1
    as_rcode=$?
    ac_log_printf "\n"
    ac_log_printf "Exit code: %d\n" "$as_rcode"

    if test "$as_rcode" = 0; then
        :
        $3
    else
        :
        $4
    fi
])

AC_DEFUN([AC_PROG_INSTALL], [
    AS_MSG_CHECKING_CACHE_IFELSE([for a BSD-compatible install], [
        AC_FIND_PROG_IFELSE([install], [INSTALL], [install], [
            as_rcode=1

            AS_FOREACH([_install_opts], ["" "-c"], [
                AS_IF([test $as_rcode -ne 0], [
                    as_exec="$as_path/[]as_prog_it[]"
                    as_prog="$as_exec"
                    as_cmd="$as_exec"

                    if test -f "$as_path/install" && test -x "$as_path/install"; then
                        as_tmp1=`as_mktemp`
                        as_tmp2=`as_mktemp`
                        echo 42 > "$as_tmp1"
                        AC_RUN_PROG([$as_exec], [_install_opts $as_tmp1 $as_tmp2], [as_rcode=0], [as_rcode=1])
                        contents=`cat "$as_tmp2" 2>/dev/null`

                        if test "$as_rcode" = 0 && test "$contents" = 42; then
                            as_rcode=0
                            INSTALL_OPTS=_install_opts
                        else
                            as_rcode=1
                        fi

                        rm -f "$as_tmp1" "$as_tmp2"
                    else
                        as_rcode=1
                    fi
                ])
            ])

            test "$as_rcode" = 0
        ], [
            AC_MSG_RESULT([$INSTALL $INSTALL_OPTS])
            AC_SUBST([INSTALL], [$INSTALL $INSTALL_OPTS])
        ], [
            AC_MSG_RESULT([none])
            AC_MSG_ERROR([Unable to find a BSD-compatible install program])
        ])
    ], [])
])

AC_DEFUN([AC_PROG_MAKE], [
    AS_MSG_CHECKING_CACHE_IFELSE([for make], [
        AC_FIND_PROG([make], [MAKE], [make gmake bmake], [], [Unable to find make], [1])
        AC_SUBST([MAKE])
    ], [])
])

AC_DEFUN([AC_PROG_MAKE_SET], [
    AS_MSG_CHECKING_CACHE_IFELSE([whether make sets \$(MAKE)], [
        tmp="$(as_mktemp)"
        as_printf "all:\n\t@echo \$(MAKE)\n" > "$tmp"
        out=`$MAKE -f "$tmp" 2>&1`
        AS_IF([test $? = 0 && test -n "$out"], [
            AC_MSG_RESULT([yes])
        ], [
            AC_MSG_RESULT([no])
            AC_MSG_ERROR([make does not set \$(MAKE)])
        ])
    ], [])
])

AC_DEFUN([AC_PROG_AWK], [
    AS_MSG_CHECKING_CACHE_IFELSE([for awk], [
        AC_FIND_PROG([awk], [AWK], [gawk awk mawk], [], [Unable to find awk], [1])
        AC_SUBST([AWK])
    ], [])
])

AC_DEFUN([AC_PROG_GREP], [
    AS_MSG_CHECKING_CACHE_IFELSE([for grep], [
        AC_FIND_PROG([grep], [GREP], [grep], [], [Unable to find grep], [1])
        AC_SUBST([GREP])
    ], [])
])

AC_DEFUN([AC_ENSURE_POSIX], [
    AS_MSG_CHECKING_CACHE_IFELSE([whether all required POSIX utilities are available], [
        err=""
        AC_FIND_PROG_IFELSE([tr],  [POSIX_TR],  [tr],  [], [], [err="Unable to find 'tr'"])
        AC_FIND_PROG_IFELSE([od],  [POSIX_OD],  [od],  [], [], [err="Unable to find 'od'"])
        AC_FIND_PROG_IFELSE([cut], [POSIX_CUT], [cut], [], [], [err="Unable to find 'cut'"])
        AS_IF([test -n "$err"], [
            AC_MSG_RESULT([no])
            AC_MSG_ERROR([$err])
        ], [
            AC_MSG_RESULT([yes])
        ])
    ], [])
])
