m4_include([m4/ax_lp.m4])
m4_include([m4/l8_optarg.m4])
m4_include([m4/l8_revpath.m4])
m4_include([package_l8tf.m4])
m4_include([install-l8tf-opt.m4])

# define IT_OPTION_HELP_LINES, IT_OPTION_CASES, IT_OPTION_CASES_FIRST
L8_OPT_USE([SHELL], [IT_OPTION_CASES],      m4_defn([INSTALL_L8TF_OPTS]))
L8_OPT_USE([HELP],  [IT_OPTION_HELP_LINES], m4_defn([INSTALL_L8TF_OPTS]))
L8_OPT_USE([ARGS], [IT_OPTION_ARGS], m4_defn([INSTALL_L8TF_OPTS]))
m4_define([IT_OPTION_ARGS],
m4_unquote([m4_dquote(m4_join([ ],]m4_defn([IT_OPTION_ARGS])[))]))

AS_INIT
AS_COPYRIGHT(m4_defn([L8TF_COPYRIGHT]))[

_l8_b=`basename -- x/y`]
AS_VAR_IF([[_l8_b]],[[--]],
[[l8_basename='basename']],
[[l8_basename='basename --']])[

#------------------------------------------------
# basic messaging, death with dignity
#
l8_verbosity=0

# l8_fn_msg MIN_VERBOSITY MESSAGE
# ---------
#
l8_fn_msg () ]{
  AS_IF([[test $l8_verbosity -ge $][1]],
  [  AS_ECHO(["$][2"])])
}[

# l8_fn_fatal ERROR_MSG...
# -----------
#   how to exit with an error message
#
l8_fn_fatal () ]{[
  s=$?
  test $s -eq 0 && s=1]
  AS_IF([[test $][@%:@ -gt 0]],
 [  AS_ECHO([["$@"]]) [>&2]])
  AS_EXIT([[$s]])
}[

# l8_fn_usage ERROR_MSG ?DONT_MENTION_HELP
# -----------
#
l8_fn_usage () ]{
  AS_VAR_IF([2],[],
[[  l8_fn_fatal "$1" "$as_myself --help  will show a list of valid options"]],[[
    l8_fn_fatal "$1"]])
}[

#------------------------------------------------
# cleaning up
#

l8_all_cleanups=tempdir
l8_cancellable_cleanups=
l8_cleanup_tempdir=

# l8_fn_add_noncancel_cleanup CL_KWD
# --------------
# create a cleanup that cannot (yet) be cancelled
#
l8_fn_add_noncancel_cleanup () ]{
  # accidental blank kwords would be bad
  AS_VAR_IF([[1]],[],
[[  l8_fn_fatal "cleanup keyword = ''?"]])
  AS_VAR_SET([[l8_cleanup_$][1]],[])[
  l8_all_cleanups="$1 $l8_all_cleanups"
]}[

# l8_fn_cleanup_trap
# --------------
# what actually runs at exit
#
l8_fn_cleanup_trap () ]{[
  for _l8_cl in $l8_all_cleanups ; do]
    AS_VAR_IF([[l8_cleanup_$_l8_cl]],[],[],[[
      eval 'l8_fn_msg 2 "'"(cleanup) Removing '"\$l8_cleanup_$_l8_cl"'"'"'
      eval 'rm -rf "'\$l8_cleanup_$_l8_cl'"']])[
  done
]}[

# l8_fn_cancel_cleanups
# --------------
# cancel all of the cancellable cleanups
#
l8_fn_cancel_cleanups () ]{[
  l8_fn_msg 3 "Cancelling cleanups:  $l8_cancellable_cleanups"
  for _l8_cl in $l8_cancellable_cleanups ; do]
    AS_VAR_SET([[l8_cleanup_$_l8_cl]],[])[
  done
]}[

# l8_fn_add_cleanup CL_KWD
# --------------
# create a cleanup that can be cancelled
#
l8_fn_add_cleanup () ]{
  [l8_fn_add_noncancel_cleanup "$][1"]
  AS_VAR_APPEND([[l8_cancellable_cleanups]],[[" $][1"]])
}[

# l8_fn_set_file_cleanup CL_KWD FILENAME
# --------------
# set the filename for this cleanup
# (save as an absolute path in case we cd someplace unexpected)
#
l8_fn_set_file_cleanup () ]{
  AS_VAR_SET([[_l8_pwd]],[[`pwd`]])
  AS_SET_CATFILE([[l8_cleanup_$][1]],[[$_l8_pwd]],[["$][2"]])
}[

# l8_verbosity=2
# l8_fn_add_cleanup wombat
# touch fribble/foo
# l8_fn_set_file_cleanup wombat fribble/??
# printf '(%s)\n' "$l8_cleanup_wombat"
# l8_fn_cancel_cleanups

# :; preserves exit status in pre-2.05 versions of bash (?)
trap ':; l8_fn_cleanup_trap' 0

#------------------------------------------------
# temporary directory
#
l8_temp_dir=

# l8_fn_make_temp_dir WHERE
# --------------
#   give us this day our temporary directory within WHERE
#   and lead us not into temptation
#   (WHERE is absolute
#   => l8_fn_next_temp_file won't care what directory we're in)
#
l8_fn_make_temp_dir () ]{
  AS_VAR_IF([[l8_temp_dir]], [],
 [  AS_TMPDIR([l8IT],[[$][1]])m4_newline()[
    l8_temp_dir="$tmp"
    l8_fn_set_file_cleanup tempdir "$tmp"]],
  dnl else (temp_dir already named)
[
    AS_IF([[test ! -d "$l8_temp_dir" || test ! -w "$l8_temp_dir"]],
[[    l8_fn_fatal "bad temp directory:  $l8_temp_dir"]])])
}[

# l8_fn_next_temp_file VAR NAME
# --------------
#   VAR= unused temp file vaguely named NAME
#
l8_fn_next_temp_file () ]{[
  _l8_base="$l8_temp_dir/$][2"]
  _l8_n=0
  AS_VAR_COPY([[$][1]],[[_l8_base]])[
  while eval test -r '"$'$][1'"' ; do]
    L8_VAR_INCR([[_l8_n]])
    AS_VAR_SET([[$][1]],[["$_l8_base$_l8_n"]])[
  done
]}[

#------------------------------------------------
# how to schedule pending updates
#

# l8_fn_init_save BASE_DIR
# --------------
# initialize l8_save_base_dir (to BASE_DIR) and everything
# else that l8_fn_save and l8_fn_commit_updates depend on
#
l8_fn_init_save () ]{[
  l8_save_base_dir="$1"
  l8_save_fname=/dev/null
  l8_save_clkwd=
  l8_do_finish_install=:
  l8_v_save_same=2
  l8_v_save_update=1
  l8_v_save_new=1
  l8_fn_next_temp_file l8_finish_cmds do_it
  printf '@%:@ updates scheduled\n' >"$l8_finish_cmds"
]}[

# l8_fn_next_save_file NAME CL_KWD
# --------------
# l8_save_fname= destination file NAME (relative to $l8_save_base_dir)
#   must either previously exist or have been trial-created
#   with an active cleanup
# l8_save_temp= new source (reserved temp filepath vaguely named NAME)
#   someplace to write the new version to
# l8_save_clkwd= associated cleanup (CL_KWD)
#
l8_fn_next_save_file () ]{
  AS_SET_CATFILE([[l8_save_fname]],[[$l8_save_base_dir]],[[$][1]])[
  l8_save_clkwd=$][2
  l8_fn_next_temp_file l8_save_temp `$l8_basename $][1]`
}[

# l8_fn_update_single DEST SOURCE KWD
# --------------
#   schedule update of DEST from (file) SOURCE
#
l8_fn_update_single () ]{
  AS_IF([[test -d "$][1"]],
[[  # should not happen
    l8_fn_fatal "$][1: overwrite directory with regular file?"]],
[[test ! -e "$][1"]],
[[  l8_fn_msg  $l8_v_save_new     "NewFile:  $][1"
    printf "mv '%s' '%s'\n" "$][2" "$][1" >>"$l8_finish_cmds"]],
[[test ! -f "$][1"]],
[[  # definitely should not happen
    l8_fn_fatal "$][1: weird file type"]],
[[diff -q "$][1" "$][2" >/dev/null]],
[[  l8_fn_msg  $l8_v_save_same    "Same:     $][1"]
    AS_VAR_SET([[l8_unchanged_$][3]],[1])],
  dnl else
[[
    $l8_do_clobber || l8_do_finish_install=false
    l8_fn_msg  $l8_v_save_update  "Changed:  $][1"
    printf "mv -f '%s' '%s'\n" "$][2" "$][1" >>"$l8_finish_cmds"]
    AS_IF([[$l8_do_diff]],
[[    diff $l8_diff_flags "$][1" "$][2"]])])
}[

# l8_fn_update_dir DEST SOURCE KWD
# --------------
#   schedule update of DEST from (directory) SOURCE
#   recursing as necessary
#
l8_fn_update_dir () ]{
  AS_IF([[test ! -e "$][1"]],
[[  l8_fn_msg  $l8_v_save_new     "NewDir:   $][1"
    printf "mv -f '%s' '%s'\n" "$][2" "$][1" >>"$l8_finish_cmds"]],
[[test ! -d "$][1"]],
[[  $l8_do_clobber || l8_do_finish_install=false
    l8_fn_msg  $l8_v_save_update  "FtoDir:   $][1"
    printf "rm -f '%s'; mv '%s' '%s'\n" "$][1" "$][2" "$][1" >>"$l8_finish_cmds"]],
  dnl else
[[
    cd "$][2"
    for _l8_entry in .* *; do]
      AS_CASE([[$_l8_entry]],[[.|..|'*']],[[continue]])[
      _l8_ekwd=${][3}_]AS_TR_SH([$_l8_entry])

      AS_IF([[test -d "$][2/$_l8_entry"]],
[[      l8_fn_update_dir    "$][1/$_l8_entry" "$][2/$_l8_entry" "$_l8_ekwd"]],
      dnl else
[[
        l8_fn_update_single "$][1/$_l8_entry" "$][2/$_l8_entry" "$_l8_ekwd"]])[
    done]] )
}[

# l8_fn_save
# ----------
# if there is an active cleanup ($l8_save_clkwd) for $l8_save_name
#   write new file/dir directly there
# else
#   schedule an update
#
l8_fn_save () ]{[
  l8_cleanup_=]
  AS_VAR_IF([[l8_cleanup_$l8_save_clkwd]], [],
 [  AS_IF([[test ! -r "$l8_save_fname"]],
 [[    l8_fn_fatal "l8_fn_save: assertion failed: -r '$l8_save_fname'"]])],[
    AS_VAR_COPY([[_l8_f]], [[l8_cleanup_$l8_save_clkwd]])[
    l8_fn_msg  $l8_v_save_new     "New:      $_l8_f"
    rm -rf "$_l8_f"
    mv -f "$l8_save_temp" "$_l8_f"
    return]])
  AS_IF([[test ! -d "$l8_save_temp"]],
[[  l8_fn_update_single "$l8_save_fname" "$l8_save_temp" "$l8_save_clkwd"]],
[[$l8_do_recreate]],
[[  l8_fn_msg  $l8_v_save_update  "Recreate: $l8_save_fname"
    printf "rm -rf '%s' ; mv -f '%s' '%s'\n" \
      "$l8_save_fname" "$l8_save_temp" "$l8_save_fname" \
      >>"$l8_finish_cmds"]],
  dnl else (-d $l8_save_temp && !$l8_do_recreate)
[[
    l8_fn_update_dir    "$l8_save_fname" "$l8_save_temp" "$l8_save_clkwd"
    cd "$l8_subject"]])
}[

# l8_fn_commit_updates
# --------------
#    perform scheduled updates
l8_fn_commit_updates () ]{
  AS_IF([[test $l8_verbosity -ge 2]],
 [  AS_ECHO([["@%:@ end of list"]])[ >>"$l8_finish_cmds"
    cat "$l8_finish_cmds"]])dnl

  [. "$l8_finish_cmds"
]}[

#------------------------------------------------
# remaining utilities
#

# l8_fn_read_init_file WHICH FILENAME
# --------------
# WHICH is one of 'site', 'subject', 'prev', 'user'
# if FILENAME.sh exists, source it
# elsif FILENAME exists, extract/reparse options out of it
#
l8_init_file=
l8_init_source=

l8_fn_read_init_file () ]{[
  l8_init_source="$][1"
  l8_init_file="$][2"]
  AS_IF([[test -r "$l8_init_file.sh"]],
[[  l8_fn_msg 1 "Reading '$l8_init_file.sh'"
    . "$l8_init_file.sh"]],

  [[test -e "$l8_init_file.sh"]],
[[  l8_fn_fatal "$l8_init_file.sh exists but cannot be read"]],

  [[test -r "$l8_init_file"]],
[[  l8_fn_msg 1 "Reading '$l8_init_file'"
    _l8_content=$(sed -e 's/^@%:@.*//' -e 's/[ 	]@%:@.*//' "$l8_init_file" | tr "$as_nl" ' ')]
    AS_VAR_IF([[_l8_content]],[],[],
    dnl else
[[
      eval 'l8_fn_parse_cmdline '"$_l8_content"]])],

[[test -e "$l8_init_file"]],
[[  l8_fn_fatal "$l8_init_file exists but cannot be read"]])dnl
[
  l8_init_source=
  l8_init_file=
]}[

# l8_fn_do_version()
# --------------
# print version information

l8_fn_do_version() ]{[
  cat <<L8END
This is ]m4_defn([L8TF_PACKAGE_NAME])[ version ]m4_defn([L8TF_PACKAGE_VERSION])[
(commit @%:@]L8TF_PACKAGE_COMMIT[)

]L8TF_COPYRIGHT[
]L8TF_LICENSE_SHORT[
L8END]
  AS_IF([[test $l8_verbosity -gt 1]], [[cat <<\L8END

There should be a LICENSE file.  I also like cats.
(Additional details will be available as soon as I think of some.)
L8END
]])
}[

# l8_fn_do_help()
# --------------
# print help text

l8_fn_do_help() ]{[
    cat <<L8END
Usage:
  $as_me [OPTIONS]]
IT_OPTION_HELP_LINES
[
L8END
]}

L8_OPT_CMDLINE_PARSE_FN([[l8_fn_firstpass_cmdline]],
  [do [first]ed command line arguments],
  [IT_OPTION_CASES_FIRST])

L8_OPT_CMDLINE_PARSE_FN([[l8_fn_parse_cmdline]],
  [parse command line arguments (skip [first]ed ones)],
  [IT_OPTION_CASES]dnl
[[    l8_fn_usage "unrecognized option:  '$1'"
       ]])[

# l8_fn_saved_args_to_sh
# ----------------------
#
l8_fn_saved_args_to_sh() ]{[
  for _l8_var in] IT_OPTION_ARGS
  [do
    eval 'printf "%s='"'%s'"'\n" '$_l8_var' "$'$_l8_var'"'
  done
]}[

# l8_fn_showargs
# --------------
# do --args
#
l8_fn_showargs() ]{[
  l8_fn_msg 1
  cat <<L8END
# actual script run:
#   $as_myself
cd '$l8_subject'; $l8_root/install-l8tf

# initialization
L8END
  set -- site_init l8_do_site_init subject_init l8_do_subject_init prev_init l8_do_prev_init
  while test $@%:@ -gt 0; do]
    AS_IF([[eval \$$2]],
[[    printf "  --%s\n" "$1"]],[[
      printf "  --no-%s\n" "$1"]])[
    shift
    shift
  done]
  AS_IF([[$l8_do_user_init]],
 [[  printf "  --user-init='%s'\n"  "$l8_user_init_file"]],[
[    printf "  --no-user-init\n"]])[

  cat <<L8END

@%:@ options to be saved
  --alltests='$l8_alltests_from_subject'
  --run='$l8_run_from_build'
  --subject-marker='$l8_subject_marker'
  --subject-test-ac='$l8_testing_ac'
  --specs='$l8_specs'
L8END]
  AS_IF([[$l8_do_distcopy]],
[[  printf "  --distcopy='%s'\n"  "$l8_distcopy_root"]],[[
    printf "  --no-distcopy\n"]])[
  printf '%s\n' '' '@%:@ other options'
  set -- autoconf l8_do_subj_autoconf configure-tests l8_do_tests_configure clobber l8_do_clobber recreate l8_do_recreate
  while test $@%:@ -gt 0; do]
    AS_IF([[eval \$$2]],
[[    printf "  --%s\n" "$1"]],[[
      printf "  --no-%s\n" "$1"]])[
    shift
    shift
  done]
  AS_IF([[$l8_do_diff]],
[[  printf "  --diff='%s'\n"  "$l8_diff_flags"]],[[
    printf "  --no-diff\n"]])
  AS_VAR_IF([[l8_test_configure_args]],[],[],[[cat <<L8END

@%:@ --configure-tests does
@%:@   cd $l8_alltests_from_subject ; ./configure $l8_test_configure_args
L8END
]])
}[

# l8_fn_try_create_file(CL_KWD FILE MTEXT)
# ---------------------
#  make sure FILE is creatable (by creating it;
#   l8_cleanup_CL_KWD is then set so that it goes away again,
#   l8_fn_cancel_cleanups will be needed to make it stick)
#  or updatable (first line must be MTEXT)
#
l8_fn_try_create_file () ]{[
  _l8_error=
  _l8_clkwd=$][1
  _l8_new=$][2
  _l8_mtext=$][3]

  AS_IF([[test ! -e "$_l8_new"]],
 [  AS_IF([AS_ECHO([["$_l8_mtext"]])[ >"$_l8_new"]],
[[    l8_fn_set_file_cleanup $_l8_clkwd "$_l8_new"]],[[
      _l8_error="file cannot be created"]])],
  dnl elif
[[test ! -f "$_l8_new"]],
[[  _l8_error="not an ordinary file"]],

[[test ! -r "$_l8_new"]],
[[  _l8_error="not readable"]],

[[_l8_ck=`sed -e '2,$d' "$_l8_new" 2>/dev/null`
         test x"$_l8_mtext" != x"$_l8_ck"]],
[[  _l8_error="file was not created by install-l8tf"]],

[[test ! -w "$_l8_new"]],
[[  _l8_error="not writable"]])

  AS_VAR_IF([[_l8_error]],[],[],[[
    l8_fn_fatal "$_l8_new:  $_l8_error"]])[
]}[

# l8_fn_try_create_dir(CL_KWD DIR MARKERFILE MTEXT)
# ---------------------------
#  make sure DIR is creatable (by creating it;
#   l8_cleanup_CL_KWD is then set so that it goes away again,
#   l8_fn_cancel_cleanups will be needed to make it stick)
#  or updatable (must contain MARKER file with first line MTEXT)
#
l8_fn_try_create_dir () ]{[
  _l8_error=
  _l8_clkwd=$][1
  _l8_new=$][2
  _l8_marker=$][3
  _l8_mtext=$][4]

  AS_IF([[test ! -e "$_l8_new"]],
 [  AS_IF(
        [AS_MKDIR_P([["$_l8_new"]])
[       test -d "$_l8_new"]],
    dnl then (mkdir)
[[    l8_fn_set_file_cleanup $_l8_clkwd "$_l8_new"]
      AS_ECHO([["$_l8_mtext"]]) >"$_l8_new/$_l8_marker"],
    dnl else (!mkdir)
[[
      _l8_error="directory cannot be created"]])],
  dnl elif
[[test ! -d "$_l8_new"]],
[[  _l8_error="not a directory"]],

[[test ! -r "$_l8_new"]],
[[  _l8_error="directory is not readable"]],

[[_l8_ck=`cat "$_l8_new/$_l8_marker" 2>/dev/null`
         test x"$_l8_mtext" != x"$_l8_ck"]],
[[  _l8_error="directory was not created by install-l8tf"]],

[[$l8_do_recreate]],
 [  AS_IF([[test ! -w "$_l8_new/.."]],
[[    _l8_error="parent directory is not writable"]])],

[[test ! -w "$_l8_new"]],
[[  _l8_error="directory is not writable"]])

  AS_VAR_IF([[_l8_error]],[],[],[[
    l8_fn_fatal "$_l8_new:  $_l8_error"]])
}[


## ----------------------------- ##
## Initial values for everything ##
## ----------------------------- ##

# Informational modes
l8_do_help=false
l8_do_version=false
l8_do_dryrun=false
l8_do_showargs=false

# --subject = source root
l8_subject_given=false
l8_subject=`pwd`
l8_subject_marker=Minimal.db

# --l8tf_root = L8TF repository directory
l8_root_given=false
l8_root=`dirname -- "$as_myself"`

# alltests directory
l8_alltests_given=false
l8_alltests_from_subject=tests
l8_alltests_marker=.l8tf_alltests
l8_alltests_mck='alltests directory created by install-l8tf'

# --distcopy = distcopy directory
l8_do_distcopy=false
l8_distcopy_root=   # leave blank, resolve later
l8_distcopy_marker=.l8tf_distcopy
l8_distcopy_mck='l8tf root directory copy created by install-l8tf'

# test run directory
l8_run_given=false
l8_run_from_build=t

## Subject-specific issues
l8_testing_ac='testing.ac'
l8_testing_ac_head='d''nl -- '"$l8_testing_ac"' -- generated by install-l8tf'
l8_specs='@R/ssmoo'
l8_specs_in_root=:

## Final actions
l8_do_subj_autoconf_given=false
l8_do_subj_autoconf=:
l8_do_tests_configure_given=false
l8_do_tests_configure=   # leave blank, resolve later
l8_test_configure_args=  # leave blank, resolve later

## Update options
l8_do_clobber=:
l8_do_diff=false
l8_diff_flags='-u'
l8_do_recreate=false

## Initialization
l8_do_site_init=:
l8_do_subject_init=:
l8_subject_init_file=.l8tf-install.conf
l8_do_prev_init=:
l8_prev_init_file=.l8tf-install.prev
l8_prev_init_head='@%:@ -- '"$l8_prev_init_file"' -- generated by install-l8tf'
l8_do_user_init=:
l8_user_init_file=   # leave blank, resolve later
]

## ------------------------------------ ##
## Parse command Line; validate options ##
## ------------------------------------ ##

#
# command line first pass
#   this does just the options labeled [first]

AS_CASE([[$@%:@]], [0], [], [[l8_fn_firstpass_cmdline "$@"]])

#
# --help
#
AS_IF([[$l8_do_help]],
[[l8_fn_do_help]
  AS_EXIT(0)])

#
# --version
#
AS_IF([[$l8_do_version]],
[[l8_fn_do_version]
  AS_EXIT(0)])

#
# If we are not already in the subject directory
# cd there and adjust $l8_root.
#
AS_IF([[$l8_subject_given]],
 [L8_REVERSE_PATH([[_l8_cur]], [[$l8_subject]])
  AS_SET_CATFILE([[l8_root]], [[$_l8_cur]], [[$l8_root]])
  [cd "$l8_subject" || l8_fn_fatal "could not cd to --subject ($l8_subject)"
  l8_fn_msg 1 "Entering subject directory '$l8_subject'"
  l8_fn_msg 1 "L8TF root is now '$l8_root'"
  l8_subject=`pwd`]])

#
# validate --subject
#
[_l8_subj_ckfile=]
AS_IF([[test ! -r configure.ac]],
[[l8_fn_fatal "$l8_subject:  configure.ac not found/readable"]],[[
  eval `autoconf '--trace=AC_CONFIG_SRCDIR:_l8_subj_ckfile="$1"' 2>/dev/null | grep _l8_subj_ckfile`]
  AS_VAR_IF([[_l8_subj_ckfile]], [],
[[  l8_fn_fatal "$l8_subject:  AC_CONFIG_SRCDIR(...) not found in configure.ac"]],[
    AS_IF([[test -e "$_l8_subj_ckfile"]],[],[[
      l8_fn_fatal "$l8_subject:  expected marker file '$_l8_subj_ckfile' not found"]])])])

#
# validate --l8tf-root
#
[cd "$l8_root" || l8_fn_fatal "could not cd to --l8tf-root ($l8_root)"]
AS_IF([[test -r "package_l8tf.m4" &&
    grep -q -E '\[L8TF_PACKAGE_NAME\], *\[L8TestFrame\]' package_l8tf.m4]],[],[[
  l8_fn_fatal "$l8_root:  not an L8TF directory (package_l8tf.m4 missing or weird)"]])

L8_REVERSE_PATH([[l8_root]], [[$l8_subject]])
[cd "$l8_subject"]

#
# Read the init files
#
AS_VAR_COPY([[_l8_cl_user_init_file]], [[l8_user_init_file]])
AS_VAR_COPY([[_l8_cl_do_user_init]],   [[l8_do_user_init]])

AS_IF([[$l8_do_site_init]],
  [[l8_fn_read_init_file site    "$l8_root/.l8tf-install.site"]])
AS_IF([[$l8_do_subject_init]],
  [[l8_fn_read_init_file subject "./$l8_subject_init_file"]])

AS_VAR_SET([[l8_do_distcopy]],[[false]])

AS_IF([[$l8_do_prev_init]],
  [[l8_fn_read_init_file prev    "./$l8_prev_init_file"]])

AS_VAR_COPY([[l8_do_user_init]], [[_l8_cl_do_user_init]])
AS_VAR_IF([[l8_user_init_file]], [],
  [AS_VAR_SET([[l8_user_init_file]], [[.l8tf-install.rc]])],[
  AS_VAR_IF([[_l8_cl_user_init_file]], [], [],[
    AS_VAR_COPY([[l8_user_init_file]], [[_l8_cl_user_init_file]])])])

# --user-init=~USER/FILE will not expand, so we need to do it manually
AS_CASE([[$l8_user_init_file]],[[~*/*]],
  [[_l8_rest=${l8_user_init_file@%:@~*/}
    _l8_user=${l8_user_init_file%"$_l8_rest"}
    eval _l8_user="$_l8_user"
    l8_user_init_file="$_l8_user$_l8_rest"]])

