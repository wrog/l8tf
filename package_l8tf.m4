# package_l8tf.m4
#
#  Test Suite id and version
#
#  (It turns out that the filename 'version.m4' is reserved by m4sugar
#   so if you try to m4_include a file by that name, you get warnings.)
#
m4_define([L8TF_PACKAGE_NAME],[L8TestFrame])
m4_define([L8TF_PACKAGE_BUGREPORT],[https://github.com/wrog/l8tf/issues])
m4_define([L8TF_PACKAGE_URL],[https://wrog.net/moo/l8tf])
m4_define([L8TF_PACKAGE_VERSION],
  m4_bpatsubst(m4_dquote(
      m4_esyscmd([git describe --tags --match='v*' --dirty='?' | sed 's/-g[0-9a-f]*//'])),
    [^\(.\) *v\(.*\)
],[\1\2]))
m4_define([L8TF_PACKAGE_COMMIT],
  m4_bpatsubst(m4_dquote(
      m4_esyscmd([git rev-list --max-count=1 @])),
    [
],[]))

m4_define([L8TF_COPYRIGHT],
[Copyright 2026, Roger F. Crew.])

m4_define([L8TF_LICENSE_SHORT],
[License GPLv2+/Autoconf: GNU GPL version 2 or later
or something similar; I have not fully decided yet.  But, essentially:
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.])
