# netcat configuration
#
# M5_PROG_NETCAT
# --------------
# Sets up the --with-netcat=NAME|PATH command option
# Tries to find a Netcat program.
# Sets output variables accordingly (more detail below)
#   NETCAT - program name/path
#   NETCAT_WHICH - if this is a recognized version
#     ''     -- (not recognized)
#     'trad' -- Hobbit's original (nc.traditional)
#     'bsd'  -- OpenBSD version   (nc.openbsd)
#     'gnu'  -- GNU version
#     'ncat' -- IMAP's ncat
#     'socket' -- Nickelsen's socket utility
#   NETCAT_CLOSE_EOF - how to shutdown on stdin EOF
#   NETCAT_KEEPALIVE - how to *not* shut down on stdin EOF
#   NETCAT_LISTEN_FORMAT - how to do a basic listener
#
# If user is already pointing us to a netcat with
#   --with-netcat=FILENAME
# we use that and try to figure out which one it is.
#
# Or everything was already set in the cache from
# the last configure run.
#
# Or user has given up on us and
# and is setting the output variables directly.
#
# Or the command line is blank and we are doing
# a full PATH search for something usable.

#--------------------------------
# _M5_PROG_NETCAT_WHICH([netcat])
#
m4_defun_init([_M5_PROG_NETCAT_WHICH],
[AS_REQUIRE([_M5_PROG_NETCAT_WHICH_PREPARE],[],[M4SH-INIT-FN])],
[[_m5_fn_netcat_which "]$1["]])


m4_defun([_M5_PROG_NETCAT_WHICH_PREPARE],
[AS_REQUIRE_SHELL_FN([_m5_fn_netcat_which],[
AS_FUNCTION_DESCRIBE([_m5_fn_netcat_which],[PROG_VAR],
[Determine which netcat $PROG_VAR (assumed to expand to a name or path) is; i.e., this does the actual work.  Note that we cannot rely on the filename; there are just too many versions out there and names like 'netcat' and 'nc' typically get remapped.])[
#
# The following shell vars are set, where possible:
#    _m5_nc_rank   (higher=more preferred, 0=dont know)
#    _m5_nc_which  (NETCAT_WHICH)
#    _m5_nc_cleof  (NETCAT_CLOSE_EOF)
#    _m5_nc_keepa  (NETCAT_KEEPALIVE)
#    _m5_nc_listen (NETCAT_LISTEN_FORMAT)
]],
[  AS_VAR_COPY([_m5_nc_prog],[$][1])[
  _m5_match=`"$_m5_nc_prog" -version 2>&1 | \
    $EGREP -e '^Socket-' -`
  if test "x$_m5_match" != x ; then
    _m5_nc_cleof=-q
    _m5_nc_keepa=
  else
    _m5_match=`"$_m5_nc_prog" -h 2>&1 | \
    $EGREP -e 'nmap[.]org|OpenBSD|GNU netcat |[@<:@]v' -`
    _m5_nc_keepa=`"$_m5_nc_prog" -h 2>&1 | \
      $EGREP -i -e '(continue) .* 'EOF' .* stdin' -`
    _m5_nc_keepa=`expr "X$_m5_nc_keepa" : 'X *\([^ ]*\)'`
    _m5_nc_cleof=`"$_m5_nc_prog" -h 2>&1 | \
      $EGREP -i -e '(close|shutdown) .* (on|after) 'EOF' (on|from) stdin' -`
    if test "x$_m5_nc_cleof" = x ; then
      "$_m5_nc_prog" -h 2>&1 | \
        $EGREP -i -e '-q secs[ 	]*quit after EOF on stdin' - 1>/dev/null 2>&1 &&
        _m5_nc_cleof='-q 0'
    else
      _m5_nc_cleof=`expr "X$_m5_nc_cleof" : "X[ 	]*\([^ 	,]*\)"`
    fi
  fi
  _m5_nc_rank=0
  { test "$_m5_nc_cleof" || test "$_m5_nc_keepa"; } &&]
    AS_CASE([[$_m5_match]],[[
      *nmap.org*]],[[
        _m5_nc_which=ncat
        _m5_nc_rank=1
       ]],[[
      GNU*]],[[
        _m5_nc_which=gnu
        _m5_nc_rank=2
       ]],[[
      OpenBSD*]],[[
        _m5_nc_which=bsd
        _m5_nc_rank=3
       ]],dnl
dnl traditional netcat does not identify itself.
dnl yes, relying on a specific version may seem stupid
dnl but this one has not been updated since 1996;
dnl it is the one everybody has
[[
      ?v1.10*]],[[
        _m5_nc_which=trad
        _m5_nc_rank=4
       ]],[[
      Socket-*]],[[
        _m5_nc_which=socket
        _m5_nc_rank=5
      ]])
    AS_CASE([[$_m5_nc_which]],[[
      ncat|bsd]],[[
        _m5_nc_listen_fmt='-l %s %s']],[[
      gnu|trad]],[[
        _m5_nc_listen_fmt='-l -s %s -p %s']],[[
      socket]],[[
        _m5_nc_listen_fmt='-s -B %s %s']])
])
])