AS_IF([[$l8_do_user_init]],
  [AS_SET_CATFILE([[_l8_init]], [~], [[$l8_user_init_file]])[
  l8_fn_read_init_file user "$_l8_init"]])

#
# command line second (and last) pass
#   handle everything else (second pass may revert $l8_user_init_file
#   but that will not have been the value we used, so we need to
#   restore whatever rewrites we did)

AS_CASE([[$@%:@]], [0], [],
    [AS_VAR_COPY([[_l8_save_uif]],[[l8_user_init_file]])
    [l8_fn_parse_cmdline "$@"]
    AS_VAR_COPY([[l8_user_init_file]],[[_l8_save_uif]])])

#
# final steps of --subject validation
#   (that need to wait for all of the command line args)

AS_VAR_IF([[_l8_subj_ckfile]], [["$l8_subject_marker"]], [], [[
  l8_fn_fatal "$l8_subject:  marker file ($_l8_subj_ckfile) is not '$l8_subject_marker'"]])

AS_IF([[autoconf --trace='m4@&t@_include:$][1' --trace='m4@&t@_sinclude:$][1' 2>/dev/null | grep -q -F "$l8_testing_ac"]],[],
  [[l8_fn_fatal "configure.ac does not m4@&t@_s?include([$l8_testing_ac])"]])

