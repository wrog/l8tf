# package.m4
#
#  Test Suite version
#
m4_include([package_l8tf.m4])
#
#  LambdaMOO version
#
# Autotools people want these values set early as M4 macros.
# In some cases this is easy:
#
m4_define([AT_PACKAGE_NAME],[LambdaMOO])
m4_define([AT_PACKAGE_TARNAME],m4_defn([AT_PACKAGE_NAME]))
m4_define([AT_PACKAGE_BUGREPORT],m4_defn([L8TF_PACKAGE_BUGREPORT]))
m4_define([AT_PACKAGE_URL],m4_defn([L8TF_PACKAGE_URL]))

# AT_PACKAGE_VERSION is a problem: The test suite builds (m4-expands
# -- recall: target platform may not actually *have* autotools) --
# before ./configure runs on the subject source, and so there is no
# version.lastck yet.
#
# But, by the time the test suite runs, version.lastck *must* exist
# because ./config.status creates the test run directory.
#
# Also, all places where the AT_PACKAGE_* macros are used are places
# where shell variables get expanded.  So this

m4_define([AT_PACKAGE_VERSION],[$PACKAGE_VERSION])
m4_define([AT_PACKAGE_STRING],[$PACKAGE_STRING])

# works if we set the variables in time.  Normal places to do this are
# atlocal or atconfig, but those get sourced **way** too late in the
# process, (diversion) TESTS_BEGIN, whereas the AT_PACKAGE_* are
# needed in HELP_END and VERSION (see autotest/general.m4).
#
# Earlier diversions exist.  But, a -C/--directory command line arg
# can change the test run directory, changing where we need to look
# for version.lastck, so we have to wait until after PARSE_ARGS_END.
#
# Also package.m4 is included/expanded before AT_INIT, meaning what we
# do shows up at the *beginning* of whichever diversion we use.
#
# HELP is thus the earliest diversion we can use.
# HELP_END is the latest if this code stays here; otherwise
# HELP_OTHER if we move it after AT_INIT.
# Here, any -C has been is accounted for and $at_dir is set (even if
# the cd has not yet happened).  version.lastck is in the top build
# directory for which we must use $at_dir/.. since the *top_build_*
# shell vars are not set until atconfig (TESTS_BEGIN).

m4_divert_push([HELP])
#--------------------
# set dynamic PACKAGE_* variables from version.lastck (config.status)
#
AS_SET_CATFILE([_l8tf_version_lastck],[$at_dir],[../version.lastck])
AS_IF([[test -r "$_l8tf_version_lastck"]],
[[moo_no_write=:
  . "$_l8tf_version_lastck"]
  AS_VAR_IF([[moo_COMMIT]],[],[[
    moo_COMMIT=`expr "$moo_DEFSRC" : '.*DEF(commit,"\([^"]*\)")'`]])[
  PACKAGE_VERSION=$moo_MAJOR.$moo_MINOR.$moo_RELEASE$moo_EXT]],
[[PACKAGE_VERSION="x.x.x ($][0 outside test directory?  use -C)"]])
[PACKAGE_STRING="]AT_PACKAGE_NAME[ $PACKAGE_VERSION (]L8TF_PACKAGE_NAME L8TF_PACKAGE_VERSION[)"]

#--------------------
m4_divert_pop([HELP])
#
# back to m4_divert([KILL])
