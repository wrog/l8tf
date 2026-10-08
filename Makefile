AUTOM4TE = autom4te
M4_SRCS = m4/ax_lp.m4 m4/l8_optarg.m4 m4/l8_optmd.m4 m4/l8_script.m4

all: install-l8tf.sh Install_L8TF.md

install-l8tf.sh: install-l8tf.m4 $(M4_SRCS)
	$(AUTOM4TE) -l m4sh install-l8tf.m4 >$@ && chmod +x $@

Install_L8TF.md: install-l8tf-opt.m4 $(M4_SRCS)
	{ printf 'm4_include(%s)\n' $(M4_SRCS) install-l8tf-opt.m4 ;\
          printf '%s\n' 'L8_OPT_USE([MD],[OUT], m4_defn([INSTALL_L8TF_OPTS]))m4_divert()m4_unquote(m4_defn([OUT]))dnl'; \
        } | $(AUTOM4TE) -l m4sugar - >$@

init-guidance:
	{ printf 'm4_include(%s)\n' $(M4_SRCS) install-l8tf-opt.m4 ;\
          printf '%s\n' 'L8_OPT_USE([INITS],[OUT], m4_defn([INSTALL_L8TF_OPTS]))m4_divert()m4_unquote(m4_defn([OUT]))dnl'; \
        } | $(AUTOM4TE) -l m4sugar -


../s2/tests/runall: runall.m4 $(M4_SRCS) ../s2/tests/paths.m4
	cat ../s2/tests/paths.m4 runall.m4 | $(AUTOM4TE) -l m4sh - >$@ && chmod +x $@


RunAll.md: runall-opt.m4 $(M4_SRCS)
	{ printf 'm4_include(%s)\n' $(M4_SRCS) runall-opt.m4 ;\
          printf '%s\n' 'L8_OPT_USE([MD], [OUT], m4_defn([RUNALL_OPTS]))m4_divert()m4_unquote(m4_defn([OUT]))dnl'; \
        } | $(AUTOM4TE) -l m4sugar - >$@



# remove implicit rule that rewrites install-l8tf
%: %.sh
