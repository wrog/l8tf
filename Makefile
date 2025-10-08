
AUTOM4TE = autom4te
AUTOTEST = $(AUTOM4TE) --language=autotest
TESTSUITE = testbuild

$(TESTSUITE): $(TESTSUITE).at local.at package.m4 version_l8tf.m4
	$(AUTOTEST) -I m4 -o $@.tmp $@.at
	mv $@.tmp $@

clean: clean-keeps-testbuild

clean-keeps-testbuild:
	rm -rf $(TESTSUITE)
