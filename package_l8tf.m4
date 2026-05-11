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
