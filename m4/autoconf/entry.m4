m4_dnl -*- autoconf -*-
m4_dnl
m4_divert(-1)
m4_define(AS_LBR, [)m4_dnl
m4_define(AS_RBR, ])m4_dnl
m4_changequote([, ])m4_dnl
m4_define([dnl], m4_defn([m4_dnl]))m4_dnl
m4_include([divert.m4])dnl
m4_include([utils.m4])dnl
m4_include([log.m4])dnl
m4_include([print.m4])dnl
m4_include([programs.m4])dnl
m4_include([compiler.m4])dnl
m4_include([args.m4])
m4_include([header.m4])
m4_include([subst.m4])
m4_include([output.m4])
m4_divert(DIVERT_BODY)
