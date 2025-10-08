# LambdaMOO Test Frame (L8TF)

This is a framework for testing builds of the LambdaMOO server.

(...may also possibly be adaptable to testing the various forks as well,
depending on how far they have diverged...)

## Getting Started

Assuming you already have a LambdaMOO server distribution, and that
you have managed to successfully build it for whatever configurations
you care about, let `MOODIST` be the directory where it lives.

If your server distribution was a tarball already containing this
test distribution, then it should already be set up to run tests.
Let `TESTDIST` be the directory where you are reading this file.

What this means is for every build directory, whether you’re doing a
regular top-level build or a VPATH build, unless you configure it
with `--disable-tests`, there will be a `t` subdirectory where
the tests run, and

```
  make -C t
```

will configure `TESTDIST` if necessary (this only needs to happen
once), and then run the tests (you'll need to replace `t` with an
actual path if you're doing this from outside the build directory.
There should also be a `test` or `check` target in the top level build
`Makefile` that does the same thing.

The other possible scenarios are
* building from `git` repositories;
  see [the next section](#user-content-working-from-git).
* building from a tarball that does __not__ include the tests
  (which I'm going to defer writing about because maybe this
  scenario will never actually come up)

## Working from `git`

In what follows, `TESTDIST` is wherever you want your test suite
repository to be.

Note that one intent of the design is that a single `TESTDIST`
instance be able to serve multiple `MOODIST` instances, so the actual
location should not matter.  But if you have just one `MOODIST`,
having `TESTDIST` be a sibling directory is probably the easiest
setup.

(Also I expect stupid things to happen if any of the components
of the path from `MOODIST` to `TESTDIST` have spaces in them,
so (1) don't do that and (2) yes, this limits your choices,
I suppose.)

> [!NOTE]
>
> Having `TESTDIST` be a subdirectory of `MOODIST` is likely doable,
> but then you have the additional work of preventing two `git`
> instances from partying simultaneously on `TESTDIST` and all of the
> (now shared) subdirectories.  (TLDR: `MOODIST/.git/info/exclude`
> will need to list the `TESTDIST` subdirectory.
>
> Or, for extra pain in your life, you can figure out how to make
> `TESTDIST` into a submodule, and then tell me what you did.
> I am not, as yet, convinced there would be any point to this.)

1.  Retrieve the test sources.  Go to the parent directory of wherever
    you want `TESTDIST` to be and then do

   ```
   git clone REPOSITORY TESTDIST
   ```

    where `REPOSITORY` as of this writing (Oct. 2025) is at github
    ([https://github.com/wrog/l8tf.git](https://github.com/wrog/l8tf))

2.  We have to tell `MOODIST` how to find `TESTDIST`.

    Somewhere in `MOODIST/configure.ac` (at the top level outside
    of comments or m4-quotes [], and somewhere between `AC_INIT` and
    `AC_OUTPUT`), this needs to happen:

   ```
   m4_include([TESTDIST/config_subject.ac])
   ```

    where `TESTDIST` can either be an absolute path or a relative path
    from the top level of `MOODIST`.  The latter is less typing.

    Exactly _how_ this happens is up to you, but you likely want to do
    it in such a way that you are not having to commit this as a change
    in `git`.  There are choices:

    * Your `MOODIST/configure.ac` should have a `m4_sinclude([testing.ac])`
      line.  Create `testing.ac` with the single line above including
      `config_subject.ac`

 > [!WARNING]
 >
 > You may be tempted to symlink `testing.ac` to `config_subject.ac`.
 > This will not work.

    * Older versions of LambdaMOO will refer to `extensions2.ac`, so
      you could include `config_subject.ac` from there instead (the
      `./configure -hs` text will get slightly confused but this is of
      little consequence)

    * If you have to edit `configure.ac`, directly due to no
      `m4_sinclude` file being available, whether because what you're
      testing is something even older or a fork thereof, inclusion of
      `config_subject.ac` needs to come after any call to
      `AC_PRESERVE_HELP_ORDER` and generally should be after any
      macros that set up `./configure` arguments (as LambdaMOO does in
      `MOO_ARGUMENTS`)

    * (There may be fun autostash games I haven't worked out yet
      that will probably be too complicated).

3.  Then, still within `MOODIST`, do

    ```
    autoconf -f
    ```

    to update `./configure`, which will thenceforth be creating and
    populating `t` subdirectories as needed, which should then be able
    to run tests as above.

    In case you were wondering, the `-f` is needed and will be needed
    whenever there are updates within `TESTDIST` or if you want change
    `TESTDIST` because `autoconf` tends to have trouble following
    `m4_sinclude()` (or at least that's my current theory).

    The `distclean` target in `MOODIST/Makefile.in` should have `t` on
    its list of things to remove (you may need to do this manually in
    older/forked versions of LambdaMOO).

## Configuring the test sources manually

This configuration process resolves various issues in the testing
environment, e.g., which version of `netcat` is to be used.  This
should only need to be done once on any given test platform or
whenever new tools (e.g., alternate versions of `netcat`) are
installed. You can run it manually, e.g.,

```
    cd `TESTDIR
    ./configure --with-netcat=bsd
```

if, say, you want to ensure that the BSD version of netcat is used.

Use `./configure -hs` in `TESTDIR` to see the full range of arguments available.

Not configuring the test source directory means `TESTDIR/configure`
with no arguments will be invoked at the start of the first actual
testing run.

## How to create new tests

(todo.  For now, you'll have to look at the existing ones and
figure out the pattern)
