AC_DEFUN([AC_INIT], [dnl
AS_SHEBANG
#
# configure -- prepares '$1 $2' for build
#

as_pkg_name="$1"
as_pkg_version="$2"
as_pkg_bugreport_addr="$3"
as_pkg_tarname="$4"
as_pkg_url="$5"

as_pkg_eff_tarname="$as_pkg_tarname"
test -z "$as_pkg_eff_tarname" && as_pkg_eff_tarname="$as_pkg_name"

as_me_full="[$]0"
as_me=`basename "[$]0"`
as_me_dir=`dirname "[$]0"`

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

as_srcdir="$as_me_dir"
as_builddir=`pwd`
as_abs_srcdir=`as_realpath "$as_srcdir"`
as_abs_builddir=`as_realpath "$as_builddir"`

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

as_printf ()
{
    fmt="$[1]"
    shift
    printf -- "$fmt" "$[@]"
}

as_me_println ()
{
    fmt="$[1]"
    shift
    printf -- "$as_me: $fmt\n" "$[@]"
}

AC_CORE_UTIL_FUNCTIONS

AC_CORE_LOG_INIT
AC_CORE_PRINT_INIT
])dnl

AC_DEFUN([AC_CORE_UTIL_FUNCTIONS], [
ac_conftest_dir="$as_builddir/.conftests"

mkdir -p "$ac_conftest_dir" || {
    AC_MSG_ERROR([Unable to create .conftests directory])
}

as_temp_cleanup ()
{
    rm -rf "$ac_conftest_dir"
}

as_cleanup_cb_add as_temp_cleanup

as_rand ()
{
    od -An -N2 -tu2 /dev/urandom | cut -c 2-
}

as_mktemp ()
{
    rand=`as_rand`
    tmp="$ac_conftest_dir/tmp-$rand"
    echo "$tmp"
}
])
