AUTOM4TE = autom4te

all: install-l8tf.sh Install_L8TF.md

install-l8tf.sh: install-l8tf.m4 m4/ax_lp.m4 m4/l8_optarg.m4 install-l8tf-opt.m4
	$(AUTOM4TE) -l m4sh install-l8tf.m4 >$@ && chmod +x $@

Install_L8TF.md: install-l8tf-opt.m4 m4/l8_optarg.m4 m4/l8_optmd.m4
	{ printf 'm4_include(%s)\n' m4/ax_lp.m4 m4/l8_optarg.m4 m4/l8_optmd.m4 install-l8tf-opt.m4 ;\
          printf '%s\n' 'L8_OPT_USE([MD],[OUT], m4_defn([INSTALL_L8TF_OPTS]))m4_divert()m4_unquote(m4_defn([OUT]))dnl'; \
        } | $(AUTOM4TE) -l m4sugar - >$@

init-guidance:
	{ printf 'm4_include(%s)\n' m4/ax_lp.m4 m4/l8_optarg.m4 install-l8tf-opt.m4 ;\
          printf '%s\n' 'L8_OPT_USE([INITS],[OUT], m4_defn([INSTALL_L8TF_OPTS]))m4_divert()m4_unquote(m4_defn([OUT]))dnl'; \
        } | $(AUTOM4TE) -l m4sugar -

# remove implicit rule that rewrites install-l8tf
%: %.sh
