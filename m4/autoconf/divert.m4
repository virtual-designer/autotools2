dnl -*- autoconf -*-

m4_define([_iota_val], [0])
m4_define([_iota], [m4_define([_iota_val], m4_incr(_iota_val))[]_iota_val])

m4_define([DIVERT_HEADER], _iota)
m4_define([DIVERT_INIT], _iota)
m4_define([DIVERT_HELP_START], _iota)
m4_define([DIVERT_HELP_ENABLE_OPTS], _iota)
m4_define([DIVERT_HELP_WITH_OPTS], _iota)
m4_define([DIVERT_HELP_END], _iota)
m4_define([DIVERT_ARGS_START], _iota)
m4_define([DIVERT_ARGS], _iota)
m4_define([DIVERT_ARGS_END], _iota)
m4_define([DIVERT_ARGS_PROC], _iota)
m4_define([DIVERT_BODY], _iota)
m4_define([DIVERT_FOOTER], _iota)
