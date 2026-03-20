dnl -*- autoconf -*-

AC_DEFUN([AC_SUBST_INIT], [
    ac_subst_buf=""
    ac_subst_fns=""
])

AC_DEFUN([AC_SUBST_STATUS_INIT], [
    ac_subst_buf='${ac_subst_buf}'
])

AC_DEFUN([AC_SUBST], [
ac_subst_$1 ()
{
    test -n "${ac_subst_buf}" && ac_subst_buf="${ac_subst_buf}${as_nl}"
    val="$2"
    test -z "$val" && val="[$]$1"
    ac_subst_buf="${ac_subst_buf}$1=$val"
}

ac_subst_fns="${ac_subst_fns} ac_subst_$1"

m4_ifdef([_ac_subst_]$1, [1])
m4_define([_ac_subst_list], m4_ifdef([_ac_subst_list], [m4_defn([_ac_subst_list])])[]m4_ifdef([_ac_subst_list], [ ])[]$1)
])

AC_DEFUN([AC_SUBST_COMMIT], [
m4_ifelse($2, [], [], [AC_SUBST([$1], [$2])])
ac_subst_$1
])

AC_DEFUN([AC_SUBST_BUFFER], [
    for fn in $ac_subst_fns; do
        $fn
    done
])

AC_DEFUN([AC_SUBST_STATUS_BUFFER], [
    m4_ifdef([_ac_subst_list], [
        m4_ifelse([_ac_subst_list], [], [], [
            AS_FOREACH([_subst_it], [_ac_subst_list], [
                _subst_it="[$]_subst_it"
            ])
        ])
    ], [])
])

AC_DEFUN([AC_SUBST_FILE], [
echo "$ac_subst_buf" | $AWK -v OUTFILE="$2" '
m4_changequote(`, &)
m4_include(../../awk/subst.awk)
m4_changequote([, ])
' - "$1" > "$2"
])
