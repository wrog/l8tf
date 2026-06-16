# L8TF (LambdaMOO Test Frame)

*  [About L8TF](#user-content-about-l8tf)
*  [Getting Started](#user-content-getting-started)
   +  ["Getting Started"](#user-content-getting-started-1)
   +  [Actually Getting Started...](#user-content-actually-getting-started-with-a-particular-subject)
*  [Files and Directories Reserved by L8TF](#user-content-files-and-directories-reserved-by-l8tf):
   +  [The `ALLTESTS` directory (`SUBJECT/tests/`)](#user-content-the-alltests-directory-subjecttests)
   +  [The test run directory (`BUILD/t/`)](#user-content-the-test-run-directory-buildt)
   +  [The Unit Test filename prefix (`uT-*`)](#user-content-the-unit-test-filename-prefix-ut-)
   +  [The autoconf hook file (`SUBJECT/testing.ac`)](#user-content-the-autoconf-hook-file-subjecttestingac)
   +  [The `DISTCOPY` directory](#user-content-the-distcopy-directory)
   +  [The startup filename prefix (`.l8tf-install.*`)](#user-content-the-startup-filename-prefix-l8tf-install)
*   [Configuring Tests Manually](#user-content-configuring-tests-manually)
*   [How to Run Tests Directly](#user-content-how-to-run-tests-directly)
*   [Unit Testing](#user-content-unit-testing)
*   [Disabling Testing](#user-content-disabling-testing)
*   [Creating new tests](#user-content-creating-new-tests)
*   [Adapting L8TF to other version/forks of LambdaMOO](#user-content-adapting-l8tf-to-other-versionforks-of-lambdamoo)

## About L8TF

This is a framework for testing builds of the LambdaMOO server.
It provides

*  (install-l8tf)
   A script to set up a source repository or distribution
   to make it possible to run tests

*  (main_suite)
   A general test suite that exercises a particular build.

*  (runall)
   A script to run some or all available test suites over a
  'schedule' of configurations

It also provides some components specific to the LambdaMOO server

*  A nomenclature for the different possible configurations
   (i.e., choices of extensions and `options.h` settings)

*  (unit_suite)
   A unit-test suite that exercises internal server APIs.

The overall goal is to provide a means of incorporating a variety of
useful `make test*` targets into a server distribution that previously
lacked them, and thence be able to set up Continuous Integration testing.

This is a _separate_ framework.  It is its own source tree with its
own history, because

*  there are advantages to being able to apply the same test suites
   to different server development branches (cf. the many
   situations where you do _not_ want reverting or checking out a
   different branch of the server to be changing the tests)
   and perhaps even different server forks.

*  the git-submodule vs. git-subtree argument was going nowhere.

## Getting Started

You will need to have the following

*  `git`
*  GNU `autoconf` (2.68+), including `autom4te`, `m4sh`, and `autotest`

The steps are

    git clone L8TF_REPOSITORY L8TF_ROOT
    make -C L8TF_ROOT

The 2nd step creates certain shell scripts and documentation files.
It is optional in that the shell scripts will get remade automatically
if you neglect to do this, but you may as well, and also the extra
docs will be useful.

_(I have thought about adding a routine to test the test suite,
but we're not quite there yet.)_

As of this writing (July. 2026), `L8TF_REPOSITORY` is

   [https://github.com/wrog/l8tf.git](https://github.com/wrog/l8tf)

One intent of the design is that a single `l8tf` instance be able to
serve multiple subject repository instances ("subjects" being the
entities to be tested), so the actual location that you have cloned to
should not matter beyond having a directory path that is easy to type.

### "Getting Started"

The goal is to be able to do, from a freshly unpacked server distribution, either of

1.  Single-instance build:
    ```
    ./configure [_OPTIONS_]
     make
     make test
    ```
    to compile a server executable in some chosen configuration and have
    some basic confidence that it will function correctly.  Historically
    (for LambdaMOO, at least), it's that last line that has not actually
    existed.

2.  General testing:
    ```
    ./tests/runall [--unit] [--main] [_SCHEDULE_]
    ```
    to conduct a sequence of build tests on some selected _SCHEDULE_ of
    configurations, whether as a basic viability test, or a check-in test
    or a comprehensive test of some feature.

    which can be done _without_ having previously done a `./configure`
    (and, in fact, since it performs a variety of VPATH builds, it needs
    the source directory to remain prestine),

    Here, _SCHEDULE_ will normally be an identifier, but could also be
    a collection of arguments describing a specialized custom testing
    schedule.

This being about the __goal__ for this project, is _not_ actually
what you need for

### Actually Getting Started with a particular subject

Let `SUBJECT` be the LambdaMOO server source worktree to be tested.
One can then install tests:

    cd SUBJECT
    ./path/to/L8TF_ROOT/install-l8tf

For stock LambdaMOO, version 1.9.0 or newer, where the various hooks
this `install-l8tf` script needs will already be in place, this
much should suffice.

Repeating this later on will update the files installed the first time.

Note that `install-l8tf`, by default, (re-)runs `autoconf` at the
end of the installation process.  In some circumstances, it also runs
`ALLTESTS/configure` (a script for configuring the test).

For a complete description and the full range of options available,
see [The install-l8tf Reference](./Install_L8TF.md).

> [!TIP]
>
> The easiest setup is to have `SUBJECT` and `L8TF_ROOT` be siblings
> of a common parent.  This is not required, but, for now, with `l8tf`
> only being applicable to the one subject, you're probably setting up
> both at once, so you may as well be doing this.
>
> (A more-traditional format, in which `L8TF_ROOT` is a subdirectory
> of `SUBJECT`, is undoubtedly do-able but introduces unnecessary
> complications, e.g., you would then be having to learn about
> `.git/info/exclude` to keep the two `git` instances from
> interfering with each other.
>
> For extra pain in your life, you could also imagine making
> `L8TF_ROOT` into a `git` submodule, and then tell me what you did.
> I am not, as yet, convinced there would be any point to this.)

## Files and Directories Reserved by L8TF

The following directories, specific individual files, and file-name
prefixes, are __reserved for the testing framework__, meaning they are
automatically generated and any content of your own that you put in
these locations may get overwritten.

While the various names and prefixes can be changed, these should be
considered author/maintainer policies (i.e., if you're not the
author/maintainer and you change any of these for your own repository
instance, you may have trouble getting your bug-fixes and features
propagated back upstream)

### The `ALLTESTS` directory (`SUBJECT/tests/`)

By default, this is `SUBJECT/tests/`, but it can be renamed via
[--alltests=](./Install_L8TF.md#user-content---alltestspath)).

This is a home for
*  the test suite scripts,
*  the template for the test run directories
*  the `runall` script
*  a separate `configure` script that configures
   the tests for a given target platform.

### The test run directory (`BUILD/t/`)

This is a subdirectory of the build directory — whether `SUBJECT`
itself or elsewhere for a VPATH build — in which tests are run.  It is
reserved for use by the test scripts and is where you can find test
logs and detailed results.

The default name for this is `t`, but this can be changed using [--run=](./Install_L8TF.md#user-content---runpath)),

### The Unit Test filename prefix (`uT-*`)

By default, the prefix is `uT-`, but can be changed using [--unit-prefix=](./Install_L8TF.md#user-content---unit-prefixstring),

This applies to files in the C sources directory — which for LambdaMOO
is the top level of `SUBJECT`.

Files named with this prefix are assumed to refer to unit test
executables, thence possibly subject to remaking and deletion via
`make clean` if you configure a "unit testing build", and therefore
__should not be used for any other purpose__.

While this would mostly only be a problem for ordinary (non-VPATH)
builds in which object files and executables are created alongside the
C sources, this also affects VPATH builds, since any module file names
(i.e., those appearing in the Makefile `COMMON_CSRCS` or `XT_CSRCS`
lists) using this prefix will likewise get interfered with.  Meaning
if you are creating/designing new source modules, you still can't use
this prefix even you are fastidious about only doing VPATH builds.

(Note that while you can prevent unit-test executables from being
deleted by doing `touch clean-keeps-unit-tests`, this has a distinct
purpose i.e., you do this when you want to retain unit-test
executables for whatever reason.  It should not be used to protect
other content that happens to live in a file named with this prefix;
you should either change the prefix or move the content elsewhere.)

### The autoconf hook file (`SUBJECT/testing.ac`)

This is a file that gets included in `SUBJECT/configure.ac`,
preferably immediately before the final `AC_OUTPUT` directive,
in order that when the resulting `configure` script is run to create a
build directory, it will also create/populate the test run subdirectory
and fill in the various `Makefile` targets for running tests.

By default, the file is expected to be named `SUBJECT/testing.ac`,
but can be changed using [--subject-test-ac=](./Install_L8TF.md#user-content---subject-test-acpath).

### The `DISTCOPY` directory

This is the directory where testing sources get copied into a
distribution.  The default location is underneath `ALLTESTS`, and
hence already covered by the `ALLTESTS` tree being reserved.

However, you can opt to have it elsewhere (see [--distcopy=](./Install_L8TF.md#user-content---distcopypath-vs---no-distcopy)),
in which case this directory is likewise reserved.

### The startup filename prefix (`.l8tf-install.*`)

Files in various locations named with this prefix are read by
`install-l8tf` [on startup](./Install_L8TF.md#user-content-initialization-files), unless this feature has been
selectively or entirely disabled (see [--no-init](./Install_L8TF.md#user-content---no-init)).

Currently, except in the case of the __user__ startup file, where the
filepath can be changed arbitrarily (see [--user-init=](./Install_L8TF.md#user-content---user-initpath-vs---no-user-init)), this
prefix __cannot__ be changed (_I may yet make this an option, but I
have a very bad feeling about doing so…_).

For all suffixes used, there are actually two filenames reserved,

*  `.l8tf-install.SUFFIX`, expected to be list of command-line
   arguments with extra newlines and `#`-comments ignored,
*  `.l8tf-install.SUFFIX.sh`, expected to be sourced by a shell script,

both files serving the same purpose, the latter taking precedence.

Potentially, four files in the `SUBJECT` directory are affected,
although at most two should be in use at any given time:

#### `.l8tf-install.prev`

This filename is reserved for possible future use
(i.e., for now, we do everything in the `.sh` file,
but this may change)

#### `.l8tf-install.prev.sh`

This file is automatically generated.  It is a place for `install-l8tf`
to write the various "sticky" arguments that were used on the previous
installation, the ones the need to be remembered for doing updates.

#### `.l8tf-install.conf`

This file, if it exists, is __read__ by `install-l8tf`.
It is a place for the subject author/maintainer to place various
subject-specific command line options.

_(currently LambdaMOO's version of this file is blank since all of the
current defaults are as _for_ LambdaMOO, but, in theory, various flags
will migrate here eventually)_

#### `.l8tf-install.conf.sh`

> [!CAUTION]
>
> _Don't use this if you don't have to.  Seriously._
>
> _Using this entails Reading The Source to keep up with which shell_
> _variables the current version of `install-l8tf` relies on for what,_
> _all of which is, as yet, undocumented and may change out from under you._

This is the shell-script version of `.l8tf-install.conf` and takes
precedence if it exists.  This file is sourced as a shell script to
set shell variables directly, avoiding possible problems with command
line re-parsing _(that might happen if you are prone to doing silly
things like relying on filenames with single quotes (') in them, which
you shouldn't, but anyway).

## Configuring Tests Manually

The `ALLTESTS/configure` script resolves various testing environment
issues, e.g., which version of `netcat` is to be used.  This should
only need to be done once on any given test platform or whenever new
tools (e.g., alternate versions of `netcat`) become available, say,
due to OS upgrades or other package-system events.

You can run it manually, e.g.,

    cd ALLTESTS
    ./configure --with-netcat=nc.openbsd

if, say, you want to ensure that the BSD version of netcat is used.

Do `ALLTESTS/configure -hs` to see the full range of arguments
available.

Note that failing to do this simply means that `ALLTESTS/configure`
will be invoked at the start of the first actual test run (whether
from a build or an invocation of `ALLTESTS/runall`).

## How to Run Tests Directly

Tests scripts are created by GNU `autotest` and themselves take a
variety of options, not all of which are made readily available by
the various build `Makefile` testing targets.  Generally
`make test` in the build directory will do

    make -C t

i.e., descend into the `t` directory and make the first target,
which, by default, will be a vanilla run of `main_suite`.

However, `t/Makefile` has two variables available

* `TESTSUITE`  =  the suite to run (one of the `ALLTESTS/*_suite` scripts)
* `TESTSUITEFLAGS` = arguments to pass

so, e.g., you can do `make -C t TESTSUITEFLAGS=--help` to find out
what arguments are available for a given suite.

## Unit Testing

Running `SUBJECT/configure` with `--enable-testing=unit`
will produce a build directory set up for unit testing, which means

* `make test` will now run the `unit_suite` to build and run
  all of the unit tests

* unadorned `make` to build a server executable will __fail__
  to link due to `main()` having been '#ifdef'ed away.

* `make uT-`_NAME_ will build a particular unit-test executable
  which you can then run.

Some of the unit test executables have options to provide additional
useful information.

Notably `uT-bquota --report` will report the sizes (fictitious or
real) imputed to the various structures that `value_bytes()` depends
on.  (Running this on a `BYTE_QUOTA_MODE=BQM_HW` build would be a good
first step in designing a suitable byte-quota model for an exotic, new
hardware platform.)

## Disabling Testing

Running `SUBJECT/configure` with `--disable-testing`
creates a build for which there will be no test run (`t`) subdirectory
and those make targets will not exist.

## Creating new tests

(TODO.  For now, you'll have to look at the existing ones and
figure out the pattern)

## Adapting L8TF to other version/forks of LambdaMOO

In order for `install-l8tf` to work, `configure.ac` needs to satisfy
certain requirements, in order that this subject directory can be
recognized as a proper one to be operating on (as opposed to some
random directory being reached due to a typo).  `install-l8tf` will
otherwise immedately abort.

These requirements [are detailed here](./Install_L8TF.md#user-content---subjectpath)

> TODO: getting the rest of the way to being able to use this on a
> LambdaMOO fork will entail specifying
>
>    +  where unit test sources are to be found,
>
>    +  the unit test source prefix if this needs to be different
>       from `uT-` for whatever reason
>
>    +  which of the general tests (and maybe other tests located
>       elsewhere) are to be included in `main_suite`
>
>    +  the configuration naming scheme, i.e., names for
>       particular sequences of arguments to `configure` (or some
>       other way to get from names to `options.h` settings)
