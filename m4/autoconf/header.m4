dnl -*- autoconf -*-

AC_DEFUN([AC_INIT], [m4_divert(DIVERT_HEADER)[]dnl
AS_SHEBANG
as_pkg_name="$1"
as_pkg_version="$2"
as_pkg_bugreport_addr="$3"
as_pkg_tarname="$4"
as_pkg_url="$5"

AC_PREINIT
AC_ARG_INIT
AC_CORE_PRINT_INIT
AC_CORE_UTIL_FUNCTIONS
AC_CORE_LOG_INIT

m4_divert(DIVERT_BODY)
AC_CORE_RUN_CHECKS
])

AC_DEFUN([AC_STATUS_INIT], [
cat > $1 <<AS_EOF
AS_SHEBANG

as_pkg_name="$2"
as_pkg_version="$3"
as_pkg_bugreport_addr="$4"
as_pkg_tarname="$5"
as_pkg_url="$6"

AS_EOF_END

cat >> $1 <<'AS_EOF'
AC_PREINIT
AC_CORE_PRINT_INIT
AC_CORE_UTIL_FUNCTIONS

ac_log_printf ()
{
    :
}

ac_log_heading ()
{
    :
}

AS_EOF_END
])

AC_DEFUN([AC_PREINIT], [
as_pkg_eff_tarname="$as_pkg_tarname"
test -z "$as_pkg_eff_tarname" && as_pkg_eff_tarname="$as_pkg_name"

PACKAGE_NAME="$as_pkg_name"
PACKAGE_VERSION="$as_pkg_version"
PACKAGE_FULLNAME="$as_pkg_name-$as_pkg_version"
PACKAGE_BUGREPORT="$as_pkg_bugreport_addr"
PACKAGE_TARNAME="$as_pkg_eff_tarname"
PACKAGE_URL="$as_pkg_url"

as_realpath ()
{
    path="$[1]"
    name=""

    test -d "$path" || {
        name="/"`basename "$path"`
    }

    pwd=`pwd -P`
    test $? -eq 0 || return 1

    printf "%s%s\n" "$pwd" "$name"
}

as_me_full="[$]0"
as_me=`basename "[$]0"`
as_me_dir=`dirname "[$]0"`

test -z "$as_srcdir" && as_srcdir="$as_me_dir"
test -z "$as_builddir" && as_builddir="."
test -z "$as_abs_srcdir" && as_abs_srcdir=`as_realpath "$as_srcdir"`
test -z "$as_abs_builddir" && as_abs_builddir=`as_realpath "$as_builddir"`
test -z "$as_build_aux_dir" && as_build_aux_dir="$as_srcdir"

as_nl='
'
as_tab='	'
as_spc=' '
as_ifs="$as_nl$as_tab$as_spc"

IFS="$as_ifs"

as_now ()
{
    date '+%Y-%m-%d %H:%M:%S'
}

as_date_start=`as_now`
as_cleanup_cb_list=""

as_cleanup_cb_add ()
{
    for cb in "$[@]"; do
        case "$as_cleanup_cb_list" in
            *" $cb"|"$cb "*)
                continue
                ;;

            *)
                ;;
        esac

        as_cleanup_cb_list="$as_cleanup_cb_list $cb"
    done

}

as_cleanup ()
{
    for cb in $as_cleanup_cb_list; do
        $cb
    done
}

trap 'as_code=$?; as_cleanup; exit $as_code;' EXIT INT TERM
])

AC_DEFUN([AC_CORE_UTIL_FUNCTIONS], [
ac_conftest_dir="$as_builddir/.conftests"

as_temp_cleanup ()
{
    rm -rf "$ac_conftest_dir"
}

as_cleanup_cb_add as_temp_cleanup

as_rand ()
{
    od -An -N2 -tu2 /dev/urandom | tr -d '[[:space:]]'
}

as_mktemp ()
{
    rand=`as_rand`
    test -n "$[1]" && rand="${rand}$[1]"
    tmp="$ac_conftest_dir/tmp-$rand"
    echo "$tmp"
}
])

AC_DEFUN([AC_CORE_RUN_CHECKS], [
    cd "$as_builddir" || {
        AC_MSG_ERROR([Unable to change directory to $as_builddir])
    }

    mkdir -p "$ac_conftest_dir" || {
        AC_MSG_ERROR([Unable to create .conftests directory])
    }

    AS_IF([test -d "$as_build_aux_dir"], [], [
        AC_MSG_ERROR([Auxiliary script directory '$as_build_aux_dir' could not be found or accessed])
    ])

    AC_ENSURE_POSIX
    AC_ENSURE_SANENESS
])

AC_DEFUN([AC_ENSURE_SANENESS], [
    AC_MSG_CHECKING([whether build environment is sane])
    AS_IF([test -r "$as_builddir" && test -d "$as_builddir" && test -r "$as_srcdir" && test -d "$as_srcdir"], [sane=1], [sane=0])
    AS_IF([test "$sane" -eq 1], [
        id=`date '+%s'`
        touch "$as_builddir/.conftest-$id" 2>/dev/null
        test $? -ne 0 && sane=0
        test -f "$as_builddir/.conftest-$id" || sane=0
        rm -f "$as_builddir/.conftest-$id"
    ])
    AS_IF([test "$sane" -eq 1], [
        id=`date '+%s'`
        touch "$as_srcdir/.conftest-$id" 2>/dev/null
        test $? -ne 0 && sane=0
        test -f "$as_srcdir/.conftest-$id" || sane=0
        rm -f "$as_srcdir/.conftest-$id"
    ])
    AS_IF([test "$sane" -eq 1], [AC_MSG_RESULT([yes])], [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([Build environment is not sane.  Please double check if the filesystem is writable and accessible.  Ensure permissions are correct.])
    ])
])

AC_DEFUN([AC_CONFIG_AUX_DIR], [as_build_aux_dir=$1])
