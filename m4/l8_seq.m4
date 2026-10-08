
# l8_fn_seq_ranges OUTVAR SEQ
# l8_fn_seq_from_list OUTVAR N...

# l8_fn_seq_not   OUTVAR SEQ
# l8_fn_seq_union OUTVAR SEQ1 SEQ2
# l8_fn_seq_diff  OUTVAR SEQ1 SEQ2


m4_defun([L8_SEQ_FNS_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_seq_ranges],[[
# l8_fn_seq_not OUTVAR SEQ
# ---------------------
# OUTVAR= complement of SEQ
#
l8_fn_seq_not () ]{
  AS_CASE([[$][2]],[[
    0_*]], [
      AS_VAR_SET([[$][1]],[[$][{2@%:@0_}]])],[[
    0]], [
      AS_VAR_SET([[$][1]],[])],
[dnl (*)
      AS_VAR_SET([[$][1]],[[0_$][2]])])
}[

# l8_fn_seq_diff OUTVAR SEQ1 SEQ2
# --------------------------
# OUTVAR= SEQ1 but removing everything in SEQ2
#
l8_fn_seq_diff () ]{[
    l8_fn_seq_not $][1 $][2
    eval l8_fn_seq_union $][1 \$$][1 \$][3
    eval l8_fn_seq_not $][1 \$$][1
]}[

# l8_fn_seq_union OUTVAR SEQ1 SEQ2
# --------------------------
# OUTVAR= union of SEQ1 and SEQ2
#
l8_fn_seq_union () ]{
  AS_VAR_SET([[$][1]],[])[
  _l8_r=$][1
  _l8_Aseq=$][2
  _l8_Bseq=$][3
  _l8_Aout=:
  _l8_Bout=false
  save_IFS=$IFS
  IFS=_
  set X $_l8_Aseq
  shift
  for _l8_B in $_l8_Bseq; do
    IFS=$save_IFS]
    L8_TOGGLE([[_l8_Bout]])[
    while test $][@%:@ -gt 0 && test $][1 -le $_l8_B; do]
      AS_IF([[test $][1 -eq $_l8_B]],[
        AS_VAR_IF([[_l8_Aout]],[[$_l8_Bout]],[
            AS_VAR_APPEND([[$_l8_r]], [["_$][1"]])])
        L8_TOGGLE([[_l8_Aout]])[
        shift
        continue 2]])
      AS_IF([[$_l8_Bout]], [AS_VAR_APPEND([[$_l8_r]], [["_$][1"]])])
      L8_TOGGLE([[_l8_Aout]])[
      shift
    done]
    AS_IF([[$_l8_Aout]], [AS_VAR_APPEND([[$_l8_r]], [["_$_l8_B"]])])[
  done
  IFS=$save_IFS]
  AS_IF([[$_l8_Bout]],[],[[
    while test $][@%:@ -gt 0; do]
      AS_VAR_APPEND([[$_l8_r]],[["_$][1"]])
      L8_TOGGLE([[_l8_Aout]])[
      shift
    done]])[
  eval "$_l8_r=\${$_l8_r@%:@_}"
]}[

# l8_fn_seq_from_list OUTVAR N1...
# --------------------------------
# OUTVAR= seq generated from N1... (assumed ordered)
#
l8_fn_seq_from_list () ]{[
  eval "$][1="
  _l8_r=$][1
  shift
  while test $][@%:@ -gt 0; do
    as_fn_arith $][1 - 1]
    AS_VAR_APPEND([[$_l8_r]],[["_$as_val"]])[
    _l8_end=$][1
    shift
    while as_fn_arith $_l8_end + 1
          test "x$as_val" = "x$][1"; do
      shift
      _l8_end=$as_val
    done]
    AS_VAR_APPEND([[$_l8_r]],[["_$_l8_end"]])[
  done
  eval "$_l8_r=\${$_l8_r@%:@_}"
]}

AS_FUNCTION_DESCRIBE([[l8_fn_seq_ranges]],[OUTVAR SEQ MAX],
[OUTVAR= whitespace separated list of ranges for SEQ
which, in turn, is taken to be a subset of 1-MAX
])],
dnl -- body of l8_fn_seq_ranges
[
    AS_VAR_SET([[$][1]],[])[
    _l8_max=$][3
    _l8_s=
    _l8_excl=:
    save_IFS=$IFS
    IFS=_
    for _l8_x in $][2; do
      IFS=$save_IFS]
      AS_IF([[$_l8_excl]],[[
        _l8_excl=false]
        AS_VAR_ARITH([[_l8_s]],[[$_l8_x \+ 1]])],[
dnl   else
[        _l8_excl=:]
        AS_VAR_IF([[_l8_x]],[[$_l8_s]],[
          AS_VAR_APPEND([[$][1]],[[" $_l8_x"]])],
[dnl    else
          AS_VAR_APPEND([[$][1]],[[" $_l8_s-$_l8_x"]])])])[
    done
    IFS=$save_IFS]
    AS_IF([[$_l8_excl || test ${_l8_s}0 -gt ${_l8_max}0]],[],
     [[test $_l8_max = $_l8_s]],[
      AS_VAR_APPEND([[$][1]],[[" $_l8_s"]])],[
dnl else
      AS_VAR_APPEND([[$][1]],[[" $_l8_s-$_l8_max"]])])])])

# L8_TOGGLE(VAR)
#   does VAR=!VAR where VAR is expected to have value ':' or 'false'
#
m4_define([L8_TOGGLE],
[AS_LITERAL_WORD_IF([$1],
[[if $]$1[; then ]$1[=false; else ]$1[=:; fi]],
[AS_VAR_COPY([[_l8_toggle]],[$1])
[if $_l8_toggle; then ]AS_VAR_SET([$1],[[false]])[; else ]AS_VAR_SET([$1],[:])[; fi]],
[[if eval \$$1; then eval ]$1[=false; else eval ]$1[=:; fi]])])
