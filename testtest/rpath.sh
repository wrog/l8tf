
_l8_fn_try_relative_reverse_path () {
  rpathv=$1
  first=:
  last=false
  prev_i=$(ls -di .)
  prev_i="${prev_i%%[	 ]*}"
  eval "$rpathv=."
  eval "from$prev_i=."
  all_inodes="$all_inodes $prev_i"
  _l8_save_IFS=$IFS
  IFS=/
  for dir in $2; do
    IFS=$_l8_save_IFS
    if $last
 then :
return 1
 fi
    case $dir in #(
      '') :
        if $first
 then :
 return 1
 fi ;; #(
      .)  : ;; #(
      ..) :
         inode=$(ls -di ..)
         inode="${inode%%[	 ]*}"
         if test $inode = $prev_i
then :
         else
# eval 'echo -n "$'"$rpathv"' (`pwd`=$prev_i)-> ($inode)"'
            cd .. || return 1
            if eval 'test x$'"from$inode != x"
then :
                eval "$rpathv"'=$from'"$inode"
            else
                rdir="$( ls -ai . | grep -E '^[	 ]*'$prev_i'[	 ]')"
                test -n "$rdir" || return 1
                y="${rdir%%[!	 ]*}"
                test -n "$y" && rdir="${rdir#$y}"
                y="${rdir%%[	 ][!	 ]*}"
                rdir="${rdir#$y?}"
                eval $rpathv=\$rdir/\$$rpathv
                eval from$inode=\$$rpathv
                all_inodes="$all_inodes $inode"
            fi
            prev_i=$inode
# eval 'echo $'"$rpathv"
         fi
      ;; #(
      *) :
        if test ! -d "$dir"
 then :
          last=:
        else
          cd "$dir" || return 1
          inode=$(ls -di ..)
          inode="${inode%%[	 ]*}"
          if test $inode != $prev_i
 then :  return 1
 fi
          prev_i=$(ls -di .)
          prev_i="${prev_i%%[	 ]*}"
          if eval 'test x$'"from$prev_i != x"; then :
              eval "$rpathv"'=$from'"$prev_i"
          else
              eval "$rpathv"'=../$'"$rpathv"
              eval "from$prev_i="'$'"$rpathv"
              all_inodes="$all_inodes $prev_i"
          fi
        fi
      ;;
    esac
    first=false
  done
  eval "$rpathv"'=${'"$rpathv"'%/.}'
  return 0
}

l8_fn_reverse_path () {
  rpathv=$1
  here=`pwd`
  if _l8_fn_try_relative_reverse_path $1 $2
 then :
else
  eval "$rpathv"'=$here'
 fi
  for inode in $all_inodes; do
    unset from$inode
  done
  unset all_inodes
  cd "$here"
}

try () {
    l8_fn_reverse_path xxx "$1"
    printf "%-42s =>%s<=\n" "$1" "$xxx"
}

try .git/branches
try .git/branches///..
try ../s2/../expat/../s2/tests
try ../s2/tests/xx
try ../s2/tests/xx/yy
try ../../../../../../../home/moo/src/git/s2
try ./.git/./..//single/../

exit 0
autom4te -l m4sh - <<\EOF | sh -s
m4_include([m4/l8_revpath.m4])
AS_INIT
for ivar in 1054930 1054931 1054932 054931 105493 ; do
_L8_GET_INAME([[fvar]],[[$ivar]],
[[printf "** %s not found **\n" "$ivar"; continue]])[
printf "%s -> %s\n" "$ivar" "$fvar"]
done
EOF

cd ..
autom4te -l m4sh - <<\EOF | sh -s
m4_include([m4/l8_revpath.m4])
AS_INIT
[try () ]{
    L8_REVERSE_PATH([[xxx]],[[$][1]])[
    printf "%-42s =>%s<=\n" "$1" "$xxx"]
}
[
try ''
try .git/branches
try .git/branches///..
try ../s2/../expat/../s2/tests
try ../s2/tests/xx
try ../s2/tests/xx/yy
try ../../../../../../../home/moo/src/git/s2
try ./.git/./..//single/../
try /home/moo/src/git
try /home/moo/src/git/s2/tests/xx
try /usr/share/autoconf
]
EOF


                                           =>.<=
.git/branches                              =>../..<=
.git/branches///..                         =>..<=
../s2/../expat/../s2/tests                 =>../../l8tf<=
../s2/tests/xx                             =>../../l8tf<=
../s2/tests/xx/yy                          =>/home/moo/src/git/l8tf<=
../../../../../../../home/moo/src/git/s2   =>../l8tf<=
./.git/./..//single/../                    =>.<=
/home/moo/src/git                          =>l8tf<=
/home/moo/src/git/s2/tests/xx              =>../../l8tf<=
/usr/share/autoconf                        =>../../../home/moo/src/git/l8tf<=
