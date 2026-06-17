# l8_cfname.m4 -- language to specify a configuration naming scheme
# ===================================================================
#
# DESCRIPTION
#
#   CFNAME is a small, simple domain-specific language for specifying
#   a configuration naming scheme, a way to summarize long lines of
#   ./configure arguments into compact words that can be used for naming
#   build/test directories.
#
#   Given a CFNAME scheme, this emits M4SH macros to define
#   the following shell functions (whose actual names are up to you)
#
#     parse     - attempt to parse a cfname and set shell variables
#     to_cfargs - convert a successful parse to ./configure arguments
#     to_cfname - convert a successful parse to a (canonical) cfname
#
# SYNOPSIS
#   my_cfname.m4:
#     L8_CFNAME_DECLARE_SCHEMA([MINE],[],[
#       # schema definition...
#     ])
#
#   elsewhere.m4
#     # declare MY_PARSE(), MY_TO_CFARGS(), MY_TO_CFNAME()
#     L8_CFNAME_USE_SCHEMA([MINE],[MY_])
#
#     # set parse state
#     MY_PARSE([[Nlt]])
#
#     MY_TO_CFARGS([[cfargs]])   # cfargs=' --enable-net=tcp,local'
#     MY_TO_CFNAME()             # "Ntl" (canonical cfname) on stdout
#
# TERMINOLOGY
#   "configuration" is a sequence of arguments ('cfarg's) for ./configure
#   eg.,
#     'net'   ->  --enable-net=K1,K2,...
#     'uclib' ->  --with-uclib=K1,K2,...
#     'foo'   ->  --enable-def-OPTION_NAME_FOR_FOO=K
#
#   each argument has one or more keyword positions ("kpos")
#   that take multiple values, e.g., for 'net' we have
#
#      net_p = 'tcp' or 'local'
#      net_s = 'bsd' or 'sysv'
#
#   and any of the four combinations can show up in --enable-net
#
#   A "cfname" is a sequence of "word"s mashed together
#   (regexp is (([A-Z](([a-w][xyz]?)([0-9][0-9]?))*)+ if you care)
#
#   each word starts with a word key ("wkey", single capital letter)
#   followed by zero or more 'value wordlets' which are all sequences
#   of 1-2 digits or lower-case letters, each corresponding to some
#   setting of a keyword position,
#
#   so, e.g.,
#
#     %word N
#       %kpos    net
#         %val!  x      no
#       %kpos    net p
#         %val   t      tcp
#         %val   l      local
#
#   means we have the following correspondences
#
#     ...Nx...   <=>  --disable-net
#     ...Npt...  <=>  --enable-net=...,tcp
#     ...Npl...  <=>  --enable-net=...,local
#
#   and parsing a configuration name with 'Npt'
#   in it sets the shell variable
#
#      {sh_prefix_}enable_net_p=tcp


# L8_CFNAME_DECLARE_SCHEMA(<NAME>,<SCRIPT>,<ARGS>)
#
m4_defun([L8_CFNAME_DECLARE_SCHEMA],
  [m4_define([_l8_cfname_s_args_$1],[$3])dnl
AX_LP_PARSE_SCRIPT([CFNAME], [$3], [$2])])

# L8_CFNAME_USE_SCHEMA(<NAME>[,<PREFIX>])
#   defines <PREFIX>_(PARSE|TO_CFARGS|TO_CFNAME)
#   according to the given schema, prefix defaulting to L8_CF_
#
m4_defun([L8_CFNAME_USE_SCHEMA],
[m4_ifdef([_l8_cfname_s_args_$1],[],
  [m4_fatal([$0: schema '$1' not declared])])dnl
m4_pushdef([_l8_current_s_args],
  m4_dquote(m4_dquote_elt(m4_unquote(m4_defn([_l8_cfname_s_args_$1])))))dnl
m4_pushdef([_l8_prefix],
  m4_case([[g_prefix_]],
    m4_unquote(m4_defn([_l8_current_s_args])),
    m4_default_quoted([$2], [L8_CF_])))dnl
m4_pushdef([_l8_prepare_prefix],
  m4_case([[g_prepare_prefix_]],
    m4_unquote(m4_defn([_l8_current_s_args])), [[_L8_CF_]]))dnl
m4_pushdef([_l8_fn_prefix],
  m4_case([[g_fn_prefix_]],
    m4_unquote(m4_defn([_l8_current_s_args])), [[_l8_fn_]]))dnl
m4_map_args_pair([_l8_putdefine2],[],
  [PARSE],     [parse_cfname],
  [TO_CFARGS], [parsed_cf_to_cfargs],
  [TO_CFNAME], [parsed_cf_to_cfname])dnl
m4_popdef(
  [_l8_fn_prefix], [_l8_prepare_prefix], [_l8_prefix],
  [_l8_current_s_args])])

