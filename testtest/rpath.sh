
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
   AS_IF([L8_REVERSE_PATH([[xxx]],[[$][1]])],
 [[  printf "%-42s =>%s<=\n" "$1" "$xxx"]],[[
     printf 'nope: %s\n' "$1"]])
}
[
try ''
try .git/branches
try .git/branches///..
try ../s2/../expat/../s2/tests
try ../s2/tests
try ../../../../../../../home/moo/src/git/s2
try ./.git/./..//single/../
try /home/moo/src/git
try /home/moo/src/git/s2/tests
try /usr/share/autoconf
]
EOF


                                           =>.<=
.git/branches                              =>../..<=
.git/branches///..                         =>..<=
../s2/../expat/../s2/tests                 =>../../l8tf<=
../s2/tests                                =>../../l8tf<=
../../../../../../../home/moo/src/git/s2   =>../l8tf<=
./.git/./..//single/../                    =>.<=
/home/moo/src/git                          =>l8tf<=
/home/moo/src/git/s2/tests                 =>../../l8tf<=
/usr/share/autoconf                        =>../../../home/moo/src/git/l8tf<=



whereami () { df . | awk 'NR>1{ print $1 }' ; ls -id . ; }
# rel_path VAR PATHNAME
#   VAR = (path from cwd to PATHNAME)
relative_pathname () {
here=.
dest=`cd "$2" 2>/dev/null && pwd`
${dest:+false} : && return 1
while `cd "$here" 2>/dev/null && pwd=$(pwd) && test "$pwd" != / && case $dest in "$pwd") false ;; "$pwd"/*) false ;; *) : ;; esac `; do
 here="$here/.."
done
( cd "$here" 2>/dev/null ) || return 1;
suffix=` cd "$here"; pwd=$(pwd); case $pwd in /) printf '%s' "${dest#/}" ;; "$dest") printf '' ;; *) x=${dest#"$pwd/"}; printf '%s' "$x" ;; esac `
here=${here#./}
if test x"$suffix" = x; then eval $1=\$here; elif test x"$here" = x.; then eval $1=\$suffix; else eval $1=\$here/\$suffix; fi
dw=$(cd "$dest"; whereami);
eval rw=\$\(cd \"\$$1\" \&\& whereami\) || return 1
test x"$dw" = x"$rw" || return 1
}


cd "/home/moo/git sources/l8tf"
# for dest in /home/moo/src/git/l8tf/.git/branches /home/moo/src/git/l8tf/.git /home/moo/src/git/l8tf /home/moo/src/git /home/moo/src/git/s2 /home/moo/src /home/moo/src/testb /home/moo /home/moo/info /home /home/rfc / /usr /usr/bin; do
for dest in '/home/moo/git sources/l8tf/.git/branches' '/home/moo/git sources/l8tf/.git' '/home/moo/git sources/l8tf' '/home/moo/git sources' '/home/moo/git sources/s2' '/home/moo/src' '/home/moo/src/testb' '/home/moo' '/home/moo/info' '/home' '/home/rfc' '/' '/usr' '/usr/bin'; do
echo
printf 'dest=%40s\n' "$dest"
relative_pathname rel "$dest" || echo FAIL
printf 'rel =%40s\n' "$rel"
done
