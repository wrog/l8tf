# package.m4 - combined
#
#  Test Suite version
#
m4_include([package_l8tf.m4])
#
#  LambdaMOO version
#
m4_include([ssmoo/package.m4])
#
m4_define([AT_PACKAGE_BUGREPORT],[[{]]m4_defn([AT_PACKAGE_BUGREPORT])[[ (application issues)
or ]]m4_defn([L8TF_PACKAGE_BUGREPORT])[ (test suite issues)][[}]])
m4_append([AT_PACKAGE_STRING],[[(]L8TF_PACKAGE_NAME L8TF_PACKAGE_VERSION[)]],[ ])