m4_define([_l8_putdefine2],
  [m4_pushdef([_l8_lc],m4_format([[[%s%s]]], [$][1], m4_tolower([$1])))dnl
_l8_putdefine(
  m4_case(_l8_lc([g_]),         m4_unquote(m4_defn([_l8_current_s_args])),  [m4_defn([_l8_prefix])[$1]]),
  m4_case(_l8_lc([g_prepare_]), m4_unquote(m4_defn([_l8_current_s_args])),  [m4_defn([_l8_prepare_prefix])[$1_PREPARE]]),
  m4_case(_l8_lc([g_fn_]),      m4_unquote(m4_defn([_l8_current_s_args])),  [m4_defn([_l8_fn_prefix])[$2]]))dnl
m4_popdef([_l8_lc])])

m4_define([_l8_putdefine],
[m4_defun([$1], [AS_REQUIRE([$2])]m4_format([[%s %s]],[$3],[$][1]))])

dnl m4_errprintn([$1 => ]m4_defn([$1]))

AX_LP_DEFINE_LANGUAGE([CFNAME], [L8_CF_DEFINE],
  # all cmds split the line into whitespace-separated words
  [:args], [m4_unquote(m4_split(]m4_dquote([$][3])[))])


L8_CF_DEFINE([],
  # prefix for published shell variables
  [:var], [[g_sh_prefix_],        [l8_cf_]],

  [:var], [[g_fn_prefix_],        [_l8_fn_]],
  [:var], [[g_fn_parse],          [parse_cfname]],
  [:var], [[g_fn_to_cfargs],      [parsed_cf_to_cfargs]],
  [:var], [[g_fn_to_cfname],      [parsed_cf_to_cfname]],

  # PREPARE macros that can be [m4/AS/AC]_REQUIREd
  [:var], [[g_prepare_prefix_],   [_L8_CF_]],
  [:var], [[g_prepare_parse],     [PARSE_PREPARE]],
  [:var], [[g_prepare_to_cfargs], [TO_CFARGS_PREPARE]],
  [:var], [[g_prepare_to_cfname], [TO_CFNAME_PREPARE]],

  # user-selected prefixes (g_fn_sh_,g_fn_prepare)
  # are applied to the default names, but if the user
  # specifies a name for a specific routine
  # (e.g., g_parse_prepare) the full name must given.
  [:fn], [m4_do(
    [ax_lp_check_puts($@)],
    [ax_lp_map_beta_sep([&],
      [m4_format(
        [m4_map_args_sep([ax_lp_prepend([$1],[&1]],[,[%s])], [],
          [parse], [to_cfargs], [to_cfname])],
        m4_case([[&1prefix_]],m4_dquote_elt(m4_shift($@)),
                [ax_lp_get([$1],[&1prefix_])]))], [],
      [g_prepare_], [g_fn_])],
    [ax_lp_put($@)])],

  [:vars], [[non_suffix_cfargs], [wkeys_string], [kpos_order],
            [parse_consts], [to_cfargs_consts], [to_cfname_consts]],

  [:sets],   [[kpos_seen]],
  [:hashes], [[cfarg_type], [kpos_suffixes]])

# %enable|%with|%option cfarg
#   defines shell variable (g_sh_prefix_)cfarg
L8_CF_DEFINE([%enable],
  [:parent], [],
  [:fn], [_l8_cf_make_cfarg([$1],[$2],[--enable])])

L8_CF_DEFINE([%with],
  [:parent], [],
  [:fn], [m4_do(
    [_l8_cf_make_cfarg([$1], [$2], [--with])],
    [ax_lp_append([$1], [to_cfargs_consts], [
_]ax_lp_get([$1],[g_sh_prefix_])[cfarg_is_with_$2=1])])])

