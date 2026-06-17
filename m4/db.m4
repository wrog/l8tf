AS_INIT
[
db_consts () {
  # INT OBJ STR ERR FLOAT WAIF
  _db_I=0
  _db_O=1
  _db_S=2
  _db_E=3
  _db_F=9
  _db_W=10

  # property flags
  _db_PF_r=0x1
  _db_PF_w=0x2
  _db_PF_c=0x4

  # verb flags
  _db_VF_r=0x1
  _db_VF_w=0x2
  _db_VF_x=0x4
  _db_VF_d=0x8
  #direct obj is any or this (0x30 not allowed)
  _db_VF_a=0x10
  _db_VF_t=0x20
  #indirect obj is any or this (0xc0 not allowed)
  _db_VF_A=0x40
  _db_VF_T=0x80

  # object flags (User Programmer Wizard rwf)
  _db_OF_U=0x1
  _db_OF_P=0x2
  _db_OF_W=0x4
  _db_OF_r=0x10
  _db_OF_w=0x20
  _db_OF_f=0x80

  # property value:  V... R O PF rwc
  # property def:  R "name"
  # verb def: VB "name" (owner) flags prep

  i=-2
  for e in any none
      with at infr in on from over thru
      unde behi besi for is as off; do]
    AS_VAR_SET([[_db_PR_$e]],[[$i]])
    AS_VAR_ARITH([i], [$i + 1])[
  done

  i=0
  for e in NONE TYPE DIV PERM PROPNF VERBNF VARNF INVIND
      RECMOVE MAXREC RANGE ARGS NACC INVARG QUOTA FLOAT; do]
    AS_VAR_SET([[_db_E_$e]],[[$i]])
    AS_VAR_ARITH([i], [$i + 1])[
  done
}


db_value_reset () {
  top=0
  s0=
  n0=0
}

db_value_push () {]
  AS_VAR_COPY([nt],[n$top])
  AS_VAR_ARITH([n$top],[$nt + 1])
  AS_VAR_APPEND([s$top],[["$][1"]])[
}

# db_flag (OF|PF|VF) [+]flags
db_flag () {
  db_flag_value=0
  for f in `printf "%s\n" $2 | sed 's/\B/ /g'`; do]
    AS_IF([[test x+ = "x$f"]],[[continue]])
    AS_VAR_SET_IF([_db_$1_$f],[],
      [AS_ERROR([[unknown $1 flag '$f']])])
    AS_VAR_COPY([_db__],[_db_$1_$f])
    AS_VAR_ARITH([db_flag_value],[$db_flag_value + $_db__])[
  done
}

db_line_push () {]
  AS_VAR_APPEND([$][1],[["$][2
"]])[
}

# object

db_obj_N_pa
db_obj_N_k1
db_obj_N_kn


db_add_kc () {]
# db_add_kc kc N pa|lo Nto (to $db_current_obj)
  AS_SET_VAR([[db_obj_${2}_${3}]],[[${4}]]),
  AS_VAR_SET_IF(      [[db_obj_${4}_${1}last]],[
   AS_VAR_COPY([[la]],[[db_obj_${4}_${1}last]])
   AS_SET_VAR([[db_obj_${la}_${1}n]],      [[$2]])],[
   AS_SET_VAR([[db_${4}_${1}1]],[[$2]])])
  AS_SET_VAR([[db_obj_${4}_${1}last]],[[$2]])[
}


emulate sh
printf "%s\n" ^ ! } { ? x + @ / , $ ] [ = . % :

db_ostream () {
  while test $@%:@ -gt 0  ; do]
    AS_CASE([$1],[[
 *\n*]]
 :]],[[# name ^owner +perms %prep code
   db_flag_context=VF
  ]],[[
 ,=]],[[# number ^owner +perms value
 ]],[[
 .]],[[# name ^owner +perms value
  db_flag_context=PF
  ]],[[# +flags
+*]],[[

  ]],[[
O]],[
  db_flag_context=OF
  AS_VAR_ARITH([db_current_obj],[[$db_current_obj + 1]]),
  ]],[[
O=]],[[
  db_flag_context=OF
  db_current_obj=$2
  shift
  ]],[[
Ks]],[[
  while : ; do]
    AS_CASE([[$2]],
      [[[0-9]*]],[[
        db_add_kc k $2 pa $db_current_obj]],[[
      break]])[
    shift
  done]],[[
Cs]],[[
  while : ; do]
    AS_CASE([[$2]],
      [[[0-9]*]],[[
        db_add_kc c $2 lo $db_current_obj]],[[
      break]])[
    shift
  done]],[[
Pa]],[[
  db_add_kc k $db_current_obj pa $2]],[[
Lo]],[[
  db_add_kc c $db_current_obj lo $2]])
}

