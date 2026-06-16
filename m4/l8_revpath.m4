
# L8_REVERSE_PATH(<VAR>, <FILEPATH>)
# VAR <- relative path to current directory from FILEPATH
# (final component ignored if an ordinary file), or,
# if symbolic links or other silliness makes this too hard,
# then an absolute path to current directory.
#
m4_defun([L8_REVERSE_PATH],
 [AS_REQUIRE([_L8_REVERSE_PATH_PREPARE])[
  l8_fn_reverse_path ]$1 "$2"])

# _L8_GET_INODE(<VAR>, <DIR>, <IF_NOT_FOUND>)
# VAR <- inode of DIR (and it looks like we only ever
# use this for DIR = . or .., so no error cases).
#
m4_define([_L8_GET_INODE],
[AS_VAR_SET([$1], [[$(ls -di ]$2[)]])
AS_VAR_SET([[_l8_s]], [[${]$1[%%[0-9]*}]])
AS_VAR_IF([[_l8_s]],[],[],[AS_VAR_SET( [$1], [[${]$1[@%:@$_l8_s}]])])
AS_VAR_SET( [$1], [[${]$1[%[	 ]*}]])])

# _L8_GET_INAME(<VAR>, <INODE>, <IF_NOT_FOUND>)
# VAR <- filename of INODE in current directory
# unless INODE is not actually in the current directory,
# (which really should not be possible but INODE might
# have a stupid name that confuses the command line parser),
# in which case expand IF_NOT_FOUND.
#
m4_define([_L8_GET_INAME],
[AS_VAR_SET( [$1], [["$( ls -ai . | ]dnl
[sed -n '/^[	 ]*']$2['[^0123456789]/]dnl
[{s/^[	 ]*[0123456789][0123456789]*[	 ]*//
p
}' )"]])
AS_VAR_IF(   [$1], [], [$3])])

dnl   Doing this without sed is harder,
dnl   in case you were wondering:  ([["$(...
dnl grep -E '^[	 ]*']$2['[	 ]')"]])
dnl AS_VAR_IF(   [$1], [
dnl   AS_VAR_SET( [[y]], [["${]$1[%%[!	 ]*}"]])
dnl   AS_VAR_IF(  [[y]],[],[],[
dnl     AS_VAR_SET( [$1], [["${]$1[@%:@$y}"]])])
dnl   AS_VAR_SET( [[y]], [["${]$1[%%[	 ][!	 ]*}"]])
dnl   AS_VAR_SET( [$1],  [["${]$1[@%:@$y?}"]])],
dnl [dnl else
dnl   $3])


# _L8_RP_PUT_STEP(<STEP>)
# assuming the current directory has not been previously encountered
# and $_l8_ihere = its inode,
# and <STEP>/$$_l8_result gets us back to the start,
# update $$_l8_result, $_l8_$from$_l8_ihere, and $_l8_all_inodes
#
m4_define([_L8_RP_PUT_STEP],
[AS_VAR_COPY(  [[_l8_sofar]],          [[$_l8_result]])
AS_VAR_SET(   [[$_l8_result]],         [$1][[/$_l8_sofar]])
AS_VAR_COPY(   [[_l8_from$_l8_ihere]], [[$_l8_result]])
AS_VAR_APPEND( [[_l8_all_inodes]],     [[" $_l8_ihere"]])])

m4_defun([_L8_REVERSE_PATH_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_reverse_path],
  [AS_FUNCTION_DESCRIBE([l8_fn_reverse_path],[VAR FILEPATH],
    [Set VAR= relative path to current directory from FILEPATH
(final component ignored if this is an ordinary file),
or, if we encounter something stupid, then give up and
provide an absolute path to current directory.])[

_l8_fn_try_relative_reverse_path () ]{
  AS_VAR_SET(    [[_l8_result]],         [[$][1]])
  AS_VAR_SET(    [[_l8_first]],          [[:]])
  AS_VAR_SET(    [[_l8_last]],           [[false]])
  _L8_GET_INODE( [[_l8_iprev]],          [[.]])

  AS_VAR_SET(   [[$_l8_result]],         [[.]])
  AS_VAR_SET(    [[_l8_from$_l8_iprev]], [[.]])
  AS_VAR_COPY(   [[_l8_all_inodes]],     [[_l8_iprev]])
  AS_VAR_COPY(   [[_l8_save_IFS]],       [[IFS]])
  AS_VAR_SET(    [[IFS]],                [[/]])[
  for _l8_step in $][2; do]
    AS_VAR_COPY( [[IFS]],                [[_l8_save_IFS]])
    AS_IF( [[$_l8_last]], [[
      return 1]])
    AS_CASE( [[$_l8_step]], [[
      '']], [
         AS_IF( [[$_l8_first]], [
           AS_VAR_SET( [[_l8_first]],  [[false]])[
           # abs path => we need to get to the root
           while : ; do]
             _L8_GET_INODE([[_l8_ihere]], [[..]])
             AS_VAR_IF([[_l8_ihere]], [[$_l8_iprev]], [[break]])[
             cd .. || return 1]
             _L8_GET_INAME(   [[_l8_nstep]],  [[$_l8_iprev]], [[return 1]])
             _L8_RP_PUT_STEP( [[$_l8_nstep]])
             AS_VAR_COPY(     [[_l8_iprev]],  [[_l8_ihere]])[
           done]])], [[

       .]], [], [[

      ..]], [
          _L8_GET_INODE([[_l8_ihere]], [[..]])
          AS_VAR_IF([[_l8_ihere]], [[$_l8_iprev]],
            [],
[dnl      else
            [cd .. || return 1]
            AS_VAR_SET_IF( [[_l8_from$_l8_ihere]], [
               AS_VAR_COPY(  [[$_l8_result]],    [[_l8_from$_l8_ihere]])],
[dnl        else
               _L8_GET_INAME( [[_l8_nstep]],     [[$_l8_iprev]], [[return 1]])
               _L8_RP_PUT_STEP(    [[$_l8_nstep]])])
            AS_VAR_COPY(      [[_l8_iprev]],     [[_l8_ihere]])])],

[dnl  default case:
          AS_IF( [[test -e "$_l8_step" && test ! -d "$_l8_step"]], [
            AS_VAR_SET(         [[_l8_last]],    [[:]])],
[dnl      else
            [cd "$_l8_step" || return 1]
            _L8_GET_INODE(      [[_l8_ihere]],   [[.]])
            AS_VAR_SET_IF( [[_l8_from$_l8_ihere]], [
              AS_VAR_COPY(     [[$_l8_result]],  [[_l8_from$_l8_ihere]])],
[dnl        else
              _L8_GET_INODE(    [[_l8_iback]],   [[..]])
              AS_VAR_SET_IF( [[_l8_from$_l8_iback]], [
                AS_VAR_COPY(   [[$_l8_result]],  [[_l8_from$_l8_iback]])],
[dnl          else
                [return 1]])
              _L8_RP_PUT_STEP(    [[..]])])
            AS_VAR_COPY(     [[_l8_iprev]],  [[_l8_ihere]])])])
    AS_VAR_SET( [[_l8_first]],  [[false]])[
  done]
  AS_VAR_COPY(  [[IFS]],         [[_l8_save_IFS]])
  AS_VAR_COPY(  [[_l8_sofar]],   [[$_l8_result]])
  AS_VAR_SET(   [[$_l8_result]], [[${_l8_sofar%/.}]])[
  return 0
]}

], [dnl -- l8_fn_reverse_path () -- main body:
  AS_VAR_SET(    [[_l8_result]],   [[$][1]])
  AS_VAR_SET(    [[_l8_goal]],     [[`pwd`]])
  AS_IF( [[_l8_fn_try_relative_reverse_path $][1 $][2]], [], [
    AS_VAR_COPY( [[$_l8_result]],  [[_l8_goal]])])[

  for _l8_inode in $_l8_all_inodes; do]
    AS_UNSET(    [[_l8_from$_l8_inode]])[
  done]
  AS_UNSET(      [[_l8_all_inodes]])[
  cd "$_l8_goal"]])])


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