L8_CF_DEFINE([%option],   # cfarg_name options.h_CPP_NAME
  [:parent], [],
  [:fn], [m4_do(
     [_l8_cf_make_cfarg([$1], [$2], [--enable-def])],
    [ax_lp_append([$1], [to_cfargs_consts], [
_]ax_lp_get([$1],[g_sh_prefix_])[actual_$2=def-$3])])])

m4_define([_l8_cf_make_cfarg],
[ax_lp_hash_has_key([$1], [cfarg_type], [$2],
  [ax_lp_fatal([$1], [cfarg '$2' already declared])],
  [ax_lp_hash_put([$1], [cfarg_type], [$2], [$3])])])

L8_CF_DEFINE([%word],   # wkey
  [:parent], [],
  [:var],  [[wkey], [$2]],
  [:vars], [[first_kpos]],
  [:fn],   [ax_lp_append([$1], [wkeys_string], [$2])])

L8_CF_DEFINE([%kpos],   # cfarg kpos_suffix
  [:parent], [%word],
  [:var],  [[kpos], m4_ifval($3, [[$2_$3]], [[$2]])],
  [:fn],
  [ax_lp_beta([&], [m4_do(
       [ax_lp_hash_has_key([$1], [cfarg_type], [$2],
         [m4_if(ax_lp_hash_get([$1], [cfarg_type], [$2]), [--with],
           [m4_ifval([$3], [ax_lp_fatal([$1],[$2 cannot have a suffix (--with)])])])],
         [ax_lp_fatal([$1], [%enable/%with/%option '$2' missing?])])],
       [ax_lp_set_add([$1], [kpos_seen], [&1], [],
         [ax_lp_fatal([$1], [%kpos '&1' twice?])])],
       [ax_lp_append([$1], [kpos_order], [&1], [ ])],
       [m4_ifval([&3],[],
         [m4_do(
           [ax_lp_put([$1], [first_kpos], [&1])],
           [ax_lp_append([$1],[to_cfname_consts],
             m4_newline()[_&2first_&1=&4])])])],
       [m4_ifval([$3],
          [ax_lp_hash_append([$1], [kpos_suffixes], [$2], [$3], [ ])],
          [ax_lp_append([$1], [non_suffix_cfargs], [$2], [ ])])])],
     ax_lp_get([$1], [kpos], [g_sh_prefix_], [first_kpos], [wkey]))])

L8_CF_DEFINE([%empty],
  [:parent], [%kpos],
  [:fn], [_l8_cf_declare_wvalue([$1],[],[$2])])

L8_CF_DEFINE([%bool],
  [:parent], [%kpos],
  [:fn], [m4_do([_l8_cf_declare_wvalue([$1], [$2], [yes])],
                [_l8_cf_declare_wvalue([$1], [$3], [no])])])

L8_CF_DEFINE([%val!],
  [:parent], [%kpos],
  [:fn], [_l8_cf_declare_wvalue([$1], [$2], [$3], [exclusive])])

L8_CF_DEFINE([%val],
  [:parent], [%kpos],
  [:fn], [_l8_cf_declare_wvalue_multi([$1], [$2], [$3])])

# <CTX>, <value wordlet>, <kpos value>, <exclusive?>
#   %val  a|b|c  whatever%
# = %val  a  whatevera
#   %val  b  whateverb
#   %val  c  whateverc
m4_define([_l8_cf_declare_wvalue_multi],
[m4_if(m4_index([$2], [|]),[-1],
  [_l8_cf_declare_wvalue([$1], [$2], [$3])],
  [m4_foreach([v], m4_split([$2], [|]),
     [_l8_cf_declare_wvalue([$1], m4_defn([v]),
        m4_bpatsubst([[$3]],[%],m4_defn([v])))])])])

# <CTX>, <value wordlet>, <kpos value>, <exclusive?>
#   does the actual identification between a
#   value wordlet and a particular setting for a kposition
m4_define([_l8_cf_declare_wvalue], [ax_lp_beta([&],
  [m4_do(
    [ax_lp_append([$1], [parse_consts],
      m4_ifval([$4],[[
_&1exclusive_wordlet_&2][$2=1]])dnl
[
_&1kval_for_&2][$2=$3
_&1kpos_for_&2][$2=&1][&3])],
    [ax_lp_append([$1], [to_cfname_consts],
      [
_&1wordlet_for_&3_$3=$2])])],
  ax_lp_get([$1], [g_sh_prefix_], [wkey], [kpos]))])


