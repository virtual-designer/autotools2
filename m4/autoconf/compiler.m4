dnl  -*- autoconf -*-

dnl *****************
dnl C compiler checks
dnl *****************
AC_DEFUN([AC_PROG_CC_EXISTS], [
    done=0

    AS_FOREACH([_cc_it], [gcc clang cc icc tcc], [
        AS_IF([test -z "$CC" || test $done -eq 0], [
            AS_MSG_CHECKING_CACHE_IFELSE([for ]_cc_it, [
                AC_FIND_PROG([cc], [CC], [_cc_it], [], [], [1])
            ])

            done=1
        ])
    ])

    AS_IF([test -z "$CC"], [
        AC_MSG_ERROR([No C compiler could be found.  Please ensure the system has a C compiler installed.])
    ])

    AC_SUBST([CC])
])

AC_DEFUN([AC_PROG_CC_WORKS], [
    AC_MSG_CHECKING([whether the C compiler works])
    tmp1=`as_mktemp ".c"`
    tmp1=`basename "$tmp1"`
    cat > "$tmp1" <<AS_EOF
#include <stdio.h>

int
main ()
{
    return 0;
}
AS_EOF_END

    pwd=`pwd`
    cd `dirname "$tmp1"` || exit 1
    src=`cat "$tmp1"`
    ac_log_heading "C compiler test"
    ac_log_printf "Temporary source file: %s\n" "$tmp1"
    ac_log_printf "Source file contents:\n\n%s\n\n" "$src"
    ac_log_printf "Compile command: %s\n" "$CC \"$tmp1\""
    contents=`ls 2>/dev/null`
    out=`$CC "$tmp1" 2>&1`
    code=$?
    new_contents=`ls 2>/dev/null`
    ac_log_printf "Compiler output:\n\n%s\n\n" "$out"
    ac_log_printf "Compiler exit code: $code\n"
    rm -f "$tmp1"
    cd "$pwd" || exit 1

    AS_IF([test $code -eq 0], [
        result=""

        for file in $new_contents; do
            is_in=0

            for file2 in $contents; do
                if test "$file" = "$file2"; then
                    is_in=1
                    break
                fi
            done

            test "$is_in" -eq 1 && continue
            result="$file"
            break
        done

        test -n "$result" && test -f "$result" && test -x "$result"
        code=$?
    ])

    AS_IF([test $code -eq 0], [
        out=`./"$result" 2>&1`
        code=$?
        ac_log_printf "Program output:\n\n%s\n\n" "$out"
        ac_log_printf "Program exit code: $code\n\n"
        rm -f "$result"
    ])

    AS_IF([test $code -eq 0], [
        test -z "$out"
        code=$?
    ])

    AS_IF([test $code -eq 0], [AC_MSG_RESULT([yes])], [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([The C compiler cannot produce valid executables.  Please ensure your compiler works.])
    ])
])

AC_DEFUN([AC_PROG_CC_C_O], [
    AC_MSG_CHECKING([whether the C compiler understands both -c and -o together])
    tmp1=`as_mktemp ".c"`
    tmp2=`as_mktemp ".o"`
    cat > "$tmp1" <<AS_EOF
int
main ()
{
    return 0;
}
AS_EOF_END

    ac_log_heading "C compiler option -c and -o test"
    ac_log_printf "Temporary source file: %s\n" "$tmp1"
    ac_log_printf "Temporary object file: %s\n" "$tmp2"
    ac_log_printf "Source file contents:\n\n%s\n\n" "$src"
    ac_log_printf "Compile command: %s\n" "$CC -c \"$tmp1\" -o \"$tmp2\""
    out=`$CC -c "$tmp1" -o "$tmp2" 2>&1 && test -f "$tmp2"`
    code=$?
    rm -f "$tmp1" "$tmp2"
    ac_log_printf "Compiler output:\n\n%s\n\n" "$out"
    ac_log_printf "Compiler exit code: $code\n"

    AS_IF([test $code -eq 0], [
        AC_MSG_RESULT([yes])
    ], [
        AC_MSG_RESULT([no])
        CC="${as_build_aux_dir}/compile $CC"
    ])
])

AC_DEFUN([AC_PROG_CC], [
    AC_PROG_CC_EXISTS
    AC_PROG_CC_WORKS
    AC_PROG_CC_C_O
])


