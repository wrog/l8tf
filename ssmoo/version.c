#include "config.h"
#include "options.h"

#include "structures.h"
#include "unparse.h"
#include "version.h"
#include "streams.h"
#include "list.h"
#include "utils.h"


static const char *label = 0;

static void
ckstring(Stream *s, Var v)
{
    if (v.type != TYPE_STR) {
        fprintf(stderr, "%s ? not a string\n", label ? label : "(null)");
        exit(1);
    }
    stream_add_string(s, v.v.str);
}

int
main(void) {
    Var v;
    Stream *s = new_stream(0);

#define unparse_bool(s,v)					\
    (stream_add_string((s),					\
	((v).type == TYPE_ERR ? error_name((v).v.err)		\
	                      : (is_true(v) ? "yes" : "no"))))
#define GETV(lbl,svfpath)  GET(lbl,svfpath,unparse_value)
#define GETB(lbl,svfpath)  GET(lbl,svfpath,unparse_bool)
#define GETS(lbl,svfpath)  label=lbl;GET(lbl,svfpath,ckstring)

#define GET(lbl,svfpath,munge)				\
  v = server_version_full(				\
        (Var){ .type=TYPE_STR, .v.str = (svfpath), });	\
  stream_add_string(s, (lbl));				\
  munge(s,v);						\
  free_var(v);						\
  stream_add_char(s, '\n');				\

    GETS("version  = ","string");
    GETS("commit   = ","source/commit");
    GETV("config   = ","config/args");
    GETV("features = ","features");
    GETV("INT_TYPE_BITSIZE   = ","options/INT_TYPE_BITSIZE");
    GETS("FLOATING_TYPE      = ","options/FLOATING_TYPE");
    GETB("BOXED_FLOATS       = ","options/BOXED_FLOATS");
    GETS("BYTE_QUOTA_MODEL   = ","options/BYTE_QUOTA_MODEL");
    GETB("BQM_BOXED_FLOATS   = ","options/BQM_BOXED_FLOATS");
    GETB("BQM_INCLUDES_WAIFS = ","options/BQM_INCLUDES_WAIFS");
    GETB("BITWISE_OPERATORS  = ","options/BITWISE_OPERATORS");

    printf("%s", reset_stream(s));
}