L8_CF_DEFINE([],
  [:fnend],
[l8_cf_make_fn(ax_lp_beta([&],
  [[parse the configuration name CFNAME and set &1*,
   or return a nonzero status with an error message in
   &1parse_error.]], ax_lp_get([$1],[g_sh_prefix_])),
ax_lp_get([$1],[g_prepare_parse],[parse_consts],[g_fn_parse]),
[[CFNAME]],[l8_cf_body_parse([$1])])

l8_cf_make_fn(
  [OUT= ./configure arguments for parsed cfname.],
ax_lp_get([$1],[g_prepare_to_cfargs],[to_cfargs_consts],[g_fn_to_cfargs]),
[[OUT]], [l8_cf_body_to_cfargs([$1])])

l8_cf_make_fn(
  [OUT= reconstructed parsed cfname.],
ax_lp_get([$1],[g_prepare_to_cfname],[to_cfname_consts],[g_fn_to_cfname]),
[[OUT]], [l8_cf_body_to_cfname([$1])])])


# because this annoys the shit out of me
m4_append([_AS_REQUIRE_SHELL_FN],[
])

# l8_cf_make_fn(DESCRIPTION, PREPARE_NAME, PREAMBLE,
#               SHELL_FN_NAME, FORMALS, MAKE_BODY)
m4_define([l8_cf_make_fn],
[m4_ifval([$2], [m4_defun([$2],
[AS_REQUIRE_SHELL_FN([[$4]],
  [AS_FUNCTION_DESCRIBE([$4], [$5], [$1])[
$3
]],]m4_dquote($6)[)])])])

# l8_foreach_kpos_suffix(CTX,KPOS_SUFFIX,A,PRE,BODY,POST)
# -> <repeat for each CFARG with suffixes>
#    PRE
#    [for KPOS_SUFFIX in suffixes...; do]
#       BODY{A->$}([g_sh_prefix_CFARG])
#    [done]
#    POST{A->$}([CFARG])
m4_define([l8_foreach_kpos_suffix],
[m4_pushdef([_body_], m4_translit([[[$5]]],[$3],[$]))dnl
m4_pushdef([_post_], m4_ifval([$6],[
  m4_translit([[[$6]]],[$3],[$])]))dnl
ax_lp_hash_map_keys_sep([$1], [kpos_suffixes],
  [ax_lp_beta([&], [m4_format([
  m4_ifval([$4],[[$4]
  ])[[for $2 in %s; do]]
    _body_([%s])[[
  done]]_post_([%s])],
        ax_lp_hash_get([$1],[kpos_suffixes],[&1]),
        ax_lp_get([$1],[g_sh_prefix_])[&1],
        [&1])], ],[)])dnl
m4_popdef([_body_])m4_popdef([_post_])])

m4_define([l8_cf_body_to_cfname],[ax_lp_beta([&],[[dnl
[  _l8_outparam=$][1
  _l8_out=
  _l8_wkey=
  for _l8_kpos in &2; do]
    AS_VAR_SET_IF([[_&1first_$_l8_kpos]], [
      AS_VAR_COPY([[_l8_wkey]],   [[_&1first_$_l8_kpos]])])
    AS_VAR_SET_IF([[&1$_l8_kpos]], [
      AS_VAR_COPY([[_l8_kvalue]], [[&1$_l8_kpos]])
      AS_VAR_COPY([[_l8_wvalue]], [[_&1wordlet_for_${_l8_kpos}_$_l8_kvalue]])
      AS_VAR_APPEND([[_l8_out]],  [[$_l8_wkey$_l8_wvalue]])[
      _l8_wkey=]])[
  done]
  AS_VAR_IF([[_l8_outparam]],[],[
    AS_ECHO([["$_l8_out"]])],[
    AS_VAR_COPY([[$_l8_outparam]],[[_l8_out]])])]],

     ax_lp_get([$1], [g_sh_prefix_], [kpos_order]))])