#
# the remaining "leave blank, resolve later" situations
#

AS_VAR_IF([[l8_distcopy_root]],[],
  [AS_VAR_SET([[l8_distcopy_root]],[[$l8_alltests_from_subject/l8tf]])])

AS_VAR_IF([[l8_do_tests_configure]],[],
 [AS_IF([[$l8_do_distcopy]],
[[    l8_do_tests_configure=false]],
   [[ l8_do_tests_configure=:]])])

[check_rs_paths () ]{
  AS_VAR_COPY([[_l8_src]],[[$][1]])
  AS_CASE([[$_l8_src]],[[
    '']],[
      AS_VAR_IF([[2]],[],[[l8_fn_fatal "--${1@%:@l8_}='' not allowed"]])
      AS_VAR_COPY([[$1]],[[$2]])
      AS_VAR_COPY([[${1}_in_root]],[[${2}_in_root]])
      AS_VAR_COPY([[${1}_full]],   [[${2}_full]])],[[
  @R/*]],[
    AS_VAR_SET([[${1}_in_root]],[[:]])
    AS_VAR_SET([[${1}_full]],[["$l8_root/${_l8_src@%:@*/}"]])],[[
  @S/*]],[
    AS_VAR_SET([[${1}_in_root]],[[false]])
    AS_VAR_SET([[${1}_full]],[["${_l8_src@%:@*/}"]])],
  [[l8_fn_fatal "--${1@%:@l8_} path must begin with '@R/' or '@S/' ($_l8_src)"]])
}
check_rs_paths l8_specs

