m4_include([version_l8tf.m4])
AC_INIT(m4_defn([L8TF_PACKAGE_NAME]),
  m4_defn([L8TF_PACKAGE_VERSION]),
  m4_defn([L8TF_PACKAGE_BUGREPORT]),
  ,m4_defn([L8TF_PACKAGE_URL]))
AC_CONFIG_SRCDIR([testbuild.at])
AC_CONFIG_MACRO_DIRS([m4])
AC_CONFIG_FILES([Makefile t0/atlocal])
AC_CONFIG_COMMANDS([config.lastrun], [[
  chmod -w Makefile t0/atlocal
  echo timestamp > config.lastrun
]])
M5_PROG_NETCAT
AC_OUTPUT
