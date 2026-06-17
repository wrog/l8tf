# l8_optarg.m4

# L8_OPT_USE(<MODE>, <ARGS>, <TEXT>)
#   -> L8_OPT_<MODE>_BEGIN(<ARGS>)<TEXT>L8_OPT_<MODE>_END()
#   <TEXT> being a sequence of
#     L8_OPT_DECLARE([<WHAT>])(args...)(args2...)
#   each of which expands as
#     L8_OPT_<MODE>_WRAP(
#        m4_dquote(L8_OPT_<MODE>_<WHAT>(args...)))dnl
#     L8_OPT_<MODE>_POST(args2....)
#   context is assumed to be m4_divert([KILL])
#   and nothing relies on more than m4sugar
#   so this is safe to use before AS_INIT
#
m4_define([L8_OPT_USE],
  [m4_do(
     L8_OPT_$1_BEGIN($2),
     m4_pushdef([ l8_mode],[$1])$3[]m4_popdef([ l8_mode]),
     L8_OPT_$1_END())])

# assuming      _fn = <F> (identifier)
# and ' l8_popdefs' = (nonempty list of quoted identifiers)
# and parameters are <P>,<P1>,<P2>,...
# push the definitions L8_<F><n> = <P<n>> for all n>0
# and L8_<F> = <P> or ':' if no parameters
# appending all of the quoted identifiers [L8_<F>*] to ' l8_popdefs'
m4_define([l8_opt_collect],
  [_$0( [], 1,
        m4_if($#, 0,
             [[:]], [$@]),)])
m4_define([_l8_opt_collect],
  [m4_if($#, 3, [],
    [m4_pushdef([_fnx], [L8_]m4_defn([_fn])[$1])dnl
m4_pushdef( m4_defn([_fnx]), [$3])dnl
m4_append([ l8_popdefs], m4_dquote(m4_defn([_fnx])), [,])dnl
m4_popdef([_fnx])dnl
$0([$2], m4_incr([$2]), m4_shift3($@))])])


m4_define([L8_OPT_DECLARE],
[m4_pushdef([ l8_what],[$1])
m4_pushdef([ l8_popdefs],[[ l8_popdefs]])
m4_foreach([_], m4_cdr($@),
  [m4_pushdef([_i],m4_index(m4_defn([_])(),[(]))dnl)
m4_pushdef([_fn],ax_lp_strhead(m4_defn([_i]),m4_defn([_])))dnl
m4_unquote([l8_opt_collect]ax_lp_strtail(m4_defn([_i]),m4_defn([_])))[]dnl
m4_popdef([_fn],[_i])])dnl
m4_pushdef([_],[L8_OPT_]m4_defn([ l8_mode])[_PRE])
m4_ifdef(m4_defn([_]),
  [m4_unquote(m4_defn([_])m4_popdef([_])[([$1])[]])],
  [m4_popdef([_])])
$0_])

m4_define([L8_OPT_DECLARE_],
[m4_pushdef([_],
  [L8_OPT_]m4_defn([ l8_mode])[_]m4_defn([ l8_what]))
m4_ifdef(m4_defn([_]),
  [m4_unquote(
[L8_OPT_]m4_defn([ l8_mode])[_WRAP(m4_dquote(]m4_defn([_])[($@)))]
m4_popdef([_]))],
  [m4_popdef([_])])
$0_])

m4_define([L8_OPT_DECLARE__],
[m4_pushdef([_],[L8_OPT_]m4_defn([ l8_mode])[_POST])
m4_ifdef(m4_defn([_]),
  [m4_unquote(m4_defn([_])[($@)[]]m4_popdef([_]))],
  [m4_popdef([_])])
m4_unquote([m4_popdef([ l8_what],]m4_defn([ l8_popdefs])[)])])


# L8_OPT_USE([SHELL], <CASES_VAR>, <TEXT>)
#   produce AS_CASE arguments for a shell script
#
# L8_OPT_USE([HELP], <HELPTEXT_VAR>, <TEXT>)
#   produce --help text
#
# L8_OPT_USE([MD],[<MDVAR>], [TEXT...])
#   produce markdown reference source
#
# L8_OPT_USE([INITS],[<MDVAR>], [TEXT...])
#   initialization guidance

# ------------
#  parameters
# ------------
#
m4_define([L8_OPTSH_HELPWIDTH],[32])   # AS_HELP_STRING width
m4_define([L8_OPT_HELP_BEGIN], [m4_pushdef([ HELP],[$1])])
m4_define([L8_OPT_HELP_END],   [m4_popdef( [ HELP])])
m4_define([L8_OPT_HELP_WRAP],  [m4_append( m4_defn([ HELP]), [$1],[
])])

