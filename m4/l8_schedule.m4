
m4_defun([L8_PARSE_SCHEDULE],
[AS_REQUIRE([AS_PREPARE])dnl
AS_REQUIRE([_L8_PARSE_SCHEDULE_PREPARE])dnl
[l8_fn_parse_schedule ]$1 $2])

m4_defun([_L8_PARSE_SCHEDULE_PREPARE],
[AS_REQUIRE_SHELL_FN([l8_fn_parse_schedule],
  [AS_FUNCTION_DESCRIBE([l8_fn_parse_schedule],[SHFN SCHEDULE...],
    [Parse the SCHEDULE and invoke shell function SHFN
    on each element.
])[
# possible arguments to SHFN:
#   open    LEVEL   PREV(==LEVEL-1)
#   close   LEVEL   PREV(==LEVEL+1)
#   keys    KEYEXP
#     change the default KEYEXP
#   include CONFIGS [KEYEXP]
#     for all CONFIGS add (KEYEXP or default)
#     and add to the current list,
#   exclude CONFIGS [KEYEXP]
#     for all CONFIGS drop (KEYEXP or all)
#     remove from current list if keyexp is empty
#   fadd  SHELLEXP KEYEXP
#     for each config satisfying SHELLEXP add KEYEXP
#   fdrop SHELLEXP KEYEXP
#     for each config satisfying SHELLEXP drop KEYEXP
#
_l8_fn__ps () ]{
  AS_CASE([[$][3]],[[
    ?*:*]],[[
      $][1 $][2 "${3%%:*}" "${3@%:@*:}"]], [[
    *[!"(),$as_cr_alnum"]*]], [[
      _l8_pserr="unexpected: ($][3)"
      return 1
    ]], [[
      $][1 $][2 "$][3"]])
}],[[
  _l8_pslvl=0
  _l8_pserr=
  _l8_psnext=$][1
  shift
  for w in "$][@"; do]
    AS_CASE([[$w]], [[
      ["("]]], [[
        _l8_p=$_l8_pslvl]
        AS_VAR_ARITH([[_l8_pslvl]], [[$_l8_pslvl '+' 1]])[
        $_l8_psnext open $_l8_pslvl $_l8_p]], [[
      [")"]]], [
        AS_IF([[test $_l8_pslvl -gt 0]],[],[[
          _l8_pserr="extra \)"
          return 1]])[
        as_fn_arith $_l8_pslvl '-' 1
        $_l8_psnext close $as_val $_l8_pslvl
        _l8_pslvl=$as_val]], [[
      :?*]], [[
        $_l8_psnext keys "${w@%:@[:]}"]], [[
      {*}:*]], [[
        w=${w@%:@[\{]}
        $_l8_psnext fadd "${w%[\}]:*}" "${w@%:@@%:@*[\}]:}"]], [[
      {*}!*]], [[
        w=${w@%:@[\{]}
        $_l8_psnext fdrop "${w%[\}]!*}" "${w@%:@@%:@*[\}]!}"]], [[
      !*]], [[
        _l8_fn__ps $_l8_psnext exclude "${w@%:@!}" || return 1
        ]], [[
        _l8_fn__ps $_l8_psnext include "$w" || return 1
    ]])[
  done]
  AS_VAR_IF([[_l8_pslvl]],[0],[],[[
    _l8_pserr="missing \)"
    return 1]])
])])
