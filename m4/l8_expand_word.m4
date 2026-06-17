
m4_defun([L8_EXPAND_WORDEXP],
[AS_REQUIRE([_L8_EXPAND_WORDEXP_PREPARE])dnl
[l8_fn_expand_wordexp ]$1 $2])

m4_defun([_L8_EXPAND_WORDEXP_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_expand_wordexp],
  [AS_FUNCTION_DESCRIBE([l8_fn_expand_wordexp],[WORDEXP OUT],
    [Generate a list of words from WORDEXP.
    (whitespace separates alternates, parens group
    subexpressions, all other characters are literals:
    'a(b c)(d ef)' -> 'abd' 'abef' 'acd' 'acef');
    OUT, if provided is a variable to append them to;
    otherwise the list is printed to stdout.
])],
[AS_IF([[test $][@%:@ -gt 1]],[[
  out=$][2
]],[[
  out=]])[
op0=:push
beg1=0
str="$][1"\)
here=1
lvl=1
while test "x$str" != x; do]
  AS_CASE([[$str]],[[
    \(*]],[
      AS_VAR_SET([[op$here]],  [[:push]])
      AS_VAR_ARITH([[lvl]],    [[$lvl '+' 1]])
      AS_VAR_COPY([[beg$lvl]], [[here]])[
      str=${str@%:@?}]],[[
    \)*]],[
      AS_VAR_IF([[lvl]],[[0]],[
        AS_ERROR([[too many closing parens]])])
      AS_VAR_COPY(  [[b]],       [[beg$lvl]])
      AS_UNSET(     [[beg$lvl]])
      AS_VAR_SET_IF(  [[prev$lvl]],[
        AS_VAR_COPY(  [[p]],       [[prev$lvl]])
        AS_UNSET(     [[prev$lvl]])
        AS_VAR_SET(   [[op$p]],    [[:last]])
        AS_VAR_COPY(  [[end$b]],   [[here]])
        AS_UNSET(   [[p]])
      ],[
        AS_VAR_SET( [[op$b]],     [[:noop]])])
      AS_UNSET(     [[b]])
      AS_VAR_ARITH( [[lvl]], [[lvl '-' 1]])[
      str=${str@%:@?}
      continue]],[[
    ' '*]],[
      AS_VAR_COPY([[prev$lvl]], [[here]])
      AS_VAR_SET( [[op$here]],  [[:next]])[
      abc="${str%%[! ]*}"
      str="${str@%:@$abc}"
    ]],[[
      abc="${str%%[() ]*}"]
      AS_VAR_COPY([[op$here]], [[abc]])[
      str="${str@%:@$abc}"]])
  AS_VAR_ARITH([[here]], [[$here '+' 1]])[
done]
AS_VAR_IF([[lvl]],[[0]],[],[
  AS_ERROR([[too many open parens ($lvl)]])])
AS_VAR_SET([[op$here]],[[:end]])[
here=0
head=
depth=0
chn=0
while : ; do]
  AS_VAR_COPY([[op]], [[op$here]])
  AS_CASE([[$op]],[[
    :noop]],[
      AS_VAR_ARITH([[here]],[[$here + 1]])],[[
    :push]],[
      AS_VAR_COPY(  [[pos$chn]],    [[restart]])
      AS_UNSET(     [[restart]])
      AS_VAR_COPY(  [[rd$chn]],     [[rdepth]])
      AS_UNSET(     [[rdepth]])
      AS_VAR_ARITH( [[chn]],        [[$chn + 1]])
      AS_VAR_COPY(  [[prefix$chn]], [[head]])
      AS_VAR_COPY(  [[after$chn]],  [[end$here]])
      AS_VAR_COPY(  [[parent$chn]], [[depth]])
      AS_VAR_COPY(  [[depth]],      [[chn]])
      AS_VAR_ARITH( [[here]],       [[$here + 1]])],[[
    :next]],[
      AS_VAR_IF( [[depth]], [[$chn]],[
        AS_VAR_ARITH( [[restart]], [[$here + 1]])
        AS_VAR_SET(   [[rdepth]],  [[$chn]])])
      AS_VAR_COPY( [[here]],  [[after$depth]])
      AS_VAR_COPY( [[depth]], [[parent$depth]])[
    ]],[[
    :last]],[
      AS_VAR_IF( [[depth]], [[$chn]],[
        AS_VAR_ARITH( [[restart]], [[$here + 1]])
        AS_VAR_COPY(  [[rdepth]],  [[parent$depth]])])
      AS_VAR_COPY( [[here]],  [[after$depth]])
      AS_VAR_COPY( [[depth]], [[parent$depth]])[
    ]],[[
    :end]],[
      AS_VAR_IF( [[out]], [], [
        AS_ECHO([["$head"]])
      ],[
        AS_VAR_APPEND( [[$out]], [[$head]])])
      AS_VAR_IF([[chn]],[0],[[
        break]])
      AS_VAR_COPY( [[head]],  [[prefix$chn]])
      AS_VAR_COPY( [[here]],  [[restart]])
      AS_VAR_COPY( [[depth]], [[rdepth]])
      AS_IF([[test $rdepth -ne $chn]],[
        AS_UNSET(     [[parent$chn]])
        AS_UNSET(     [[after$chn]])
        AS_UNSET(     [[prefix$chn]])
        AS_VAR_ARITH( [[chn]],     [[$chn '-' 1]])
        AS_VAR_COPY(  [[rdepth]],  [[rd$chn]])
        AS_UNSET(     [[rd$chn]])
        AS_VAR_COPY(  [[restart]], [[pos$chn]])
        AS_UNSET(     [[pos$chn]])])
    ],[
      AS_VAR_APPEND( [[head]], [[$op]])
      AS_VAR_ARITH(  [[here]], [[$here + 1]])])[
done]])])
