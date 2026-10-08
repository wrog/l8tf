# runall-opt.m4 -- Options for runall
# =================================================
m4_define([RUNALL_OPTS],[

L8_OPT_DECLARE([HEADER])([`runall` Reference])([
The `runall` script performs a particular _schedule_ of
individual configuration builds and test runs.
```
   runall [_SCHEDULE_ARGS_...]
```
It can also be used to define schedule names
for use in subsequent runs and also remove them
```
   runall --define NAME [_SCHEDULE_ARGS_...]
   runall --remove NAME
```
It also runs _ALLTESTS_`/configure` if needed prior to
any actual test run.

As for _SUBJECT_`/configure`, not only is there no need
to run that in advance, but, since every build this does
is a VPATH build, it is actually an error for the _SUBJECT_
directory to contain the `Makefile` that would be created.
Use [`--distclean`](@%:@user-content??) to undo that.
])

# ============================================================

L8_OPT_DECLARE([SECTION])([General options])([
Options that are nearly always applicable:
])

# -----------------
#  -v|+v|-(-no)-verbose(=N)
#
L8_OPT_DECLARE([ZVALUE],[first])(  [v],[verbose],[[<level>]],
  [be extra chatty], [no],
  [[l8_verbosity]])([
shows additional information, as appropriate.
Higher level numbers may give you more.  Or not, depending.

The default level is 0 (same as ``--no-verbose``).
``-v`` or ``--verbose`` gives you level 1.
Use ``--verbose=``_LEVEL_ for any higher level.
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Informational modes])([
These all run to display some information without actually doing anything:
])

# -----------------
#  -h|+h|-?|--help
#
L8_OPT_DECLARE([INFOBOOLEAN],[first],[mode([help])])(  [h], [help],
  [show this text and exit],[?],
  [[l8_do_help=:]])([
shows help text and exits.
])

# -----------------
#  -V|+V|--version
#
L8_OPT_DECLARE([INFOBOOLEAN],[first],[mode([version])])(  [V], [version],
  [show version info and exit],[],
  [[l8_do_version=:]])([
shows version information and exits.
])

# -----------------
#  --about
#
L8_OPT_DECLARE([ACTION],[first],[mode([version])])(  [], [about],
  [show detailed version info and exit],
      [[l8_do_version=:
        l8_verbosity=99]])([
shows the "about" box and exits.  This is equivalent to
`--version --verbose=`_MAXIMUM_, with biographies of the
developers and everything (well okay, maybe not that much).
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Directory path options])([
These specify the various directories that `runall` creates
or needs to reference.
])

# ------------------------
#  ---build=<path>
#
L8_OPT_DECLARE([VALUE],[first],[given([[l8_build_given]])])(  [], [build], [[<path>]],
  [root build directory], [$l8_alltests/$l8_build],
  [[l8_build]])([
path (relative to the current directory) to the build root directory where the test builds should take place.
])

])
