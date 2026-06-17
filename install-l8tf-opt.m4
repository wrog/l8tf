# install-l8tf-opt.m4 -- Options for install-l8tf
# =================================================
m4_define([INSTALL_L8TF_OPTS],[

L8_OPT_DECLARE([HEADER])([`install-l8tf` Reference])([
The `install-l8tf` script installs the L8TF testing regime
into a source directory, `SUBJECT`.  This creates a subdirectory,
`ALLTESTS`, with the files necessary for running tests, and
an autoconf hook file for `configure.ac` to include so that
the eventual `configure` script run will create within the
build directory a test run directory with suitable make targets.

The two most common invocations will be

1.  to modify a developer
    environment for `SUBJECT` to include tests:
    ```
      cd SUBJECT
      ./path/to/L8TF/install-l8tf
    ```
    or

2.  to add tests to `DISTRIB`, a source distribution under construction.
    In this case, scenario data and additional sources need to be copied
    in so as not to require that L8TF be available on the target host,
    hence the need for an extra option:
    ```
      cd DISTRIB
      ./path/to/L8TF/install-l8tf --distcopy
    ```
Subsequent runs of `install-l8tf` without arguments on the same subject
directory update the test files as needed if the L8TF sources have changed.
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

# -----------------
#  --args
#
L8_OPT_DECLARE([INFOBOOLEAN],[first],[mode([showargs])])(  [], [args],
  [show arguments and exit],[],
  [[l8_do_showargs=:]])([
displays all options currently in effect and then exits
immediately (unless `--dry-run` is also given), showing
how the various unmentioned options are being resolved/defaulted.
])

# -----------------
#  -n|+n|--dry-run
#
L8_OPT_DECLARE([INFOBOOLEAN],[first],[mode([dryrun])])(  [n], [dry-run],
  [validate command line and exit],[],
  [[l8_do_dryrun=:]])([
does as much validation of the given command line as possible,
including checking that it is possible to create necessary new
directories and files, without actually making changes (aside
from directory access/modification times, which will inevitably
get bumped).  This can be combined with `--args`.
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Directory path options])([
These specify the various directories that `install-l8tf` creates
or needs to reference.
])

# ------------------------
#  ---subject=<path>
#
L8_OPT_DECLARE([VALUE],[first],[given([[l8_subject_given]])])(  [], [subject], [[<path>]],
  [subject directory], [.],
  [[l8_subject]])([
path to `SUBJECT`, the top-level/root directory of the subject source
tree, either a repository root or a distribution — whether under
construction or already unpacked somewhere, — this being the source
directory in need of a test suite or updates thereto.

This defaults to the current directory, i.e., one is normally expected
to have cd'ed there before running this script, but this allows
running `install-l8tf` from some other directory.

Providing an explicit `--subject=SUBJECT` effectively first does `cd SUBJECT`,
then adjusts as needed any provided [--l8tf-root](@%:@user-content---l8tf-rootpath)
— the only other option for which the current directory can be relevant, —
and then continues from there.

Since `install-l8tf` does rather a lot of `rm -rf` and `mv -f` and
thus can potentially do significant damage if run in the wrong directory,
there are precautions:

* `SUBJECT` must have a `configure.ac` file at the top level, which, in turn
  + must have an `AC_CONFIG_SRCDIR` directive that
    - names a marker file that actually exists
      (the `configure` script would fail otherwise), and
    - the marker file name, see [--subject-marker](@%:@user-content---subject-markerfilename),
      must be the one we are expecting;
  + must reference the `.ac` file that `install-l8tf` has been specifed to create;
    see [--subject-test-ac](@%:@user-content---subject-test-acpath),

`install-l8tf` will abort if any of these conditions fails.
])

# ------------------------
#  ---l8tf-root=<path>
#
L8_OPT_DECLARE([VALUE],[first],[given([[l8_root_given]])])(  [], [l8tf-root], [[<path>]],
  [L8TF repository], [$l8_root],
  [[l8_root]])([
path to `L8TF`, the top-level/root testing-sources directory — whether
a repository or an unpacked stand-alone distribution thereof — that
this installation/update is to be done _from_.  Relative paths are
taken as being from the current directory.

By default, `L8TF` is inferred from the execution path of `install-l8tf`
itself.  That is, since this script is supposed to be located at the
top-level of some viable `L8TF` instance, the simple fact of it having
been found and successfully executed ought to validate that directory
as indeed being a proper L8TF repository/source directory.

Explicit use of this option should thus only be necessary if

* inferring `L8TF` from the execution path does not work for some
  reason (e.g., stupid symbolic link games, or the script is somehow
  being run with `$0` obfuscated), or

* you want to use _this_ `install-l8tf` script, but have it pretend
  to be living in some _other_ testing-sources directory, at which
  point we have no choice but to assume you know what you are doing,
  even if this is not likely to end well.

`install-l8tf` checks whether particular files that this version of
the script depends on exist in the purported `L8TF` tree  and,
to protect against unexpected `$0`-obfuscation or typos in the
`--l8tf-root` argument, aborts if they are not found.
])

# ------------------------
#  ---alltests=<path>
#
L8_OPT_DECLARE([VALUE],[save],[given([[l8_alltests_given]])])(  [], [alltests], [[<path>]],
  [alltests (scripts) directory], [tests],
  [[l8_alltests_from_subject]])([
path to `ALLTESTS`, the directory where (pre-target-platform-configure
versions of) test suite shell scripts, the test run directory template,
and the `runall` script for testing multiple configurations at once
are to be installed.

This pathname is absolute or relative to `SUBJECT`.
It is created if it does not yet exist.

Default value is `tests`.

Having `ALLTESTS` be located ouside of the `SUBJECT` tree _could_ work,
but could also cause confusion since its content is intended to be
specific to a given subject source tree.

`install-l8tf` will abort if the specified directory already exists
and does __not__ contain the marker file indicating it was previously
created by `install-l8tf` on this subjest.

An existing directory with the requisite marker file will, by default,
have its files overwritten each time `install-l8tf` runs (meaning if
you edit files in this directory you should not expect your edits to
survive.  To change how a given test works, edit its source (in `L8TF`)
and let the makefiles do their thing.)

But see also [--recreate](@%:@user-content---recreate-vs---no-recreate) and [--no-clobber](@%:@user-content---clobber-vs---no-clobber)
for alternative behaviors.
])

# --------------------------------
#  -(-no)-distcopy=<path>
#
L8_OPT_DECLARE([NEGVALUEOPT],[save])(  [], [distcopy], [[<path>]],
  [copy test sources to subject tree], [no],
  [[l8_do_distcopy]], [[l8_distcopy_root]])([
whether to install/update, within `SUBJECT` or `ALLTESTS`, copies of
those testing source auxiliary and scenario data files needed for
running tests, optionally specifying where to do so.

This option is for preparing a distribution to be unpacked on a host
where the L8TF repository is not normally expected to be available,
so we create a skeletal copy of `L8TF`.

`--distcopy` by itself indicates that the default location within
`ALLTESTS` is good enough.

To specify a location explicitly, use `--distcopy=`_path_, with
pathname relative to `SUBJECT`.

> [!WARNING]
>
> Specifying a location that is within `ALLTESTS` but different
> from the default is not recommended since you may inadvertantly
> overwrite something that matters, and even if you are sure that
> will not be the case for the current version of L8TF, future
> versions may change the layout of `ALLTESTS`.

The default, `--no-distcopy`, indicates that no such copies are needed
and that test scripts will reference `L8TF` itself directly, which is
likely what you want for a development environment.

When appearing in a [startup file](@%:@user-content-initialization-files),
`--distcopy=` will __only__ set the default location, leaving in place
the default behavior of _not_ creating a skeletal `L8TF`.
])

# ------------------------
#  ---run=<path>
#
L8_OPT_DECLARE([VALUE],[save],[given([[l8_run_given]])])(  [], [run], [[<path>]],
  [test run directory], [t],
  [[l8_run_from_build]])([
specifies the test run directory, i.e., the subdirectory of the build
directory where the test suites will be run, where individual test-run
logs and error-output files will show up (see GNU autotest docs for
everything this gets used for).

This path must be relative and strictly downward, i.e., the test
run directory must have the root build directory as an ancestor
(due to VPATH builds, the build directory can be __anywhere__).
There is also unlikely to be any point to giving it multiple
components (i.e., making it a grandchild or deeper).

The default test run directory name is `t`.
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Subject-specific issues])([
In order that this framework can actually be used on a particular
subject tree, there are a number of subject-specific matters that
need to be specified, having to do with

*  content of `SUBJECT/configure.ac` (which we use to recognize
   a subject directory and which needs to include a hook file
   that `install-l8tf` can write),

*  unit test source files, which will inherently be subject-specific,
   need to be findable and distinguishable from the regular
   source files,

*  configuration nomenclature, i.e., how we translate between
   lists of `configure` arguments and the configuration names
   to be used by `runall`

*  definitions for the test schedule keywords (`smoke`, etc...)

   _(this list will likely get expanded)_

Currently, these all default to what they need to be for the
LambdaMOO C server source, though the [--subject-init file](@%:@user-content---subject-init-vs---no-subject-init)
provides a means for subject authors to have their own defaults.
])

# ------------------------
#  --subject-test-ac=<path>
#
L8_OPT_DECLARE([VALUE],[save])(  [], [subject-test-ac], [[<path>]],
  [hook for configure.ac], [testing.ac],
  [[l8_testing_ac]])([
name for a `.ac` file that is `m4_[s]include()ed` by
`SUBJECT/configure.ac`, preferably immediately before the
final `AC_OUTPUT` directive, in order to define how to
build and populate the test run directory

This defaults to `testing.ac`

`install-l8tf` writes this file but will abort if the file already
exists and does __not__ contain the magic string indicating it was
written by a previous run of `install-l8tf`.

See also [--no-clobber](@%:@user-content---clobber-vs---no-clobber).

`install-l8tf` will also abort if `SUBJECT/configure.ac` does not
appear to reference this file at all (an `autoconf --trace` is performed).
])

# ------------------------
#  ---subject-marker=<filename>
#
L8_OPT_DECLARE([VALUE],[save])(  [], [subject-marker], [[<filename>]],
  [expected subject marker file], [Minimal.db],
  [[l8_subject_marker]])([
Name of marker file expected to be present in the subject directory
as named by the `AC_CONFIG_SRCDIR` declaration in `SUBJECT/configure.ac`.

`install-l8tf` will abort if the marker filename declared is not
the one we were expecting.

The default here is `Minimal.db` which identifies the LambdaMOO
C language server source.
])

# ------------------------
#  ---specs=<path>
#
L8_OPT_DECLARE([VALUE],[save])(  [], [specs], [[<path>]],
  [subject specifications directory], [@R/ssmoo],
  [[l8_specs]])([
path to where the subject specification files can be found.
The default is `@R/ssmoo`.

This directory is expected to include
|                |                                  |
|---------------:|:---------------------------------|
|    `cfname.m4` | the configuration naming scheme  |
| `schedules.sh` | available schedules for `runall` |

The pathname must begin with either `@R` or `@S`, according as you
want the remaining path to be relative to the `L8TF` root or `SUBJECT`.
In the former case this directory will be included in any [--distcopy](@%:@user-content---distcopypath-vs---no-distcopy).
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Final actions])([
Once the various files have been created, there are two optional
final actions that may be taken.
])

# ------------------------
#  -(-no)-autoconf
#
L8_OPT_DECLARE([BOOLEAN],[given([[l8_do_subj_autoconf_given]])])([],[autoconf],
  [run autoconf in subject],[yes],
  [[l8_do_subj_autoconf]])([
whether or not to run `autoconf` to regenerate `SUBJECT/configure`.
this happens after all other file creation/updating.  The default is to
do this unless the [--subject-test-ac](@%:@user-content---subject-test-acpath) file already exists and
the files it includes are older than `SUBJECT/configure`.

Use `--no-autoconf` to skip this step, though there is hardly
ever any reason to.

(Note that this has nothing to do with the `ALLTESTS/configure`
script which is _always_ created/updated by `install-l8tf`.
See [--configure-tests](@%:@user-content---configure-tests-vs---no-configure-tests) for that)
])

# ------------------------
#  -(-no)-configure-tests
#
L8_OPT_DECLARE([BOOLEAN],[given([[l8_do_tests_configure_given]])])([],[configure-tests],
  [run tests/configure],[no],
  [[l8_do_tests_configure]])([
whether or not to run `ALLTESTS/configure`.

The `configure` script in `ALLTESTS`, the one that chooses testing tools
and creates/updates the test run directory templates, normally does
not need to run very often.  Typically this only matters if available
system tools or test tool requirements have changed (e.g., an
alternative `netcat` becomes available after an OS update or a new test
requires a completely new tool).

This is the only script `install-l8tf` invokes that depends on the
target environment; the ability to have `install-l8tf` run this script
is mainly a convenience.

Both `SUBJECT/configure` and `ALLTESTS/runall` already ensure that
`ALLTESTS/configure` has been run __at all__, but there is no way to
know whether it needs to be run _again_ without actually running it.
However, invoking it on _every_ individual test suite run may be
rather expensive.

Running it on `install-l8tf` updates is infrequent enough to be the
Right Thing, at least if this is a development host.

Running it on a distribution under construction is very much __not__ the
Right Thing (`configure` scripts exist to determine the characteristics
of the target/build host, so packaging the results of a `configure` run
on the development host makes no sense.)

Therefore, the default behavior is to run `ALLTESTS/configure` if and
only if this is a `--no-distcopy` run.  If that is not what you want,
that's what this option is for.

Also, you can always manually `cd ALLTESTS; ./configure` whenever you like.
])

# ============================================================

L8_OPT_DECLARE([SECTION])([Update options])([
Re-running `install-l8tf` updates the files it created the
first time.  These options control how updates work.])

# --------------------------------
#  -(-no)-clobber
#
L8_OPT_DECLARE([BOOLEAN])([],[clobber],
  [allow file updates],[yes],
  [[l8_do_clobber]])([
The default behavior (`--clobber`) is that files highly likely to have
been created by prior runs of `install-l8tf` will be silently overwritten
as needed.  Here, "highly likely" refers to

* files under `ALLTESTS` if that directory has the expected marker, or
* the `--subject-test-ac` file and the --prev-init startup file if
  they contain the requisite magic strings.

If you consider this to be insufficiently paranoid, `--no-clobber`
will, __if__ there exist files needing to be changed, cause
`install-l8tf` to abort and list those files, at which point
you can decide what you care about, then remove or otherwise
shuffle files manually as you see fit, or just reissue the
command without `--no-clobber`

(or with `--clobber`, if you made `--no-clobber` the default
by putting it in your user startup file, see [`--user-init=`](@%:@user-content---user-initpath-vs---no-user-init))

Note that `--no-clobber` will not prevent __new__ files
from being created.

See also [--dry-run](@%:@user-content---dry-run--n).
])

# --------------------------------
#  -(-no)-diff=flags
#
L8_OPT_DECLARE([NEGVALUEOPT])(  [], [diff], [[<flags>]],
  [show differences in updated files], [no],
  [[l8_do_diff]], [[l8_diff_flags]])([
whether to show differences in files being updated and, if so,
which flags to use.

> [!TIP]
>
> The `--diff=`_FLAGS_ argument needs to be read as a single
> word but then the _FLAGS_ portion will get path-expanded and
> whitespace-separated.  Make sure you understand shell quoting.
])

# --------------------------------
#  -(-no)-recreate
#
L8_OPT_DECLARE([BOOLEAN])([],[recreate],
  [delete prior alltests directory],[no],
  [[l8_do_recreate]])([

The default behavior of `install-l8tf` in the case of `ALLTESTS`
or the directory created by [--distcopy](@%:@user-content---distcopypath-vs---no-distcopy),
where either or both of those directories previously existed,
is to update in place those files it knows about and ignore
everything else.  Theoretically, this should suffice since test
scripts should not be referencing any other files.

But there are remotely possible situations where simply having
unexpected files exist (e.g., obsolete files left behind by prior
versions of L8TF or random files that you yourself added for reasons
of your own) causes unexpected behavior.

With `--recreate`, any previously created `ALLTESTS` directory (i.e., that
has the requisite marker file) is __entirely removed__ and a new one is
built from scratch.

`--recreate` overrides `--no-clobber` for files within `ALLTESTS`,
but the latter still applies to other files that can be modified
(i.e., specifying both can still make sense in some situations).])

# ============================================================

L8_OPT_DECLARE([SECTION])([Initialization files])([
This is about the files that `install-l8tf` reads at startup.

The content of each of these files is a sequence of command line
arguments for `install-l8tf`, but newlines can be arbitrarily
added to make the file more readable by putting each option on
its own line.  Also, a `@%:@` appearing either at the beginning of a
line or preceded by whitespace is treated as the start of a comment
and everything from there to the end of the line is ignored.

1. `L8TF/.l8tf-install.site` is for package maintainers, if,
   say, an OS distribution has rules about where user personal
   preference files should go.

2. `SUBJECT/.l8tf-install.conf` is for subject authors to
   configure/customize aspects of how tests are installed on
   this particular subject.

3. `SUBJECT/.l8tf-install.prev` records the "sticky" arguments
   used for the most recent successful installation of tests
   on this subject (which then become the default for updates)

4. the user preferences file, `~/.l8tf-install.rc` usually,
   but this can be changed by [`--user-init=`](@%:@user-content---user-initpath-vs---no-user-init)
   in one of the previous files.

Certain options behave differently when they appear in a startup file.

`--subject`, `--l8tf-root` and any options that change the mode
`install-l8tf` runs in (e.g., `--help`, `--version`, or `--dry-run`)
are ignored in startup files.

`--distcopy=` and `--user-init=` in a startup file will __only__
specify a default name for the directory or file to use/create;
whether the corresponding action happens depends on the command line only.

The following options customize how initialization works:
])

# --------------------------------
#  --no-init
#
L8_OPT_DECLARE([ACTION],[first],[mode([version])])(  [], [no-init],
  [do not read any init files],
      [[l8_do_site_init=false
        l8_do_subject_init=false
        l8_do_prev_init=false
        l8_do_user_init=false]])([
disables all reading of startup files.  This is equivalent to
specifying all of `--no-site-init`, `--no-subject-init`, `--no-prev-init`,
and `--no-user-init`

Any of the corresponding non-negated options can appear later in the
command line to restore reading of particular startup files as desired.
])

# --------------------------------
#  -(-no)-site-init
#
L8_OPT_DECLARE([BOOLEAN],[first])( [], [site-init],
  [read site's init file], [yes],
  [[l8_do_site_init]])([
whether to read `L8TF/.l8tf-install.site` on startup.
])

# --------------------------------
#  -(-no)-subject-init
#
L8_OPT_DECLARE([BOOLEAN],[first])( [], [subject-init],
  [read subject's init file], [yes],
  [[l8_do_subject_init]])([
whether to read `SUBJECT/.l8tf-install.conf` on startup.
])

# --------------------------------
#  -(-no)-prev-init
#
L8_OPT_DECLARE([BOOLEAN],[first])( [], [prev-init],
  [read previous settings (for update)], [yes],
  [[l8_do_prev_init]])([
whether to read `SUBJECT/.l8tf-install.prev` on startup.
])

# --------------------------------
#  -(-no)-user-init=<path>
#
L8_OPT_DECLARE([NEGVALUEOPT],[first([1])])(  [], [user-init], [[<path>]],
  [read user's init file], [yes],
  [[l8_do_user_init]], [[l8_user_init_file]])([
whether to read the user preferences file on startup.

To explicitly specify the location of this file, use `--user-init=`_path_,
where the pathname is relative to the user's home directory.

When appearing in a [startup file](@%:@user-content-initialization-files), `--user-init=` will __only__ set the
default location; any `--no-user-init` on the command line will take precedence.

The default location is `~/.l8tf-install.rc` unless this is modified
elsewhere (e.g., in `L8TF/.l8tf-install.site`).
])])