AC_DEFUN_ONCE([M5_PROG_NETCAT],[dnl
dnl
  AC_REQUIRE([AC_PROG_EGREP])dnl
dnl
  AC_ARG_VAR([NETCAT],
[The preferred 'Netcat' executable, either the name or full path as
needed.  Normally, you should use --with-netcat=PROGRAM to switch
Netcats, However, if your desired version of Netcat is not one of
the varieties we recognize (see NETCAT_WHICH) and thus know which
arguments do what, you may need to set the other NETCAT_ variables
directly on the ./configure command line.])dnl
dnl
  AC_ARG_VAR([NETCAT_CLOSE_EOF],
[Netcat arguments to pass to ensure that Netcat
shuts down upon reaching (local) stdin EOF.
Set this variable directly only if --with-netcat=PROGRAM
does not produce the correct settings.])dnl
dnl
  AC_ARG_VAR([NETCAT_KEEPALIVE],
[Netcat arguments to pass to ensure that Netcat
does *NOT* shut down upon reaching (local) stdin EOF.
Set this variable directly only if --with-netcat=PROGRAM
does not produce the correct settings.])dnl
dnl
  AC_ARG_VAR([NETCAT_LISTEN_FORMAT],
[How to invoke Netcat in "listen mode"; this is
expected to be a 2-argument format string for printf,
where the arguments are address and port, in that order.
Set this variable directly only if --with-netcat=PROGRAM
does not produce the correct settings.])dnl
dnl
  AC_ARG_VAR([NETCAT_WHICH],
[Which netcat implementation this is, one of
'trad' -- traditional netcat (Hobbit's original)
'bsd'  -- OpenBSD version
'gnu'  -- GNU netcat
'ncat' -- Nmap project version])dnl
dnl
  AC_ARG_WITH([netcat],
    AS_HELP_STRING([--with-netcat=PROGRAM],
    [specify Netcat program to use (see NETCAT below)]),dnl
dnl
dnl user supplies '--with-netcat=...'
dnl
[   AS_IF([[test "$withval" = "no"]],[
      AC_MSG_ERROR([[Sorry, netcat is required.]])])
    AC_PATH_PROG([NETCAT],[[$withval]])
    test "$NETCAT" ||
      AC_MSG_ERROR(
[[Cannot find Netcat program '$withval'; giving up]])
    _M5_PROG_NETCAT_WHICH([[NETCAT]])
    AS_IF([[test $_m5_nc_rank -le 0]],[
      AC_MSG_ERROR(
[[Cannot tell which version of Netcat '$NETCAT' is.
You may need to set NETCAT, NETCAT_CLOSE_EOF, NETCAT_KEEPALIVE,
NETCAT_LISTEN_FORMAT, and NETCAT_WHICH individually.]])])[
    m5_cv_NETCAT_close_eof="$_m5_nc_cleof"
    m5_cv_NETCAT_keep_alive="$_m5_nc_keepa"
    m5_cv_NETCAT_listen_format="$_m5_nc_listen_fmt"
    m5_cv_NETCAT_which="$_m5_nc_which"
]],[dnl
dnl
dnl user does NOT supply '--with-netcat=...'
dnl
    AS_IF([[${ac_cv_path_NETCAT+false} : && test "$NETCAT"]],[
      # assume user knows what she is doing
dnl    in this case AC_PATH_PROGS_FEATURE_CHECK only does
dnl   ac_cv_path_NETCAT="$NETCAT"
[      m5_cv_NETCAT_close_eof="$NETCAT_CLOSE_EOF"
      m5_cv_NETCAT_keep_alive="$NETCAT_KEEPALIVE"
      m5_cv_NETCAT_listen_format="$NETCAT_LISTEN_FORMAT"
      m5_cv_NETCAT_which="$NETCAT_WHICH"
]])
    AC_CACHE_CHECK([for netcat/ncat],[ac_cv_path_NETCAT],dnl
dnl      either ac_cv_path_NETCAT is set (from the cache),
dnl        in which case m5_cv_NETCAT* will be as well,
dnl        and AC_PATH_PROGS_FEATURE_CHECK does nothing
dnl      or NETCAT is already set and
dnl        prior AS_IF did what is needed
dnl        and AC_PATH_PROGS_FEATURE_CHECK does nothing
dnl      or NETCAT is also not set
dnl        and we need to do the full search
      [[_m5_nc_maxrank=0]
      AC_PATH_PROGS_FEATURE_CHECK([NETCAT],
        [[nc.traditional nc.openbsd netcat nc ncat socket]],[dnl
dnl
        _M5_PROG_NETCAT_WHICH([[ac_path_NETCAT]])
        AS_IF([[test $_m5_nc_rank -gt $_m5_nc_maxrank]],[[
          ac_cv_path_NETCAT="$ac_path_NETCAT"
          _m5_nc_maxrank="$_m5_nc_rank"
          m5_cv_NETCAT_close_eof="$_m5_nc_cleof"
          m5_cv_NETCAT_keep_alive="$_m5_nc_keepa"
          m5_cv_NETCAT_listen_format="$_m5_nc_listen_fmt"
          m5_cv_NETCAT_which="$_m5_nc_which"
          test $_m5_nc_rank -ge 3 && ac_path_NETCAT_found=:]])],[dnl

        AC_MSG_ERROR(
[cannot find any recognizable version of Netcat; giving up])])])])dnl
dnl end of AC_ARG_WITH
dnl
  [NETCAT="$ac_cv_path_NETCAT"
  NETCAT_CLOSE_EOF="$m5_cv_NETCAT_close_eof"
  NETCAT_KEEPALIVE="$m5_cv_NETCAT_keep_alive"
  NETCAT_LISTEN_FORMAT="$m5_cv_NETCAT_listen_format"
  NETCAT_WHICH="$m5_cv_NETCAT_which"]
  AC_SUBST([NETCAT])
  AC_SUBST([NETCAT_CLOSE_EOF])
  AC_SUBST([NETCAT_KEEPALIVE])
  AC_SUBST([NETCAT_LISTEN_FORMAT])
  AC_SUBST([NETCAT_WHICH])
])#
# ------------ end of M5_PROG_NETCAT


# M5_NETCAT_TEST_ADDR_PORT( [IP_ADDR], PORT )
# ------------------------
# test if IP_ADDR PORT is available for listening
# return status 0 if yes, 1 if no
#
AC_DEFUN([M5_NETCAT_TEST_ADDR_PORT],
  [AC_REQUIRE([M5_PROG_NETCAT])dnl
AC_REQUIRE([_M5_NETCAT_TEST_PREPARE])dnl
[m5_fn_netcat_test_addr_port ]m4_default([$1],[''])[ ]$2[ ]])


AC_DEFUN([_M5_NETCAT_TEST_PREPARE],[
AS_REQUIRE_SHELL_FN([m5_fn_netcat_test_addr_port],[
AS_FUNCTION_DESCRIBE([m5_fn_netcat_test_addr_port],[ADDR PORT],
[Check if ADDR PORT can be listened at by running two netcat processes (server and client).  ADDR can be '', in which case the server listens at that port on all available interfaces (0.0.0.0) and hence fails if the port is in use on *any* interface.])
],
[[  _m5_nc_port=$][2
  _m5_nc_string=heeeeey]
  AS_VAR_IF([1],[],
[[  _m5_nc_addr=0.0.0.0
    _m5_nc_send=127.0.0.1]],
[[  _m5_nc_addr=$][1
    _m5_nc_send=$][1]])
  AS_ECHO_N([["  trying $_m5_nc_addr $_m5_nc_port..."]]) >&AS_MESSAGE_LOG_FD[
#  printf "\nDEBUG: %s" "...listen $_m5_nc_addr; send $_m5_nc_send; port = $_m5_nc_port" >&2
  { eval `printf "%s $NETCAT_LISTEN_FORMAT 2>&]AS_MESSAGE_LOG_FD[" \
         '$NETCAT' '$_m5_nc_addr' '$_m5_nc_port'` &
    eval "( { sleep 0.5 ; kill $! >/dev/null 2>&1; } & )" &
    } | grep $_m5_nc_string >/dev/null &
  _m5_nc_server=$!
  sleep 0.1]
  AS_ECHO([[$_m5_nc_string]])[ | { $NETCAT $NETCAT_CLOSE_EOF \
       $_m5_nc_send $_m5_nc_port || kill $_m5_nc_server ; } >/dev/null 2>&1 &
  _m5_nc_client=$!]
  AS_IF([[wait $_m5_nc_server]],
[  AS_ECHO([[success]]) >&AS_MESSAGE_LOG_FD[
    sync
    return 0]],
[  AS_ECHO([[fail]]) >&AS_MESSAGE_LOG_FD[
    kill $_m5_nc_client >/dev/null 2>&1
    sync
    return 1]])])])


# ------------ end of M5_NETCAT_TEST_ADDR_PORT