#
# flesh out subject<->root navigation
#

L8_REVERSE_PATH([[l8_subject_from_root]], [[$l8_root]])
AS_SET_CATFILE([[l8_abs_root]], [[$l8_subject]], [[$l8_root]])
AS_SET_CATFILE([[l8_alltests_from_root]], [[$l8_subject_from_root]], [[$l8_alltests_from_subject]])

#
# --args (now that we have resolved them all)
#

AS_IF([[test -r "$l8_alltests_from_subject/config.status"]],
[[l8_test_configure_args=`cd "$l8_alltests_from_subject" ; ./config.status --config`]])

AS_IF([[$l8_do_showargs]],
[[l8_fn_showargs]
  AS_IF([[$l8_do_dryrun]],[],[
    AS_EXIT(0)])])

## ---------------------- ##
##  Do all of the things  ##
## ---------------------- ##

#------------------------------------------------
# do trial creations
#
[l8_fn_add_cleanup alltests
l8_fn_try_create_dir       \
  alltests                 \
  "$l8_alltests_from_subject" \
  "$l8_alltests_marker"    \
  "$l8_alltests_mck"
]

[cd $l8_root]
L8_REVERSE_PATH([[l8_root_from_alltests]], [[$l8_alltests_from_root]])
[cd $l8_subject]
L8_REVERSE_PATH([[l8_subject_from_alltests]], [[$l8_alltests_from_subject]])

