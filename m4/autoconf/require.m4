dnl             -*- mode: autoconf; -*-

AC_DEFUN([AC_REQUIRE], [dnl
m4_ifelse(_ac_macro_used_$1, [1], [], [dnl
m4_define(_ac_macro_used_$1, [1])[]dnl
$1(m4_shift($@))[]dnl
])[]dnl
])
