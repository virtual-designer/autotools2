dnl -*- autoconf -*-

AC_DEFUN([AS_HELP_STRING], [  $1[]dnl
m4_ifelse(m4_eval(m4_len($1) < 20), 1, [AS_REPEAT(m4_eval(23 - m4_len($1)), [ ])], [
[]AS_REPEAT(25, [ ])])[]dnl
m4_patsubst($2, [
], [
]AS_REPEAT(25, [ ]))[]dnl
])

AC_DEFUN([AC_ARG_INIT], [
AS_DIVERT(DIVERT_ARGS_START)
as_flag_no_create=0
as_o=

while test $[#] -gt 0; do
    arg="$[1]"
    optname="$arg"

    case "$arg" in
        ${as_o}--)
            shift
            as_o=`as_rand`
            continue
            ;;

        ${as_o}-h|${as_o}--help)
            usage
            exit 0
            ;;

        ${as_o}-V|${as_o}--version)
            show_version
            exit 0
            ;;

        ${as_o}-n|${as_o}--no-create)
            as_flag_no_create=1
            shift
            continue
            ;;

AS_DIVERT(DIVERT_ARGS_END)
        ${as_o}--enable-*|${as_o}--disable-*|${as_o}--with-*|${as_o}--without-*)
            optname_base=`printf '%s\n' "$optname" | cut -d= -f1`
            as_me_warn "Unknown option: '%s' - ignoring" "$optname_base"
            shift
            continue
            ;;

        ${as_o}-*)
            as_me_error "Unrecognized option: '%s'" "$optname"
            as_me_error "Try '%s --help' for more information." "$as_me_full"
            exit 1
            ;;

        *=*)
            varname=`printf '%s\n' "$arg" | cut -d= -f1`
            as_me_warn "Unknown variable: '%s' - ignoring" "$varname"
            shift
            ;;

        *)
            as_me_error "Unrecognized argument: '%s'" "$arg"
            as_me_error "Try '%s --help' for more information." "$as_me_full"
            exit 1
            ;;
    esac
done

AS_DIVERT(DIVERT_HELP_START)
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
  -n, --no-create         Do not create output files.
AS_DIVERT(DIVERT_HELP_ENABLE_OPTS)
Optional features/capabilities:
  --enable-<FEATURE>      Enable FEATURE during build.
  --disable-<FEATURE>     Disable FEATURE during build.
AS_DIVERT(DIVERT_HELP_WITH_OPTS)
Optional packages:
  --with-<PACKAGE>=[[ARG]]  Include PACKAGE during build.
  --without-<PACKAGE>     Exclude PACKAGE during build.
AS_DIVERT(DIVERT_HELP_VARS)
Environment variables:
AS_DIVERT(DIVERT_HELP_END)
Bug reports and suggestions should be sent to <$as_pkg_bugreport_addr>.
EOF
}

AS_DIVERT(DIVERT_ARGS_END)

[#] Print version information
show_version ()
{
cat <<EOF
$as_me ($PACKAGE_NAME $PACKAGE_VERSION)
This script is free software: there is no warranty.
EOF

test -n "$PACKAGE_BUGREPORT" && \
    echo "Bug reports for $PACKAGE_NAME should be sent directly to <$PACKAGE_BUGREPORT>."
}

AS_DIVERT(DIVERT_BODY)
])

AC_DEFUN([AC_ARG_ENABLE], [
AS_DIVERT(DIVERT_ARGS)
    ${as_o}--enable-$1|${as_o}--enable-$1=*|${as_o}--disable-$1|${as_o}--disable-$1=*)
        seen=1
        enableval=1

        case "$optname" in
            --disable-$1|--disable-$1=*)
                enableval=0
                seen=0
                ;;
            *)
                ;;
        esac

        shift

        if test "$optname" != "--enable-$1" && test "$optname" != "--disable-$1"; then
            case "$optname" in
                --enable-$1=*)
                    optlen="m4_eval(m4_len([--enable-][$1]) + 2)"
                    ;;

                --disable-$1=*)
                    optlen="m4_eval(m4_len([--disable-][$1]) + 2)"
                    ;;
            esac

            optval=`echo "$optname" | cut -c ${optlen}-`
            enableval="$optval"
        elif test $[#] -gt 0; then
            enableval=1
        fi

        $3

        as_opt_enable_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen="$seen"
        ;;
AS_DIVERT(DIVERT_HELP_ENABLE_OPTS)$2[]
AS_DIVERT(DIVERT_ARGS_PROC)
    if test "$as_opt_enable_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen" != 1; then
        $4
        :
    fi
AS_DIVERT(DIVERT_BODY)
])

