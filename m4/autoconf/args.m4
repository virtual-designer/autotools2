dnl -*- autoconf -*-

AC_DEFUN([AS_HELP_STRING], [  $1[]dnl
m4_ifelse(m4_eval(m4_len($1) < 20), 1, [AS_REPEAT(m4_eval(23 - m4_len($1)), [ ])], [
[]AS_REPEAT(25, [ ])])[]dnl
$2[]dnl
])

AC_DEFUN([AC_ARG_INIT], [
m4_divert(DIVERT_ARGS_START)
while test $[#] -gt 0; do
    optname="$[1]"

    case "$optname" in
        --)
            shift
            break
            ;;

        -h|--help)
            usage
            exit 0
            ;;

m4_divert(DIVERT_ARGS_END)
        --enable-*|--with-*)
            as_me_warn "Unknown option: '%s' - ignoring" "$optname"
            shift
            ;;

        -*)
            as_me_error "Unrecognized option: '%s'" "$optname"
            as_me_error "Try '%s --help' for more information." "$as_me_full"
            exit 1
            ;;

        *)
            break
            ;;
    esac
done
m4_divert(DIVERT_HELP_START)
[#] Print usage
usage ()
{
cat <<EOF
$as_me -- prepare and configure $as_pkg_name $as_pkg_version to adapt to
many kinds of systems.

Usage:
  $as_me_full [[OPTION]]... [[--]] [[VAR=VALUE]]...

To set configuration environment variables, you can either set them before
executing this script, or pass VAR=VALUE arguments.

General options:
  -h, --help              Show this help and exit.
  -v, --version           Show version information.
  -q, --quiet, --silent   Do not print any message other than errors and
                          warnings.
m4_divert(DIVERT_HELP_ENABLE_OPTS)
Optional features/capabilities:
m4_divert(DIVERT_HELP_WITH_OPTS)
Optional packages:
m4_divert(DIVERT_HELP_END)
Bug reports and suggestions should be sent to <$as_pkg_bugreport_addr>.
EOF
}

m4_divert(DIVERT_ARGS_END)
for pair in "$[@]"; do
    varname=`echo "$pair" | cut -d= -f1`
    varval=`echo "$pair" | cut -d= -f2-`
dnl TODO: Implement [AC_SUBST]
done
m4_divert(DIVERT_BODY)
])

AC_DEFUN([AC_ARG_ENABLE], [
m4_divert(DIVERT_ARGS)
    --enable-$1|--enable-$1=*)
        enableval=1
        shift

        if test "$optname" != "--enable-$1"; then
            optlen="m4_eval(m4_len([--enable-][$1]) + 2)"
            optval=`echo "$optname" | cut -c ${optlen}-`
            enableval="$optval"
        elif test $[#] -gt 0; then
            case "$[1]" in
                -*)
                    ;;

                *)
                    optval="$[1]"
                    enableval="$optval"
                    shift
                    ;;
            esac
        fi

        $3

        as_opt_enable_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen=1
        ;;
m4_divert(DIVERT_HELP_ENABLE_OPTS)$2[]
m4_divert(DIVERT_ARGS_PROC)
    if test "$as_opt_enable_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen" != 1; then
        $4
        :
    fi
m4_divert(DIVERT_BODY)
])

AC_DEFUN([AC_ARG_WITH], [
m4_divert(DIVERT_ARGS)
    --with-$1|--with-$1=*)
        withval=""
        shift

        if test "$optname" != "--with-$1"; then
            optlen="m4_eval(m4_len([--with-][$1]) + 2)"
            optval=`echo "$optname" | cut -c ${optlen}-`
            withval="$optval"
        elif test $[#] -gt 0; then
            case "$[1]" in
                -*)
                    ;;

                *)
                    optval="$[1]"
                    withval="$optval"
                    shift
                    ;;
            esac
        fi

        $3

        as_opt_with_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen=1
        ;;
m4_divert(DIVERT_HELP_WITH_OPTS)$2[]
m4_divert(DIVERT_ARGS_PROC)
    if test "$as_opt_with_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen" != 1; then
        $4
        :
    fi
m4_divert(DIVERT_BODY)
])
