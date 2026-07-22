
# L8_REVERSE_PATH(<VAR>, <DIR>)
# VAR <- relative path to current directory from DIR
# with status 0 or do nothing with status 1 if DIR
# does not exist or something else goes wrong
#
m4_defun([L8_REVERSE_PATH],
 [AS_REQUIRE([_L8_CWD_TO_PWD_PREPARE])
{[
    _l8_end=`pwd`
    _l8_beg=]$2
    AS_VAR_SET([$1],[[`cd "$_l8_beg" 2>/dev/null &&
       l8_fn_cwd_to_pwd _l8_path "$_l8_end" &&
       printf '%s\n' "$_l8_path"`]])
}])

# L8_RELATIVE_PATH(<VAR>, <DIR>)
# VAR <- relative path from current directory to DIR
# with status 0 or do nothing with status 1 if DIR
# does not exist or something else goes wrong
#
m4_defun([L8_RELATIVE_PATH],
 [AS_REQUIRE([_L8_CWD_TO_PWD_PREPARE])[
{
  _l8_end=]$2[
  _l8_end=`cd "$_l8_end" 2>/dev/null && pwd` &&
  l8_fn_cwd_to_pwd ]$1[ "$_l8_end"
}]])

m4_defun([_L8_CWD_TO_PWD_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_cwd_to_pwd],
  [AS_FUNCTION_DESCRIBE([l8_fn_cwd_to_pwd],[VAR PWD],
    [Set VAR= a relative path from here to PWD,
returning status 1 if we cannot for some reason])
],
[  AS_VAR_COPY( [[dest]], [[2]])
  AS_VAR_SET(   [[here]], [[.]])[
  while `cd "$here" 2>/dev/null && ]
       AS_VAR_SET([[pwd]],[[$(pwd)]]) &&
       [test "$pwd" != / && ]
       AS_CASE([[$dest]],
[[        "$pwd"]],
[[           false]],
[[      "$pwd"/*]],
[[           false]],
[[           :]]) [`
  do]
    AS_VAR_SET([[here]],[["$here/.."]])[
  done
  ( cd "$here" 2>/dev/null ) || return 1; ]
  AS_VAR_SET([[suffix]],[[`
    cd "$here"]
    AS_VAR_SET([[pwd]],[[$(pwd)]])
    AS_CASE([[$pwd]],
[[         /]],
[[            printf '%s' "${dest@%:@/}"]],
[[   "$dest"]],
[[            printf '']],
dnl     default
[[            x=${dest@%:@"$pwd/"}
                printf '%s' "$x"]]) `])
  AS_VAR_SET([[here]],[[${here@%:@./}]])
  AS_VAR_IF([[suffix]],[],
 [  AS_VAR_COPY([[$][1]],[[here]])],[
    AS_VAR_IF([[here]],[.],
 [    AS_VAR_COPY([[$][1]],[[suffix]])],[
      AS_VAR_SET([[$][1]],[[$here/$suffix]])])])])])

dnl dw=$(cd "$dest"; whereami);
dnl eval rw=\$\(cd \"\$$1\" \&\& whereami\) || return 1
dnl test x"$dw" = x"$rw" || return 1


# !!!FIX  are we using the rest of this file...???

# _L8_GET_INODE(<VAR>, <DIR>, <IF_NOT_FOUND>)
# VAR <- inode of DIR
# (.we only use this on . or .. but on Android this fails
# if you get too near the top of the hierarchy.)
#
m4_define([_L8_GET_INODE],
[AS_VAR_SET([$1], [[$(ls -di ]$2[)]])
AS_VAR_SET([[_l8_s]], [[${]$1[%%[0-9]*}]])
AS_VAR_IF([[_l8_s]],[],[],[AS_VAR_SET( [$1], [[${]$1[@%:@$_l8_s}]])])
AS_VAR_SET( [$1], [[${]$1[%[	 ]*}]])])


# L8_DIR_CONTAINS(<PATH1>, <PATH2>)
m4_defun([L8_DIR_CONTAINS],
 [AS_REQUIRE([_L8_DIR_CONTAINS_PREPARE])[
  l8_fn_dir_contains ]"$1" "$2"])

m4_defun([_L8_DIR_CONTAINS_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_dir_contains],
  [AS_FUNCTION_DESCRIBE([l8_fn_dir_contains],[PATH1 PATH2],
    [Returns status 0 (true) if PATH1 is an ancestor of
PATH2 or the same directory; otherwise returns status 1.
Returns status 2 if one of the paths is nonexistent
or not a directory.])],

[dnl -- l8_fn_dir_contains () -- main body:
  AS_VAR_SET(    [[_l8_save]],    [[`pwd`]])
  [cd "$][1"   2>/dev/null || return 2]
  _L8_GET_INODE( [[_l8_igoal]],   [[.]])[
  cd $_l8_save 2>/dev/null || ]{ AS_ECHO([["cd cwd fails?"]]) >&2;AS_EXIT(2); }[
  cd "$][2"    2>/dev/null || return 2]
  _L8_GET_INODE( [[_l8_ihere]],   [[.]])[
  while : ; do]
    AS_VAR_IF([[_l8_ihere]], [[$_l8_igoal]],
[[    cd $_l8_save 2>/dev/null || ]{ AS_ECHO([["cd cwd fails?"]]) >&2;AS_EXIT(2); }[
      return 0]])
    _L8_GET_INODE( [[_l8_inext]], [[..]])
    AS_VAR_IF([[_l8_ihere]], [[$_l8_inext]],
[[    cd $_l8_save 2>/dev/null || ]{ AS_ECHO([["cd cwd fails?"]]) >&2;AS_EXIT(2); }[
      return 1]])
    AS_VAR_COPY([[_l8_ihere]], [[_l8_inext]])[
    cd ..
  done
]])])