db_bits () {
  while test $@%:@ -gt 0  ; do]
    AS_CASE([$1],[[
      dump]],[
        AS_IF([[test $top -gt 0]],[
          AS_ERROR([[$top missing \}(s)]])])[
        printf "%s" "$s0"
        db_value_reset]],[[
      PP]],[
        AS_VAR_COPY([_db__],[[_db_$1]])
        AS_VAR_APPEND([s0],[["$_db__
"]])],[[
      PF|OF|VF]],[[
        db_flag $1 $2
        shift]
        AS_VAR_APPEND([s0],[["$db_flag_value
"]])],[[
      \{]],[
        AS_VAR_APPEND([s$top],[["4
"]])
        AS_VAR_ARITH([top],[$top + 1])
        AS_VAR_SET([n$top],[0])],[[
      \}]],[[
        t=$top]
        AS_VAR_COPY([_db__n],[n$t])
        AS_UNSET([n$t])
        AS_VAR_COPY([_db__s],[s$t])
        AS_UNSET([s$t])
        AS_VAR_ARITH([top],[$top - 1])[
        db_value_push "$_db__n
$_db__s"]], [[
      V]],[[
        db_value_push "$2
$3
"
        shift
        shift]],[[
      I|O|S|F]],[
        AS_VAR_COPY([_db_],[_db_$1])[
        db_value_push "$_db_
$2
"
        shift]],[[
      E_*]],[
        AS_VAR_COPY([_db_],[_db_$1])[
        db_value_push "$_db_E
$_db_
"]],[[
      @]], [
        AS_IF([[test $top -gt 0]],[],
          [AS_ERROR([[filesplice (@) must be within a list {}]])])[
        a=`sed -e 'i\
2' $2`
        shift
        an=`printf "%s" "$a" | wc -l`]
        AS_VAR_ARITH([anb], [[$an '&' 1]])
        AS_IF([[test "$anb" = 1]],[
          AS_VAR_ARITH([an], [[$an + 1]])[
          a=$a'
']],[[test "x$a" != x]],[
          AS_VAR_ARITH([an], [[$an + 2]])[
          a=$a'

']])
        AS_VAR_COPY([nt],[n$top])
        AS_VAR_ARITH([n$top],[[$nt + '(' $an '/' 2 ')']])
        AS_VAR_APPEND([s$top],[["$a"]])],[[
      on]],[ # on next-obj-number
        AS_IF([[test $db_current_obj -ge "$2"]],
          AS_ERROR([[object number too small: $2]]))
        AS_VAR_ARITH([goal],[[$2 '-' 1]])[
        while test $db_current_obj -lt $goal ; do]
          AS_VAR_ARITH([db_current_obj],[[$db_current_obj + 1]])[
          db_line_push s0 "@%:@$db_current_obj recycled"
        done]],[[
      ob]],[ # ob (name) (flags) owner (Lo C1 Cn|:) (Pa K1 Kn|:)
        AS_VAR_ARITH([db_current_obj],[[$db_current_obj + 1]])[
        db_flag OF $3
        db_line_push s0 "@%:@$db_current_obj
$2

$db_flag_value
$4"]
        AS_IF([[test "x$5" = "x:"]],[
          AS_VAR_SET_IF([db_obj_${db_current_obj}_lo],[AS_VAR_COPY([lo],[db_obj_${db_current_obj}_lo])],[[lo=-1]])
          AS_VAR_SET_IF([db_obj_${db_current_obj}_c1],[AS_VAR_COPY([c1],[db_obj_${db_current_obj}_c1])],[[c1=-1]])
          AS_VAR_SET_IF([db_obj_${db_current_obj}_cn],[AS_VAR_COPY([cn],[db_obj_${db_current_obj}_cn])],[[cn=-1]])[
          db_line_push s0 "$lo
$c1
$cn"]],[[
          db_line_push s0 "$5
$6
$7"
shift
shift]])
        AS_IF([[test "x$6" = "x:"]],[
          AS_VAR_SET_IF([db_obj_${db_current_obj}_pa],[AS_VAR_COPY([pa],[db_obj_${db_current_obj}_pa])],[[pa=-1]])
          AS_VAR_SET_IF([db_obj_${db_current_obj}_k1],[AS_VAR_COPY([k1],[db_obj_${db_current_obj}_k1])],[[k1=-1]])
          AS_VAR_SET_IF([db_obj_${db_current_obj}_kn],[AS_VAR_COPY([kn],[db_obj_${db_current_obj}_kn])],[[kn=-1]])[
          db_line_push s0 "$pa
$k1
$kn"]],[[
          db_line_push s0 "$6
$7
$8"
shift
shift]])
        AS_VAR_SET_IF([db_obj_${db_current_obj}_verbs],
           [AS_VAR_COPY([sx],[db_obj_${db_current_obj}_verbs])[db_line_push s0 "$sx"]],
           [[db_line_push s0 "0"]])
        AS_VAR_SET_IF([db_obj_${db_current_obj}_propdefs],
           [AS_VAR_COPY([sx],[db_obj_${db_current_obj}_verbs])[db_line_push s0 "$sx"]],
           [[db_line_push s0 "0"]])
        AS_VAR_SET_IF([db_obj_${db_current_obj}_propvals],
           [AS_VAR_COPY([sx],[db_obj_${db_current_obj}_verbs])[db_line_push s0 "$sx"]],
           [[db_line_push s0 "0"]])])[
    shift
  done
}
]

db_consts
db_current_obj=-1
db_next=0
db_value_reset
printf "===\n"
db_bits on 5 ob 'My Favorite Object' rWPU 0 : 6 7 8 dump
printf "===\n"
