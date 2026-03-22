dnl -*- autoconf -*-

AC_DEFUN([AC_INIT], [AS_DIVERT(DIVERT_HEADER)[]dnl
AS_SHEBANG
as_pkg_name="$1"
as_pkg_version="$2"
as_pkg_bugreport_addr="$3"
as_pkg_tarname="$4"
as_pkg_url="$5"

AC_PREINIT
AC_CORE_PRINT_INIT
AC_CORE_UTIL_FUNCTIONS
AC_ARG_INIT
AC_CORE_LOG_INIT

AS_DIVERT(DIVERT_BODY)
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

as_srcdir="$as_srcdir"
as_builddir="$as_builddir"

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
    input_path="$[1]"
    readlink=1
    test "$input_path" = "-x" && input_path="$[2]" && readlink=0
    command -v readlink >/dev/null 2>&1 && test $readlink -eq 1 && readlink -f "$input_path" && return

    old_ifs="$IFS"
    IFS="/"
    new_path=""

    for c in $input_path; do
        test "$c" = "." && continue

        if test "$c" = ".." && test -n "$new_path"; then
            case "$new_path" in
                */*)
                    new_path=`echo "$new_path" | rev | cut -d/ -f2- | rev`
                    ;;

                *)
                    new_path=
                    ;;
            esac

            continue
        fi

        test -n "$new_path" && new_path="$new_path/"
        new_path="$new_path$c"
    done

    IFS="$old_ifs"

    if test -d "$new_path"; then
        pwd=`cd "$new_path" && pwd -P`
        echo $pwd
        return
    fi

    dir=`dirname "$new_path"`
    pwd=`cd "$dir" && pwd -P`
    base=`basename "$new_path"`

    echo "$pwd/$base"
}

as_rel_path ()
{
    target="$[1]"
    from="$[2]"

    if test "$target" = "$from"; then
        echo "."
        return
    fi

    target=`as_realpath "$target" | cut -c 2-`
    from=`as_realpath "$from" | cut -c 2-`

    while test -n "$target" && test -n "$from"; do
        c1=`echo "$target" | cut -d/ -f1-1`
        test -z "$from" && break
        c2=`echo "$from" | cut -d/ -f1-1`
        if test "$c1" = "$c2"; then
            case "$target" in
                */*)
                    target=`echo "$target" | cut -d/ -f2-`
                    ;;

                *)
                    target=
                    ;;
            esac

            case "$from" in
                */*)
                    from=`echo "$from" | cut -d/ -f2-`
                    ;;

                *)
                    from=
                    ;;
            esac

            continue
        fi

        break
    done

    f_path=""
    old_ifs="$IFS"
    IFS="/"

    for c in $from; do
        test -n "$f_path" && f_path="${f_path}/"
        f_path="${f_path}.."
    done

    IFS="$old_ifs"
    test -n "$f_path" && test -n "$target" && f_path="${f_path}/"
    test -n "$target" && f_path="${f_path}${target}"

    echo "$f_path"
}

as_me_full="[$]0"
as_me=`basename "[$]0"`
as_me_dir=`dirname "[$]0"`

test -z "$as_srcdir" && as_srcdir="$as_me_dir"
test -z "$as_builddir" && as_builddir="."
test -z "$as_abs_srcdir" && as_abs_srcdir=`as_realpath "$as_srcdir"`
test -z "$as_abs_builddir" && as_abs_builddir=`as_realpath "$as_builddir"`
test -z "$as_build_aux_dir" && as_build_aux_dir="$as_srcdir"

top_srcdir=`as_rel_path "$as_abs_srcdir" "$as_abs_builddir"`
top_builddir="$as_builddir"

if test -n "$ZSH_VERSION"; then
    setopt sh_word_split
fi

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

    AC_REQUIRE([AC_ENSURE_POSIX])
    AC_REQUIRE([AC_ENSURE_SANENESS])
    AC_REQUIRE([AC_PROG_AWK])
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
