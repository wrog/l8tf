m4_ifdef([L8_PATH_SUBJECT_FROM_ALLTESTS], [],
   [m4_fatal([missing:  L8_PATH_SUBJECT_FROM_ALLTESTS (need to prepend paths.m4)])])
m4_include([m4/ax_lp.m4])
m4_include([m4/l8_optarg.m4])
m4_include([m4/l8_revpath.m4])
m4_include([package_l8tf.m4])
m4_include([m4/l8_script.m4])
m4_include([m4/l8_expand_word.m4])

m4_include([runall-opt.m4])
# define L8_OPTION_HELP_LINES, RA_OPTION_CASES, RA_OPTION_CASES_FIRST
L8_OPT_USE([HELP],  [L8_OPTION_HELP_LINES], m4_defn([RUNALL_OPTS]))
L8_OPT_USE([SHELL], [RA_OPTION_CASES], m4_defn([RUNALL_OPTS]))
L8_OPT_USE([ARGS],  [RA_OPTION_ARGS],  m4_defn([RUNALL_OPTS]))

AS_INIT
AS_PREPARE
AS_COPYRIGHT(m4_defn([L8TF_COPYRIGHT]))

## --------- ##
## Functions ##
## --------- ##

L8_SCRIPT_PREAMBLE()

L8_OPT_CMDLINE_PARSE_FN([[l8_fn_firstpass_cmdline]],
  [do [first]ed command line arguments],
  [RA_OPTION_CASES_FIRST])

L8_OPT_CMDLINE_PARSE_FN([[l8_fn_parse_cmdline]],
  [parse command line arguments (skip [first]ed ones)],
  [RA_OPTION_CASES]dnl
[[    l8_fn_usage "unrecognized option:  '$1'"
       ]])[


## ----------------------------- ##
## Initial values for everything ##
## ----------------------------- ##

# Informational modes
l8_do_help=false
l8_do_version=false

# alltests directory
l8_alltests=`dirname -- "$as_myself"`

# build root directory
l8_build_given=false
l8_build=b
l8_alltests_from_build=..

# subject directory
l8_subject_from_alltests=]m4_defn([L8_PATH_SUBJECT_FROM_ALLTESTS])[
l8_subject=`cd $l8_alltests; cd $l8_subject_from_alltests; pwd` ||
  l8_fn_fatal "could not cd to $l8_alltests then $l8_subject_from_alltests"]

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

# If we are not already in the alltests directory
# cd there and ensure $l8_build is relative to alltests
#
L8_REVERSE_PATH([[_l8_cur]], [[$l8_alltests]]) ||
  l8_fn_fatal "could not cd to --alltests ($l8_alltests)"
AS_IF([[$l8_build_given]],
 [AS_SET_CATFILE([[l8_build]], [[$_l8_cur]], [[$l8_build]])])

cd "$l8_alltests"
l8_fn_msg 1 "Entering alltests directory '$l8_alltests'"
l8_fn_msg 1 "Build root is '$l8_build'"
l8_alltests=`pwd`


## ---------------------- ##
##  Do all of the things  ##
## ---------------------- ##

# cd alltests if we are not there already
# digest the recipe
#if edit mode
#   save the start file
#elif cout mode
#   count configs, do time estimate
#else run mode
#   make sure runall directory exists
AS_IF([[test -d $l8_build]],[],
  [AS_MKDIR_P([[$l8_build]]) || [
     l8_fn_fatal "could not create --build ($l8_build)"]])
AS_IF([[$l8_build_given]],
  [L8_REVERSE_PATH([[l8_alltests_from_build]], [[$l8_build]])])[

cd $l8_subject]
AS_SET_CATFILE([[_l8_bs]],[[$l8_alltests]],[[$l8_build]])
L8_REVERSE_PATH([[l8_subject_from_build]],[[$_l8_bs]])[

cd $l8_alltests

l8_fn_msg 1 "alltests_from_build: '$l8_alltests_from_build'"
l8_fn_msg 1 "subject_from_build: '$l8_subject_from_build'"
]

#   cd there
#   run the recipe