dnl *****************
dnl C++ compiler checks
dnl *****************
AC_DEFUN([AC_PROG_CXX_EXISTS], [
    done=0

    AS_FOREACH([_cxx_it], [g++ clang++ c++], [
        AS_IF([test -z "$CXX" || test $done -eq 0], [
            AS_MSG_CHECKING_CACHE_IFELSE([for ]_cxx_it, [
                AC_FIND_PROG([cxx], [CXX], [_cxx_it], [], [], [1])
            ])

            done=1
        ])
    ])

    AS_IF([test -z "$CXX"], [
        AC_MSG_ERROR([No C++ compiler could be found.  Please ensure the system has a C++ compiler installed.])
    ])
])

AC_DEFUN([AC_PROG_CXX_WORKS], [
    AC_MSG_CHECKING([whether the C++ compiler works])
    tmp1=`as_mktemp ".cc"`
    tmp1=`basename "$tmp1"`
    cat > "$tmp1" <<AS_EOF
int
main ()
{
    return 0;
}
AS_EOF_END

    pwd=`pwd`
    cd `dirname "$tmp1"` || exit 1
    src=`cat "$tmp1"`
    ac_log_heading "C++ compiler test"
    ac_log_printf "Temporary source file: %s\n" "$tmp1"
    ac_log_printf "Source file contents:\n\n%s\n\n" "$src"
    ac_log_printf "Compile command: %s\n" "$CXX \"$tmp1\""
    contents=`ls 2>/dev/null`
    out=`$CXX "$tmp1" 2>&1`
    code=$?
    new_contents=`ls 2>/dev/null`
    ac_log_printf "Compiler output:\n\n%s\n\n" "$out"
    ac_log_printf "Compiler exit code: $code\n"
    rm -f "$tmp1"
    cd "$pwd" || exit 1

    AS_IF([test $code -eq 0], [
        result=""

        for file in $new_contents; do
            is_in=0

            for file2 in $contents; do
                if test "$file" = "$file2"; then
                    is_in=1
                    break
                fi

                case "$file" in
                    *.dSYM)
                        is_in=1
                        break
                        ;;

                    *)
                        ;;
                esac
            done

            test "$is_in" -eq 1 && continue
            result="$file"
            break
        done

        test -n "$result" && test -f "$result" && test -x "$result"
        code=$?
    ])

    AS_IF([test $code -eq 0], [
        out=`./"$result" 2>&1`
        code=$?
        ac_log_printf "Program output:\n\n%s\n\n" "$out"
        ac_log_printf "Program exit code: $code\n\n"
        rm -f "$result"
    ])

    AS_IF([test $code -eq 0], [
        test -z "$out"
        code=$?
    ])

    AS_IF([test $code -eq 0], [AC_MSG_RESULT([yes])], [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([The C++ compiler cannot produce valid executables.  Please ensure your compiler works.])
    ])
])

AC_DEFUN([AC_PROG_CXX_C_O], [
    AC_MSG_CHECKING([whether the C++ compiler understands both -c and -o together])
    tmp1=`as_mktemp ".cc"`
    tmp2=`as_mktemp ".o"`
    cat > "$tmp1" <<AS_EOF
#include <stdio.h>

int
main ()
{
    return 0;
}
AS_EOF_END

    ac_log_heading "C++ compiler option -c and -o test"
    ac_log_printf "Temporary source file: %s\n" "$tmp1"
    ac_log_printf "Temporary object file: %s\n" "$tmp2"
    ac_log_printf "Source file contents:\n\n%s\n\n" "$src"
    ac_log_printf "Compile command: %s\n" "$CXX -c \"$tmp1\" -o \"$tmp2\""
    out=`$CXX -c "$tmp1" -o "$tmp2" 2>&1 && test -f "$tmp2"`
    code=$?
    rm -f "$tmp1" "$tmp2"
    ac_log_printf "Compiler output:\n\n%s\n\n" "$out"
    ac_log_printf "Compiler exit code: $code\n"

    AS_IF([test $code -eq 0], [
        AC_MSG_RESULT([yes])
    ], [
        AC_MSG_RESULT([no])
        CXX="${as_build_aux_dir}/compile $CXX"
    ])
])

AC_DEFUN([AC_PROG_CXX], [
    AC_PROG_CXX_EXISTS
    AC_PROG_CXX_WORKS
    AC_PROG_CXX_C_O
])