AS_IF([[$l8_do_distcopy]],
[[l8_fn_add_cleanup distcopy
  l8_fn_try_create_dir    \
    distcopy              \
    "$l8_distcopy_root"   \
    "$l8_distcopy_marker" \
    "$l8_distcopy_mck"]])[

l8_fn_add_cleanup previnit
l8_fn_try_create_file      \
   previnit                \
   "$l8_prev_init_file.sh" \
   "$l8_prev_init_head"

l8_fn_add_cleanup testac
l8_fn_try_create_file      \
   testac                  \
   "$l8_testing_ac"        \
   "$l8_testing_ac_head"

#------------------------------------------------
# write actual file content
#

l8_fn_put_header () ]{[
cat <<L8END
$2
$1 |             DO NOT EDIT             |
$1 \`-------------------------------------'
L8END
]}[

l8_fn_make_temp_dir "$l8_subject"
l8_fn_init_save "$l8_subject"]
AS_IF([[$l8_do_dryrun]],[[
  l8_do_finish_install=false
  l8_v_save_new=0
  l8_v_save_update=0]],[
dnl else
  [$l8_do_clobber || l8_v_save_update=0]])[

#
# (0) SUBJECT/.l8tf-install.prev.sh
#
l8_fn_next_save_file "$l8_prev_init_file.sh" previnit
l8_fn_put_header \@%:@ "$l8_prev_init_head" >"$l8_save_temp"
l8_fn_saved_args_to_sh >>"$l8_save_temp"
l8_fn_save

#
# (1) SUBJECT/testing.ac
#
l8_fn_next_save_file "$l8_testing_ac" testac
l8_fn_put_header 'd@&t@nl' "$l8_testing_ac_head" >"$l8_save_temp"
cat <<L8END >>"$l8_save_temp"
d@&t@nl
m4@&t@_include([$l8_alltests_from_subject/paths.m4])d@&t@nl
m4@&t@_include([$l8_root/subject_config.ac])d@&t@nl
L8END
l8_fn_save

#
# (2) ALLTESTS
#
l8_fn_next_save_file "$l8_alltests_from_subject" alltests
mkdir "$l8_save_temp"

]AS_ECHO([["$l8_alltests_mck"]])[ >"$l8_save_temp/$l8_alltests_marker"

# path.m4
#
cat <<L8END >>"$l8_save_temp/paths.m4"
m4@&t@_define([L8_PATH_ABS_SUBJECT],           [$l8_subject])d@&t@nl
m4@&t@_define([L8_PATH_ROOT_FROM_SUBJECT],     [$l8_root])d@&t@nl
m4@&t@_define([L8_PATH_ALLTESTS_FROM_SUBJECT], [$l8_alltests_from_subject])d@&t@nl
m4@&t@_define([L8_PATH_ROOT_FROM_ALLTESTS],    [$l8_root_from_alltests])d@&t@nl
m4@&t@_define([L8_PATH_BUILD_TO_TESTRUN],      [$l8_run_from_build])d@&t@nl
m4@&t@_define([L8_PATH_TESTING_AC],            [$l8_testing_ac])d@&t@nl
m4@&t@_define([L8_PATH_SSSPECS],               [$l8_specs_full])d@&t@nl
L8END

# Makefile
#
l8_fn_put_header \@%:@ "@%:@ generated from L8TF/alltests_Makefile.in by install-l8tf" >"$l8_save_temp/Makefile"
cat - $l8_root/alltests_Makefile.in <<L8END >>"$l8_save_temp/Makefile"

l8_abs_subject=$l8_subject
l8_abs_root=$l8_abs_root
l8_subject_from_alltests=$l8_subject_from_alltests
l8_alltests_from_subject=$l8_alltests_from_subject
l8_root_from_alltests=$l8_root_from_alltests
l8_alltests_from_root=$l8_alltests_from_root
l8_run_from_build=$l8_run_from_build

L8END

# configure, main_suite, t0
#
${MAKE-make} -s -C "$l8_save_temp" || l8_fn_fatal "make in $l8_alltests_from_subject FAILED"
mkdir "$l8_save_temp/t0"
l8_fn_save

#
# (3) DISTCOPY (TODO)
#

#------------------------------------------------
# finish install
#
cd $l8_subject]

AS_IF([[$l8_do_finish_install]], [],
 [AS_IF([[$l8_do_dryrun]],[AS_EXIT([0])],
[[  l8_fn_fatal "Aborted (--no-clobber)"]])])[

l8_fn_cancel_cleanups
l8_fn_commit_updates]

#------------------------------------------------
# run subject autoconf
#
AS_IF([[$l8_do_subj_autoconf_given]],[],[
  AS_VAR_IF([[l8_unchanged_testac]],[],[],[
    AS_IF([[test configure -nt "$l8_root/subject_config.ac" &&
       test configure -nt "$l8_alltests_from_subject/paths.m4"]],
[[    l8_do_subj_autoconf=false]])])])

AS_IF([[$l8_do_subj_autoconf]],
[[l8_fn_msg 0 "Running autoconf in $l8_subject"
  autoconf -f]])

#------------------------------------------------
# run alltests/configure
#
AS_IF([[$l8_do_tests_configure_given]],[],[
  AS_VAR_IF([[l8_unchanged_alltests_configure]],[],[],[[
    l8_do_tests_configure=false]])])

AS_IF([[$l8_do_tests_configure]],
[[cd $l8_alltests_from_subject
  l8_fn_msg 0 "Running ./configure $l8_test_configure_args in $l8_alltests_from_subject"
  ./configure $l8_test_configure_args]])
