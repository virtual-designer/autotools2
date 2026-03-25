dnl              -*- autoconf -*-

m4_define([_ac_config_macro_dirs], [])

AC_DEFUN([AC_CONFIG_AUX_DIR], [m4_define([_ac_config_build_aux_dir], [$1])[]as_build_aux_dir="$as_srcdir/$1"])
AC_DEFUN([AC_CONFIG_MACRO_DIRS], [
    m4_define([_ac_config_macro_dirs], AS_STR_TRIM(_ac_config_macro_dirs[
m4_patsubst([$1], [\s+], [
])]))
    as_config_macro_dirs="${as_config_macro_dirs}AS_FOREACH([_mdir], [$1], [$as_srcdir/_mdir
])"
])
AC_DEFUN([AC_CONFIG_MACRO_DIR], [AC_CONFIG_MACRO_DIRS([$1])])