m4_define([l8_cf_body_to_cfargs],[[dnl
[  _l8_outparam=$][1
  _l8_out=]]
l8_foreach_kpos_suffix([$1], [_l8_ksuffix], [&],
[[_l8_kwds=
  _l8_sep=]],
  [AS_VAR_SET_IF([[&1_$_l8_ksuffix]],[
      AS_VAR_COPY([[_l8_kvalue]],[[&1_$_l8_ksuffix]])
      AS_VAR_APPEND([[_l8_kwds]],[[${_l8_sep}${_l8_kvalue}]])[
      _l8_sep=,]])],
  [AS_VAR_IF([[_l8_kwds]],[],[],[
    AS_VAR_APPEND([[_l8_out]],[[" --enable-&1=$_l8_kwds"]])])])dnl
ax_lp_beta([&], [[[
  for _l8_cfarg in &2; do]
    AS_VAR_SET_IF([[&1${_l8_cfarg}]], [], [[continue]])
    AS_VAR_COPY([[_l8_kvalue]],         [[&1${_l8_cfarg}]])
    AS_VAR_SET_IF([[_&1actual_${_l8_cfarg}]],[
      AS_VAR_COPY([[_l8_actual_cfarg]], [[_&1actual_${_l8_cfarg}]])],[
      AS_VAR_COPY([[_l8_actual_cfarg]], [[_l8_cfarg]])])
    AS_VAR_SET_IF([[_&1cfarg_is_with_${_l8_cfarg}]],[[
      _l8_enable=with
      _l8_disable=without]],
     [[
      _l8_enable=enable
      _l8_disable=disable]])
    AS_CASE([[$_l8_kvalue]],[[
      no]],[
        AS_VAR_APPEND([[_l8_out]],
          [[" --$_l8_disable-$_l8_actual_cfarg"]])],[[
      yes]],[
        AS_VAR_APPEND([[_l8_out]],
          [[" --$_l8_enable-$_l8_actual_cfarg"]])],
      [
        AS_VAR_APPEND([[_l8_out]],
          [[" --$_l8_enable-$_l8_actual_cfarg=$_l8_kvalue"]])])[
done]]],
            ax_lp_get([$1], [g_sh_prefix_], [non_suffix_cfargs]))dnl
[
  AS_VAR_IF([[_l8_outparam]],[],[
    AS_ECHO([["$_l8_out"]])],[
    AS_VAR_COPY([[$_l8_outparam]],[[_l8_out]])])
]])

m4_define([l8_cf_body_parse],
[l8_foreach_kpos_suffix([$1], [_l8_s], [&], [],
   [AS_UNSET([[&1_$_l8_s]])])dnl
ax_lp_beta([&],[[[
  for _l8_s in &2; do]
    AS_UNSET([[&1$_l8_s]])[
  done]]],
       ax_lp_get([$1], [g_sh_prefix_], [non_suffix_cfargs]))[[

  _l8_cfname=$][1]]dnl
dnl
_l8_break_cfname_into_wordlets([$1], [[_l8_ws]], [[_l8_cfname]])dnl
[[
  for _l8_wordlet in $_l8_ws ; do
]]dnl
ax_lp_beta([&],[[
    AS_CASE([[$_l8_wordlet]],[[
      [&2]]],[[
        _l8_set=false
        _l8_no_more=false]
        AS_VAR_COPY([[_l8_wkey]],[[_l8_wordlet]])],[[
      [&3]*]],[
        AS_IF([[$_l8_no_more]],[[
          &1parse_error="? $_l8_wordlet not allowed"
          return 1]])
        AS_VAR_SET_IF([[_&1exclusive_wordlet_$_l8_wkey$_l8_wordlet]],[
          AS_IF([[$_l8_set]],[[
            &1parse_error="? $_l8_wkey$_l8_wordlet is exclusive"
            return 1]],
          [[
            _l8_no_more=:]])])[
        _l8_set=:]&4],[[
      /]],[
        AS_IF([[$_l8_set]],[],[&5])],
      [[
        &1parse_error="? $_l8_wordlet unexpected"
        return 1]])[
  done
]]],
    ax_lp_get([$1], [g_sh_prefix_], [wkeys_string]),
    m4_defn([m4_cr_digits])m4_defn([m4_cr_letters]),
    _l8_cf_parse_setvalue([$1], [8],
        [[$_l8_wkey$_l8_wordlet]], [[not recognized]]),
    _l8_cf_parse_setvalue([$1], [10],
        [[$_l8_wkey]],             [[cannot be by itself]]))])

