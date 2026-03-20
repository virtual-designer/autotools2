dnl -*- autoconf -*-

AC_DEFUN([AC_PREREQ], [dnl
m4_define([_req_ver], m4_patsubst(AS_STR_TRIM($1), [[\.a-zA-Z_+-]+], []))[]dnl
m4_ifelse(m4_eval(_req_ver[ < 9]), [1], [m4_define([_req_ver], m4_eval(_req_ver[ * 10]))])dnl
m4_ifelse(m4_eval(_req_ver[ < 99]), [1], [m4_define([_req_ver], m4_eval(_req_ver[ * 10]))])dnl
m4_define([_cur_ver_orig], AS_STR_TRIM(m4_esyscmd([autoconf3 --version | head -n1 | cut -d' ' -f4])))[]dnl
m4_define([_cur_ver], AS_STR_TRIM(m4_patsubst(_cur_ver_orig, [[\.a-zA-Z_+-]+], [])))[]dnl
m4_ifelse(m4_eval(_cur_ver[ < ]_req_ver), [1], [dnl
m4_errprint([Autoconf version requirement not satisfied: required $1, have ]_cur_ver_orig[
])[]dnl
m4_exit(1)[]dnl
], [])[]dnl
])