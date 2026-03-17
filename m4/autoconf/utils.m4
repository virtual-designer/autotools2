dnl -*- autoconf -*-
dnl
m4_define([AC_DEFUN], m4_defn([m4_define]))dnl
dnl
m4_define([_EOF_COUNT_], [-1])dnl
dnl
AC_DEFUN([AS_SHEBANG], [[#]! /bin/sh])dnl
AC_DEFUN([AS_EOF], [dnl
m4_define([_EOF_COUNT_], m4_incr(_EOF_COUNT_))dnl
EOF_[]_EOF_COUNT_[]dnl
])dnl
dnl
AC_DEFUN([AS_EOF_END], [dnl
EOF_[]_EOF_COUNT_[]dnl
m4_define([_EOF_COUNT_], m4_decr(_EOF_COUNT_))dnl
])dnl
dnl
AC_DEFUN([AS_PUSH_VAR], [dnl
m4_define([as_mnv], [[as_var_id_]$1])dnl
m4_ifdef(as_mnv, [], [m4_define(as_mnv, [-1])])dnl
m4_define(as_mnv, m4_incr(m4_indir(as_mnv)))dnl
[#] Push '$1' ([#]m4_indir(as_mnv))
as_var_$1[_]m4_indir(as_mnv)="$$1"
$1=$2
])dnl
dnl
AC_DEFUN([AS_POP_VAR], [dnl
m4_define([as_mnv], [[as_var_id_]$1])dnl
[#] Pop '$1' ([#]m4_indir(as_mnv))
$1="[$]as_var_$1[_]m4_indir(as_mnv)"
m4_define(as_mnv, m4_decr(m4_indir(as_mnv)))dnl
])dnl
dnl
AC_DEFUN([AS_FOREACH_INTERNAL], [dnl
m4_define([_str], AS_SPACE_SIMPLIFY(AS_STR_TRIM($2)))dnl
m4_define([_spcpos], [m4_index(_str, [ ])])dnl
m4_define([_next], [dnl
m4_pushdef([$1], AS_STR_TRIM(m4_substr(_str, 0, _spcpos)))dnl
m4_define([_rest], [m4_substr(_str, _spcpos)])$3
AS_FOREACH_INTERNAL([$1], _rest, [$3])])dnl
m4_ifelse(_spcpos, [-1], [dnl
m4_define([$1], _str)dnl
$3[]m4_popdef([$1])], [_next])])dnl
dnl
AC_DEFUN([AS_FOREACH], [dnl
m4_ifelse([$2], [], [], [dnl
m4_pushdef([_str], [])dnl
m4_pushdef([_spcpos], [])dnl
m4_pushdef([_next], [])dnl
m4_pushdef([_rest], [])dnl
AS_FOREACH_INTERNAL([$1], [$2], [$3])[]dnl
m4_popdef([_str])dnl
m4_popdef([_spcpos])dnl
m4_popdef([_next])dnl
m4_popdef([_rest])dnl
])dnl
])dnl
dnl
AC_DEFUN([AS_STR_TRIM], [dnl
m4_patsubst(m4_patsubst([$1], [\s+$]), [^\s+])])dnl
dnl
AC_DEFUN([AS_SPACE_SIMPLIFY], [dnl
m4_patsubst([$1], [\s+], [ ])])dnl
dnl
AC_DEFUN([AS_IF], [dnl
if $1; then
$2
:
else
$3
:
fi])dnl
dnl
AC_DEFUN([AS_REPEAT], [m4_ifelse($1, 0, [], [AS_REPEAT(m4_decr($1), [$2])])[$2]])dnl
dnl
AC_DEFUN([AS_SHELL_VAR_ESCAPE], [m4_patsubst([$1], [[-$(\)\+\#\%]+], [_])])dnl
dnl
AC_DEFUN([AS_FOR], [
    for $1 in $2; do
        :;
        $3
    done
])dnl
dnl
AC_DEFUN([AS_WHILE], [
    while $1; do
        :;
        $2
    done
])dnl
dnl
AC_DEFUN([AS_BREAK], [break $1;])dnl
AC_DEFUN([AS_CONTINUE], [continue $1;])dnl