m4_define([L8_OPT_SHELL_BEGIN], [m4_pushdef([ CASES],[$1])])
m4_define([L8_OPT_SHELL_END],   [m4_popdef( [ CASES])])
m4_define([L8_OPT_SHELL_WRAP],
[m4_ifset([L8_first],
  [m4_append( m4_defn([ CASES])[_FIRST], [$1])dnl
m4_if(m4_defn([L8_first]),[:],
    [m4_pushdef([_],m4_format([[[%s],[   ],]],[$][1]))dnl
m4_append(m4_defn([ CASES]), m4_dquote(m4_map_args_pair([_],[m4_car],$1)))dnl
m4_popdef([_])],
    [m4_append( m4_defn([ CASES]), [$1])])],
  [m4_append( m4_defn([ CASES]), [$1])])])

m4_define([L8_OPT_ARGS_BEGIN], [m4_pushdef([ ARGS],[$1])])
m4_define([L8_OPT_ARGS_END],   [m4_popdef( [ ARGS])])
m4_define([L8_OPT_ARGS_WRAP],
  [m4_ifset([L8_save],[m4_append( m4_defn([ ARGS]), m4_quote($1), [,])])])

m4_define([L8_OPT_INITS_BEGIN], [m4_pushdef([ INITS],[$1])])
m4_define([L8_OPT_INITS_END],   [m4_popdef( [ INITS])])
m4_define([L8_OPT_INITS_WRAP],  [m4_append( m4_defn([ INITS]), [$1], m4_newline())])

# -----------------------------------------
#  section declarations
# -----------------------------------------
#
# HEADER([Title])
#   document header, nothing to do for the shell script

# SECTION([Title])
#   start of an new section 'Title'
#
m4_define([L8_OPT_HELP_SECTION],
[[]m4_newline()[$1]m4_ifval([$2],[[ ($2)]],[]):])

m4_define([L8_OPT_INITS_SECTION],
[
@%:@@%:@ [$1]m4_ifval([$2],[[ ($2)]],[])])

