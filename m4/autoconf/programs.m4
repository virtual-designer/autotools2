dnl -*- autoconf -*-

AC_DEFUN([AC_FIND_PROG], [
    as_prog_name=""
    as_prog_path=""

    AS_FOREACH([as_prog_it], [$3], [
        if test -z "$as_prog_name"; then
            AS_PUSH_VAR([IFS], [":"])

            for as_path in $PATH; do
                as_prog="[]as_prog_it[]"
                as_exec="$as_path/$as_prog"

                m4_ifelse([$4], [], [test -f "$as_exec" && test -x "$as_exec"], [$4])

                if test $? -eq 0; then
                    as_prog_path="$as_exec"
                    as_prog_name="$as_prog"
                    break
                fi
            done

            AS_POP_VAR([IFS])
        fi
    ])

    if test -z "$as_prog_name"; then
        AC_MSG_RESULT([none])

        m4_ifelse([$5], [], [:], [
            AC_MSG_ERROR([$5])
        ])
    else
        AC_MSG_RESULT([$as_prog_name])
    fi

    $2="$as_prog_path"
])

AC_DEFUN([AC_RUN_PROG], [
    ac_log_heading "Running program: $1 $2"
    ac_log_printf "Command: $1 $2\n"
    ac_log_printf "Output:\n\n"
    ac_log_printf "--- BEGIN OUTPUT ---\n"
    $1 $2 >> AC_CORE_LOG_FILE 2>&1
    as_rcode=$?
    ac_log_printf "\n--- END   OUTPUT ---\n\n"
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
        AC_FIND_PROG([install], [INSTALL], ["" -c], [
            as_exec="$as_path/install []as_prog_it[]"
            as_prog="$as_exec"

            if test -f "$as_path/install" && test -x "$as_path/install"; then
                as_tmp1=`as_mktemp`
                as_tmp2=`as_mktemp`
                echo 42 > "$as_tmp1"
                AC_RUN_PROG([$as_path/install], [as_prog_it $as_tmp1 $as_tmp2], [as_rcode=0], [as_rcode=1])
                contents=`cat "$as_tmp2" 2>/dev/null`
                if test "$as_rcode" = 0 && test "$contents" = 42; then
                    as_rcode=0
                else
                    as_rcode=1
                fi
                rm -f "$as_tmp1" "$as_tmp2"
            else
                as_rcode=1
            fi

            test "$as_rcode" -eq 0
        ], [Unable to find a BSD-compatible install program])
    ], [])
])

AC_DEFUN([AC_PROG_MAKE], [
    AS_MSG_CHECKING_CACHE_IFELSE([for make], [
        AC_FIND_PROG([make], [MAKE], [make gmake bmake], [], [Unable to find make])
    ], [])
])

AC_DEFUN([AC_PROG_MAKE_SET], [
    AS_MSG_CHECKING_CACHE_IFELSE([whether make sets \$(MAKE)], [
        tmp="$(as_mktemp)"
        as_printf "all:\n\t@echo \$(MAKE)\n" > "$tmp"
        out=`$MAKE -f "$tmp" 2>&1`
        if test $? = 0 && test -n "$out"; then
            AC_MSG_RESULT([yes])
        else
            AC_MSG_RESULT([no])
        fi
    ], [])
])

AC_DEFUN([AC_PROG_AWK], [
    AS_MSG_CHECKING_CACHE_IFELSE([for awk], [
        AC_FIND_PROG([awk], [AWK], [gawk awk mawk], [], [Unable to find awk])
    ], [])
])

AC_DEFUN([AC_PROG_GREP], [
    AS_MSG_CHECKING_CACHE_IFELSE([for grep], [
        AC_FIND_PROG([grep], [GREP], [grep], [], [Unable to find grep])
    ], [])
])

dnl TODO: Compiler checks
