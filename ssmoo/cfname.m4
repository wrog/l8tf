L8_CFNAME_DECLARE_SCHEMA([MOO], [

  %enable   sz
  %enable   net
  %enable   unicode
  %enable   waifs

  %with     uclib
  %with     relib

  %option   bit     BITWISE_OPERATORS
  %option   bq_box  BQM_BOXED_FLOATS
  %option   bq_waif BQM_INCLUDES_WAIFS

  %word I
    %kpos    sz   i
      %val   16|32|64   i%

  %word F
    %kpos    sz   f
      %val   f    flt
      %val   d    fdbl
      %val   l    flong
      %val   q    fquad

    %kpos    sz   b
      %val   b    box
      %val   bx   unbox

  %word B
    %kpos    bit
      %empty      yes

  %word N
    %kpos    net
      %val!  x      no

    %kpos    net p
      %val   t      tcp
      %val   l      local

    %kpos    net s
      %val   b      bsd
      %val   v      sysv

    %kpos    net m
      %val   s      select
      %val   p      poll
      %val   f      fake

    %kpos    net o
      %val   ox     noout
      %val   oz     outoff
      %val   o      out

  %word Q
    %kpos   sz q
      %val h     bqhw
      %val 32|64 bq%

    %kpos   bq_box
      %bool b bx

    %kpos   bq_waif
      %bool w wx

  %word R
    %kpos   relib
      %val   y      ylo
      %val   1      pcre

  %word U
    %kpos   unicode
      %empty        yes
      %val!  x      no
    %kpos   unicode i
      %val   i      ids
    %kpos   unicode n
      %val   n      nums
    %kpos   uclib
      %val   g      gnu
      %val   j      icu
      %val   h      ucd

  %word W
    %kpos   waifs
      %empty        yes
      %val!  x      no
      %val   c      core
],
[[g_sh_prefix_], [moo_cf_], [g_fn_prefix_], [moo_fn_]])