# -----------------------------------------
#  option declarations
# -----------------------------------------
#
# ACTION([s],[long],[helpmsg],[code])
#   perform some arbitrary parameter action.
#   Use this to create aliases for other groups of parameter settings
m4_define([L8_OPT_HELP_ACTION],
[AS_HELP_STRING(m4_ifval([$1],[[[-$1, ]]])[[--$2]],
  [$3], L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_ACTION],
[
      m4_ifval([$1],[[[-$1 | +$1 | ]]],[])[_L8_OPT_LONG_PATTERN([$2])],[
        $4
       ],])


# INFOBOOLEAN([h],[help],[msg],[?],[code])
#   informational boolean,
#     normally false
#     ANY mention (any of +h,-h,-?,--help) means true and
#       code (that will generally exit) should be invoked
#     no mention means false, do nothing, run normally
#
m4_define([L8_OPT_INITS_INFOBOOLEAN],
[m4_format([[%-25s %s]], m4_bpatsubst([$5],[:],[false]), [@%:@ --$2 (INFOBOOLEAN $3)])])

m4_define([L8_OPT_HELP_INFOBOOLEAN],
[AS_HELP_STRING(m4_ifval([$1],[[[-$1, ]]],[])dnl
m4_ifval([$4],[[[-$4, ]]],[])[[--$2]],
  [$3], L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_INFOBOOLEAN],
[
      m4_ifval([$1],[[[-$1 | +$1 | ]]],[])dnl
m4_if([$4],[?],[[[-[$4] | ]]],[$4],[],[],[[[-$4 | ]]])[_L8_OPT_LONG_PATTERN([$2])],[
        $5
       ],])

# BOOLEAN([s],[long],[helpmsg],[default],[do_it])
#   regular boolean option
#     +s or --long     means  true
#     -s or --no-long  means  false
#   and complain about multiple conflicting settings
#
m4_define([L8_OPT_INITS_BOOLEAN],
[m4_ifset([L8_given],
[m4_format([%-27s [%s
]], m4_defn([L8_given])[=false], [@%:@ --$2 (BOOLEAN $3)])])dnl
m4_format([[%-25s %s]], $5=?[$4], [@%:@ --$2 (BOOLEAN $3)])])

m4_define([L8_OPT_HELP_BOOLEAN],
[AS_HELP_STRING(m4_ifval([$1],[[[+$1, -$1, ]]],[])[[-(-no)-$2]],
  m4_ifval([$4],[[$3 [$4]]],[[$3]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_BOOLEAN],
[
      m4_ifval([$1],[[[+$1 | ]]])[_L8_OPT_LONG_PATTERN([$2])],
        m4_ifdef([L8_given],[
        m4_defn([L8_given])[=:]])[
        $5[=:
       ]],[
      ]m4_ifval([$1],[[[-$1 | ]]])[_L8_OPT_LONG_PATTERN([no-$2])],
        m4_ifdef([L8_given],[
        m4_defn([L8_given])[=:]])[
        $5[=false
       ]],])
#
#  VALUE([s],[long],[pname],[helpmsg],[default],[var])
#    regular value option
#      '--long=value' or '-s value'  sets  var=value
#
m4_define([L8_OPT_INITS_VALUE],
[m4_ifset([L8_given],
[m4_format([%-27s [%s
]], m4_defn([L8_given])[=false], [@%:@ --$2 (VALUE $4)])])dnl
m4_format([[%-25s %s]], $6=?[$5(]$3[)], [@%:@ --$2 (VALUE $4)])])

m4_define([L8_OPT_HELP_VALUE],
[AS_HELP_STRING(m4_ifval([$1],[[[-$1, ]]],[])[[--$2=]$3],
  m4_ifval([$5],[[$4 [$5]]],[[$4]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_VALUE],
[[
      _L8_OPT_LONG_PATTERN([$2=*])],m4_ifdef([L8_given],[
        m4_defn([L8_given])[=:]])[
        $6[="$l8_argument"
       ]],m4_ifval([$1],[[[
      -$1]],[[
        test $][@%:@ -gt 1 || usage "$][1: ]$3[ missing"
        shift]]m4_ifdef([L8_given],[
        m4_defn([L8_given])[=:]])[
        $6[="$][1"
       ]],],[])])

m4_define([L8_OPT_ARGS_VALUE],[[$6]])

#  ZVALUE([s],[long],[pname],[helpmsg],[default],[var])
#    integer value option
#      '--no-long'     sets it to  '0'
#      '--long','-s'   sets it to  '1'
#      '--long=n''     sets it to  'n'
#
m4_define([L8_OPT_INITS_ZVALUE],
[m4_format([[%-25s %s]], $6=m4_if([$5],[no],[0],[[?$5($3)]]), [@%:@ --$2 (ZVALUE $4)])])

m4_define([L8_OPT_HELP_ZVALUE],
[AS_HELP_STRING(m4_ifval([$1],[[[-$1, ]]],[])[[--(no-)$2(=]$3[)]],
  m4_ifval([$5],[[$4 [$5]]],[[$4]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_ZVALUE],
[[
      _L8_OPT_LONG_PATTERN([no-$2])],[
        $6[=0
       ]],[
      _L8_OPT_LONG_PATTERN([$2=*])],[
        $6[="$l8_argument"
       ]],[
      ]m4_ifval([$1],[[[-$1 | ]]])[_L8_OPT_LONG_PATTERN([$2])],[
        $6[=1
       ]],])

#  NEGVALUE([s],[long],[pname],[helpmsg],[default],[var])
#    value option that can be null
#      '--long=value'   sets  var='value'
#      '+s value'       sets  var='value'
#      '--no-long','-s' sets  var=''  (empty string)
#
m4_define([L8_OPT_INITS_NEGVALUE],
[m4_format([[%-25s %s]], $6=m4_if([$5],[no],[],[[?$5($3)]]), [@%:@ --$2 (NEGVALUE $4)])])

m4_define([L8_OPT_HELP_NEGVALUE],
[AS_HELP_STRING(m4_ifval([$1],[[[+$1,]]],[])[[--(no-)$2=]$3],
  m4_ifval([$5],[[$4 [$5]]],[[$4]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_NEGVALUE],
[[
      m4_ifval([$1],[[[-$1] | ]])_L8_OPT_LONG_PATTERN([no-$2])],[
        $6[=
       ]],[
      _L8_OPT_LONG_PATTERN([$2=*])],[
        $6[="$l8_argument"
       ]],m4_ifval([$1],[[[
      +$1]],[[
        test $][@%:@ -gt 1 || usage "$][1: ]$3[ missing"
        shift]
        $6[="$][1"
       ]],],[])])

#  NEGVALUEOPT([s],[long],[pname],[helpmsg],[default],[doit_var],[var])
#    negatable value option
#      '--long=value'   sets doit_var=:  and var=value
#      '+s' '--long'    sets doit_var=:
#      '-s' '--no-long' sets doit_var=false

m4_define([L8_OPT_INITS_NEGVALUEOPT],
[m4_format([[%-25s %s
%-25s %s]], $6=m4_if([$5],[no],[[false]],[[:]]), [@%:@ --$2 (NEGVALUEOPT $4)], $7=?[($3)], [@%:@ --$2 default])])

m4_define([L8_OPT_HELP_NEGVALUEOPT],
[AS_HELP_STRING(m4_ifval([$1],[[[+$1,-$1,]]],[])[[-(-no)-$2(=]$3[)]],
  m4_ifval([$5],[[$4 [$5]]],[[$4]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_NEGVALUEOPT],
[[
      m4_ifval([$1],[[[-$1] | ]])_L8_OPT_LONG_PATTERN([no-$2])],[
        $6[=false ;
       ]],[
      _L8_OPT_LONG_PATTERN([$2=*])],[
        $6[=: ; ]$7[="$l8_argument"
       ]],[
      m4_ifval([$1],[[[+$1] | ]])_L8_OPT_LONG_PATTERN([$2])],[
        $6[=: ;
       ]],])

m4_define([L8_OPT_ARGS_NEGVALUEOPT],[[$6], [$7]])

#  PUSH([s],[long],[pname],[helpmsg],[default],[pushfn])
#    option that can be invoked multiple times
#    to push values onto a list
#      invoke 'pushfn value' each time
#
m4_define([L8_OPT_INITS_PUSH],
[m4_format([[%-25s %s]], $6 ?[$5($3)], [@%:@ --$2 (PUSH $4)])])

m4_define([L8_OPT_HELP_PUSH],
[AS_HELP_STRING(m4_ifval($1,[[[-$1,]]],[])[[--$2=]$3],
  m4_ifval([$5],[[$4 [$5]]],[[$4]]),
  L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_PUSH],
[[
      _L8_OPT_LONG_PATTERN([$2=*])],[
        $6[ "$l8_argument"
       ]],m4_ifval($1,[[[
      -$1]],[[
        test $][@%:@ -gt 1 || usage "$][1: ]$3[ missing"
        shift]
        $6[ "$][1"
       ]],],[])])

#  LAST([--],[argsname],[helpmsg],[code])
#    -- indicates end of options
#    presumably the remaining arguments get used for something
#
m4_define([L8_OPT_INITS_LAST],
[$4 @%:@ -- $2 ($3)])

m4_define([L8_OPT_HELP_LAST],
[AS_HELP_STRING([[$1 ]$2[...]], [$3], L8_OPTSH_HELPWIDTH)])

m4_define([L8_OPT_SHELL_LAST],
[
      --,
        $4,])

# =========
# utilities
# ---------

# L8_OPT_CMDLINE_PARSE_FN([FN_PARSE], [DOCSTRING], [CASES])
#   expands to a definition of shell function FN_PARSE
#   for parsing the command line.
#   CASES is the macro name given to L8_OPT_USE([SHELL]...)
#   DOCSTRING is commentary to be passed along
#
m4_define([L8_OPT_CMDLINE_PARSE_FN],
[AS_FUNCTION_DESCRIBE([$1], [["$][@"]],
[$2])[

]$1[ () ]{[
  while test "$][@%:@" -gt 0 ; do]
    AS_CASE([[$][1]],[[
      --*=?*]],[dnl
[    l8_argument=`expr "X$][1" : '[^=]*=\(.*\)'`
       ]],[dnl
[    l8_argument=
       ]])
    AS_CASE([[$][1]],$3)[
    shift
  done
]}])


# _L8_OPT_LONG_PATTERN([long-name])
#   expands to "[long-name | long_name | longname]"
#   or just "longname" for names that have no hyphens
#   for use in case-label patterns
#
m4_define([_L8_OPT_LONG_PATTERN],
[m4_if(m4_bregexp([$1],[[-_]]),[-1],  [[--$1]],
[m4_pushdef([__x__],
  [--m4_join](m4_dquote([$]1)[,
   m4_unquote(m4_split(m4_translit([[$1]],[-],[_]),[_]))]))dnl
m4_map_args_sep([__x__(],[)],[ | ],[-],[_],[])dnl
m4_popdef([__x__])])])dnl


#  L8_VAR_INCR([[VAR]]) -> ++$VAR
#
m4_define([L8_VAR_INCR],
  [AS_VAR_ARITH([$1],[[$]$1[ \+ 1]])])dnl

#  L8_VAR_DECR([[VAR]]) -> --$VAR
#
m4_define([L8_VAR_DECR],
  [AS_VAR_ARITH([$1],[[$]$1[ \- 1]])])dnl