m4_define([_l8_cf_parse_setvalue],
  [ax_lp_beta([&],
     m4_bpatsubst([[[
AS_VAR_SET_IF([[_&1kpos_for_]$3],[
  AS_VAR_COPY([[_l8_kpos]],  [[_&1kpos_for_]$3])
  AS_VAR_COPY([[_l8_value]], [[_&1kval_for_]$3])
  AS_VAR_SET_IF([[$_l8_kpos]],[[
    &1parse_error="? ]$3[ set twice?"
    return 1]],[
    AS_VAR_COPY([[$_l8_kpos]],[[_l8_value]])])],
 [[
  &1parse_error="? ]$3 $4["
  return 1]])]]],
     [
],   m4_format([[
%*s]],[$2])),
                ax_lp_get([$1], [g_sh_prefix_]))])


# _l8_break_cfname_into_wordlets(<CTX>, <OUTVAR>, <CFNAMEVAR>)
# ------------------------------
# Emit m4sh code to break a provided cfname (value of CFNAMEVAR)
# into wkey and value wordlets and write the list to OUTVAR.
#
# I know!  We can use sed!  Now we have two problems...
# Just so that you know, this first version is 50 times too slow.
# Evidently, process creation takes a while; who knew?
# (Either that or sed sucks much harder than I originally thought.)
#
m4_define([_l8_break_cfname_into_wordlets/super-slow],
[[
  $2[=`printf "%s\n" $]$3[ | \
    sed -e 's.[ABCDEFGHIJKLMNOPQRSTUVWXYZ]. / & .g' \
        -e 's.[abcdefghijklmnopqrstuvw]. &.g' \
        -e 's. *$. /.' \
        -e 's.   *. .g' \
        -e 's.^ / *..'`
]]])
#
# so instead, we are doing this.  Bleah:
#
m4_define([_l8_break_cfname_into_wordlets],[[
  $2[=
  while : ; do]
    AS_VAR_IF([$3],[],[[
      break]])
    AS_CASE([[$]$3],[[
     [abcdefghijklmnopqrstuvw0123456789][xyz0123456789]*]],[[
       ]$2[="$]$2[ ${]$3[%%${]$3[@%:@??}}"
       ]$3[="${]$3[@%:@??}"]],[[
     [ABCDEFGHIJKLMNOPQRSTUVWXYZ]?*]],[[
       ]$2[="$]$2[ / ${]$3[%%${]$3[@%:@?}}"
       ]$3[="${]$3[@%:@?}"]],[[
     [abcdefghijklmnopqrstuvwxyz0123456789]?*]],[[
       ]$2[="$]$2[ ${]$3[%%${]$3[@%:@?}}"
       ]$3[="${]$3[@%:@?}"]],[[
     [ABCDEFGHIJKLMNOPQRSTUVWXYZ]]],[[
       ]$2[="$]$2[ / $]$3[ /"
       ]$3[=]],[[
     ?]],[[
       ]$2[="$]$2[ $]$3[ /"
       ]$3[=]],
     [
       ]]m4_dquote(m4_dquote(ax_lp_get([$1],[g_sh_prefix_])))dnl
[[[parse_error="? $]$3[ unexpected"
       return 1]])[
  done
  ]$2[="${]$2[@%:@ /}"
]]])


m4_if([

dnl m4_errprintn(m4_defn(_ax_lp_lang_prefix([CFNAME])[||:fn]))
dnl m4_errprintn(m4_defn(_ax_lp_lang_prefix([CFNAME])[||:fnend]))

m4_divert()

m4_unquote([[[a]]],[[[b]]],[[[c]]])
_ax_lp_lang_prefix([CFNAME])
m4_set_map_sep(_ax_lp_lang_prefix([CFNAME])[| _ok_par],[{],[}])
m4_defn(_ax_lp_lang_prefix([CFNAME])[| :allow])

m4_divert()
[AS_INIT]

m4_defn([_MOO_CF_PARSE_PREPARE])

m4_defn([_MOO_CF_TO_ARGS_PREPARE])

m4_defn([_MOO_CF_TO_CFNAME_PREPARE])

moo_fn_parse_cfname I32FdNxQ32bxW || echo $moo_cf_parse_error
moo_fn_parsed_cf_to_args OUT
echo "$OUT"
moo_fn_parsed_cf_to_cfname
])
