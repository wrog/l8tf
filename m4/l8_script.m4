# l8_script.m4
# -------------
#
# common shell functions needed by both install-l8tf and runall

m4_define([L8_SCRIPT_PREAMBLE],[[
#------------------------------------------------
# basic messaging, death with dignity, verbosity
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
 [  AS_ECHO([["$][@"]]) [>&2]])
  AS_EXIT([[$s]])
}[

# l8_fn_usage ERROR_MSG ?DONT_MENTION_HELP
# -----------
#
l8_fn_usage () ]{
  AS_VAR_IF([2],[],
[[  l8_fn_fatal "$][1" "$as_myself --help  will show a list of valid options"]],[[
    l8_fn_fatal "$][1"]])
}[

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
L8_OPTION_HELP_LINES
[
L8END
]}
])
