#
# Macro definitions for generating markdown references
#
# -----------------------------------------
#  utilities
# -----------------------------------------

# L8_OPT_USE([MD],[],
#   m4_defn([INSTALL_L8TF_OPTS]))dnl

m4_define([L8_OPT_MD_BEGIN],[m4_pushdef([ OUT], [$1])])
m4_define([L8_OPT_MD_END],  [m4_popdef([ OUT])])
m4_define([L8_OPT_MD_WRAP],[m4_append(m4_defn([ OUT]),[$1
])])
m4_define([L8_OPT_MD_POST],[m4_append(m4_defn([ OUT]),[[$1]]dnl
m4_ifdef([L8_first],[m4_if(m4_defn([L8_first]),[:],[[[
This option is ignored in [startup files](@%:@user-content-initialization-files).
]]])])
m4_if(m4_defn([ l8_what]),[HEADER],[m4_defn([ OUT])[_TOC]
]))])

m4_define([L8_OPT_MD_PARAM],[m4_unquote(m4_translit([[$1]],[<>],[__]))])
m4_define([L8_KILL_PARENS],[m4_bpatsubst([[$1]],[@{:@\|@:}@],[])])
m4_define([L8_OPT_MD_LINK],[L8_KILL_PARENS(m4_translit([[$1]],[ ABCDEFGHIJKLMNOPQRSTUVWXYZ=.,`'_?()],[-abcdefghijklmnopqrstuvwxyz]))])

m4_define([L8_OPT_MD_PUTHD],
[m4_append(m4_defn([ OUT])[_TOC],
m4_case([$1],[2],[[[* ]]],[3],[[[  + ]]])dnl
[[[$2]]]m4_format([[[(@%%:@user-content-%s)]]
],L8_OPT_MD_LINK([$2])))dnl
_m4_for([1],[$1],[1],[m4_ignore(],[)[@%:@]])[ $2]])

# HEADER([Title])
#   top-level header
#
m4_define([L8_OPT_MD_HEADER], [[@%:@ $1]])

# SECTION([Title])
#   2nd-level header
#
m4_define([L8_OPT_MD_SECTION],
[L8_OPT_MD_PUTHD([2],[$1]m4_ifval([$2],[[ ($2)]]))])

# ACTION([s],[long],[helpmsg],[code])
#   perform some arbitrary parameter action.
#   Use this to create aliases for other groups of parameter settings
#
m4_define([L8_OPT_MD_ACTION],
[L8_OPT_MD_PUTHD([3],[`--$2`])])

# INFOBOOLEAN([h],[help],[msg],[?],[do_it])
#   informational boolean,
#     normally false
#     ANY mention (any of +h,-h,-?,--help)
#       means true, do the help thing, and exit
#     no mention means false, do nothing, run normally
#
m4_define([L8_OPT_MD_INFOBOOLEAN],
[L8_OPT_MD_PUTHD([3],[`--$2`]dnl
m4_ifval([$4],[ ]@{:@[[`-$4`]m4_ifval([$1],[[, ]])],[m4_ifval([$1],[ ]@{:@)])dnl
m4_ifval([$1],[[`-$1`]]@:}@,[m4_ifval([$4],@:}@)]))])


# BOOLEAN([s],[long],[helpmsg],[default],[do_it])
#   regular boolean, +s means true, -s means false
#   do_it=: or do_it=false, depending
#
m4_define([L8_OPT_MD_BOOLEAN],
[L8_OPT_MD_PUTHD([3],[`--$2`]dnl
m4_ifval([$1],[[ (`+$1`)]])[ vs. `--no-$2`]m4_ifval([$1],[[ (-$1)]]))])

#  VALUE([s],[long],[pname],[helpmsg],[default],[var])
#    regular value option
#      '--long=value' or '-s value'  sets arbitrary string value
#
m4_define([L8_OPT_MD_VALUE],
[L8_OPT_MD_PUTHD([3],[`--$2=`]L8_OPT_MD_PARAM([$3])dnl
m4_ifval([$1],[[ (`-$1` ]L8_OPT_MD_PARAM([$3])[)]]))])

#  ZVALUE([s],[long],[pname],[helpmsg],[default],[var])
#    integer value option
#      '--no-long'     sets it to  '0'
#      '--long','-s'   sets it to  '1'
#      '--long=n''     sets it to  'n'
m4_define([L8_OPT_MD_ZVALUE],
[L8_OPT_MD_PUTHD([3],[`--(no-)$2`(`=`]L8_OPT_MD_PARAM([$3])[)]dnl
m4_ifval([$1],[[ (`-$1`)]]))])

#  NEGVALUE([s],[long],[pname],[helpmsg],[default],[var])
#    negatable value option
#      '--long=value'   sets it to  'value'
#      '+s value'       sets it to  'value'
#      '--no-long','-s' sets it to  '' (empty string)
#
m4_define([L8_OPT_MD_NEGVALUE],
[L8_OPT_MD_PUTHD([3],[`--$2=`]L8_OPT_MD_PARAM([$3])dnl
m4_ifval([$1],[[ (`+$1` ]L8_OPT_MD_PARAM([$3])[)]])[ vs. ]dnl
[`--no-$2`]dnl
m4_ifval([$1],[[ (`-$1`)]]))])

#  NEGVALUEOPT([s],[long],[pname],[helpmsg],[default],[doit_var],[var])
#    negatable value option
#      '--long=value'   sets doit_var=:     and var=value
#      '+s' '--long'    sets doit_var=:     and var=default
#      '-s' '--no-long' sets doit_var=false and var=

m4_define([L8_OPT_MD_NEGVALUEOPT],
[L8_OPT_MD_PUTHD([3],[`--$2`(`=`]L8_OPT_MD_PARAM([$3])[)]dnl
m4_ifval([$1],[[ (`+$1`)]])[ vs. ]dnl
[`--no-$2`]dnl
m4_ifval([$1],[[ (`-$1`)]]))])

#  PUSH([s],[long],[pname],[helpmsg],[|default],[push])
#    option that can be invoked multiple times
#    to push values onto a list
#
m4_define([L8_OPT_MD_PUSH],
[L8_OPT_MD_PUTHD([3],[`--$2=`]L8_OPT_MD_PARAM([$3])dnl
m4_ifval([$1],[[ (`-$1` ]L8_OPT_MD_PARAM([$3])[)]]))])
#
#  LAST([--],[argsname],[helpmsg],[code])
#    -- indicates end of options
#    and remaining arguments are getting swept up
#
m4_define([L8_OPT_MD_LAST],
[L8_OPT_MD_PUTHD([3],[`--` ]L8_OPT_MD_PARAM([$2])[...])])