AC_DEFUN([AC_ARG_WITH], [
AS_DIVERT(DIVERT_ARGS)
    ${as_o}--with-$1|${as_o}--with-$1=*|${as_o}--without-$1|${as_o}--without-$1=*)
        withval=""
        seen=1

        case "$optname" in
            --without-$1|--without-$1=*)
                withval=""
                seen=0
                ;;
            *)
                ;;
        esac

        shift

        if test "$optname" != "--with-$1" && test "$optname" != "--without-$1"; then
            case "$optname" in
                --with-$1=*)
                    optlen="m4_eval(m4_len([--with-][$1]) + 2)"
                    ;;

                --without-$1=*)
                    optlen="m4_eval(m4_len([--without-][$1]) + 2)"
                    ;;
            esac

            optval=`echo "$optname" | cut -c ${optlen}-`
            withval="$optval"
        elif test $[#] -gt 0; then
            withval=""
        fi

        $3

        as_opt_with_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen="$seen"
        ;;
AS_DIVERT(DIVERT_HELP_WITH_OPTS)$2[]
AS_DIVERT(DIVERT_ARGS_PROC)
    if test "$as_opt_with_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen" != 1; then
        $4
        :
    fi
AS_DIVERT(DIVERT_BODY)
])

AC_DEFUN([AC_ARG_VAR], [
AS_DIVERT(DIVERT_ARGS)
    $1=*)
        varname="$1"
        varval=`printf '%s' "${arg}" | cut -d= -f2-`
        shift
        $1="${varval}"
        $3
        as_arg_var_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen="1"
        ;;

AS_DIVERT(DIVERT_HELP_VARS)$2[]
AS_DIVERT(DIVERT_ARGS_PROC)
    if test "$as_arg_var_[]AS_SHELL_VAR_ESCAPE([$1])[]_seen" != 1; then
        $4
        :
    fi
AS_DIVERT(DIVERT_BODY)
])

AC_DEFUN([AC_STATUS_ARG_INIT], [
usage ()
{
cat <<EOF
$as_me -- generate output files and finalize build environment
with information collected during configuration.

Usage:
  $as_me_full [[OPTION]]... [[--]] [[TAG]]...

Options:
  -h, --help              Show this help and exit.
  -V, --version           Show version information and exit.
  -R, --recheck           Run configure again with the same options given
                          when this config.status was created.

EOF

as_printf "Configuration files:\n"

for file in $ac_config_files; do
    as_printf '  %s\n' "${file}"
done

as_printf "\nConfiguration headers:\n"

for header in $ac_config_headers; do
    as_printf '  %s\n' "${header}"
done

as_printf "\nConfiguration commands:\n"

for cmd in $ac_config_commands; do
    as_printf '  %s\n' "${cmd}"
done

as_printf "\n"
}

show_version ()
{
cat <<EOF
$as_me ($PACKAGE_NAME $PACKAGE_VERSION)
Generated by configure.
This script is free software: there is no warranty.
EOF

test -n "$PACKAGE_BUGREPORT" && \
    echo "Bug reports for $PACKAGE_NAME should be sent directly to <$PACKAGE_BUGREPORT>."
}

AS_WHILE([test $[#] -gt 0], [
    optname="$[1]"

    case "$optname" in
        -h|--help)
            usage
            exit 0
            ;;

        -V|--version)
            show_version
            exit 0
            ;;

        -R|--recheck)
            as_flag_recheck=1
            shift
            ;;

        --)
            shift
            break
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
])

AS_IF([test "$as_flag_recheck" = 1], [
    echo "$CONFIG_SHELL $as_configure_path --no-create $as_configure_args"
    command $CONFIG_SHELL $as_configure_path --no-create $as_configure_args
    exit $[?]
])
])
