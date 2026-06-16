/* ut-parsnum.c -- unit test for parse_number()  */

#include "config.h"
#include "options.h"

#include "numbers.h"
#include "streams.h"
#include "utf.h"
#include "utils.h"

#define PN_ACTUALMASK 0xfffff
#define PN_UNGET     0x100000  /* supply ungetch */

/*
 * Actual parse_number() error returns
 *  E_NONE   not a number (only when ungetch != NULL)
 *  E_INVARG for all other syntax errors
 *  E_RANGE  unrepresentable integer
 *  E_FLOAT  unrepresentable float

 * Other error codes repurposed for this test; update accordingly
 * if parse_number() is ever changed to actually use any of them:
 */
#define E_X_OKAY          E_QUOTA   /* initial state, no errors */
#define E_X_GET_AFTER_EOF E_PROPNF  /* getch after EOF */
#define E_X_UNGET_CHANGE  E_VERBNF  /* ungetch wrong character */
#define E_X_UNGET_TOOFAR  E_VARNF   /* ungetch past the beginning */
#define E_X_BADUTF8       E_RECMOVE /* malformed UTF8 */

static enum error my_error;

static const char *my_start;
static const char *my_next;
static const char *my_end;
static int my_eof;
static int32_t last_unget;
static FlNum last_float = -1.0;

static void
bad_unget(int32_t ch)
{
    my_error = E_X_UNGET_CHANGE;
    last_unget = ch;
}

static void
my_init(const char *str)
{
    my_start = my_next = str;
    my_end = str + strlen(str);
    my_eof = 0;
    my_error = is_utf8_cont_byte(*str) ? E_X_BADUTF8 : E_X_OKAY;
}

static int32_t
my_getch(void)
{
    if (my_error != E_X_OKAY)
	return EOF;
    if (my_eof) {
	my_error = E_X_GET_AFTER_EOF;
	return EOF;
    }
    if (my_next >= my_end) {
	++my_eof;
	return EOF;
    }
    return get_utf(&my_next);
}

static void
my_ungetch(int32_t ch)
{
    if (my_error != E_X_OKAY)
	return;
    if (my_eof) {
	if (ch == EOF)
	    my_eof = 0;
	else
	    bad_unget(ch);
    }
    else if (my_next == my_start)
	my_error = E_X_UNGET_TOOFAR;
    else {
	const char *p = my_next;
	do
	    --p;
	while (is_utf8_cont_byte(*p));
	my_next = p;
	if (ch != (int32_t)get_utf(&p))
	    bad_unget(ch);
    }
}


#define DO_TEST_TESTING_TESTS 0
#if DO_TEST_TESTING_TESTS

/* Exercise all of the code paths that the real parse_number()
 *  should not ever exercise.
 */

#define parse_number pn_fake1

/* available flags: 0xffe00 */
#define PN_K_UNGET1  0x1000
#define PN_K_UNGET2  0x2000
#define PN_K_GET2    0x4000
#define PN_K_ROBJ    0x10000

static Var
pn_fake1(unsigned flags, int32_t c_first,
	 int32_t (*getch)(void),
	 void (*ungetch)(int32_t))
{
    if (ungetch) {
	if (flags & PN_K_UNGET1)
	    (*ungetch)(c_first);
	if (flags & PN_K_UNGET2)
	    (*ungetch)('a');
    }
    else {
	(void)(*getch)();
	if (flags & PN_K_GET2)
	    (void)(*getch)();
    }
    return (flags & PN_K_ROBJ)
	? (Var){.type=TYPE_OBJ, .v.obj=42}
	: (Var){.type=TYPE_ERR, .v.err=E_INVIND};
}
#endif /* DO_TEST_TESTING_TESTS */

static void
pt_fn(Stream *s, unsigned flags, const char *str)
{
    my_init(str);

    Var result = parse_number(
       flags & PN_ACTUALMASK,
       my_getch(),
       my_getch,
       (flags & PN_UNGET) ? my_ungetch : NULL
    );
    if (my_error == E_X_OKAY && result.type == TYPE_ERR)
	my_error = result.v.err;
    stream_printf(s, "%td:", my_end - my_next);
    switch (my_error) {
    default:
	stream_printf(s, "??:: my_error=%d", my_error);
	break;
    case E_X_BADUTF8:
	stream_printf(s, "?S:: bad utf8 (0x%hhx)", str[0]);
	break;
    case E_X_GET_AFTER_EOF:
	stream_add_string(s, "EE:: get after EOF");
	break;
    case E_X_UNGET_CHANGE:
	stream_printf(s, "UX:: unget bad (0x%x)", last_unget);
	break;
    case E_X_UNGET_TOOFAR:
	stream_add_string(s, "UU:: unget too far");
	break;
    case E_INVARG:
	stream_add_string(s, "_P:: parse failed");
 	break;
    case E_NONE:
 	stream_add_string(s, "__:: no number");
 	break;
    case E_RANGE:
 	stream_add_string(s, "_R:: int range");
 	break;
    case E_FLOAT:
	stream_add_string(s, "_F:: float range");
	break;
    case E_X_OKAY:
	switch (result.type) {
	default:
	    stream_printf(s, "TX:: bad return (0x%x)",
			  result.type);
	    break;
	case TYPE_INT:
	    stream_printf(s, "_I:: %"PRIdN, result.v.num);
	    break;
	case TYPE_FLOAT:
	    FlNum f = fl_unbox(result.v.fnum);
	    stream_printf(s, "_F:%s: ",
			  last_float == f ? "=" : "");
	    stream_float_printf(s, "%.*"PRIgR,
				FLOAT_DIGITS + 4, f);
	    last_float = f;
	    free_var(result);
	    break;
	}
    }
}

static unsigned count = 0;
static unsigned errcount = 0;


static void
xp_fn(Stream *s, const char *p, unsigned line, const char *comment)
{
    size_t plen = strlen(p);
    size_t rlen = stream_length(s);
    const char *result = reset_stream(s);
    int wild = 0;
    if (strlen(p) >= 2 && 0 == strncmp(".*", p + plen - 2, 2)) {
	++wild;
	plen -= 2;
    }
    if (rlen >= plen
	&& 0 == strncmp(result, p, plen)
	&& (wild || !result[plen])) {

	printf("ok %d", ++count);
	if (comment) printf(" - %s", comment);
	printf("\n");
    }
    else {
	++errcount;
	printf("not ok %d", ++count);
	if (comment) printf(" - %s", comment);
	printf("\n");
	printf("# Failed test %d in %s at line %u\n", count, __FILE__+6, line);
	printf("#      got: '%s'\n", result);
	printf("# expected: '%s'\n", p);
    }
}

#define pt(s,flags,str,pattern)  ptc((s),(flags),(str),(pattern),0)
#define ptc(s,flags,str,pattern,comment)	\
    (pt_fn((s),(flags),(str)),			\
     xp_fn((s),(pattern),__LINE__,(comment)))	\

int
main(void)
{
    Stream *s = new_stream(32);

#if DO_TEST_TESTING_TESTS
#  if UNICODE_STRINGS
#    define U(s)  "1:?S:: bad utf8 (0x80)"
#  else
#    define U(s)  s
#  endif
    pt(s,          PN_K_UNGET1, "\200", U("0:??:: my_error=7"));
    pt(s, PN_UNGET|PN_K_UNGET1, "\200", U("1:??:: my_error=7"));
    pt(s, PN_UNGET|PN_K_UNGET2, "\200", U("1:UX:: .*"));
    pt(s, PN_UNGET|PN_K_UNGET1|PN_K_UNGET2, "\200", U("1:UU:: .*"));
    pt(s, PN_K_GET2,            "\200", U("0:EE:: .*"));
    pt(s, PN_K_ROBJ,            "\200", U("0:TX:: bad return (0x1)"));
#  undef U

#else /* !DO_TEST_TESTING_TESTS */

/*abbreviations to avoid tedium */
#define PF  PN_FLOAT_OK   /* (P)arse (F)loatstuff (. and e+nn) */
#define FF  PN_REQ_FLOAT  /* (F)orce (F)loat return */
#define FI  PN_REQ_INT    /* (F)orce (I)nteger return */
#define NN  PN_NONNEG     /* (N)on-(N)egative only (for yacc) */

/* Recall: the rest are only allowed for !ungetch */
#define OBJ PN_OCTOTHORPE  /* allow leading # for (OBJ)ect */
#define WSL PN_LDSPACE     /* (W)hite(S)pace: allow (L)eading  */
#define WST PN_TRSPACE     /* (W)hite(S)pace: allow (T)railing  */
#define WSO PN_OCTOSPACE   /* (W)hite(S)pace: allow in (O)bject */
#define WS  PN_SPACE       /* allow all (W)hite(S)pace */
#define ALL PN_MUST_EOF    /* must use (ALL) of the input */
#define UG  PN_UNGET       /* supply (U)n(G)etch */

    pt(s, UG,       "12345",   "0:_I:: 12345");
    pt(s, UG,       "12345.0", "2:_I:: 12345");
    pt(s, UG|PF,    "12345.0", "0:_F:: 12345");
    pt(s, UG|PF|FI, "12345.0", "0:_I:: 12345");
    pt(s, UG|FF,    "12345.0", "2:_F:=: 12345");
    pt(s, UG,       "+12345",  "6:__:: no number");
    pt(s, 0,        "+12345",  "5:_P:: parse failed");

#define U1 "\xf0\x9d\x9f\xb7"
#define U2 "\xf0\x9d\x9f\xb8"
#define U3 "\xf0\x9d\x9f\xb9"
#define U4 "\xf0\x9d\x9f\xba"
#define U5 "\xf0\x9d\x9f\xbb"

    pt(s, UG,   U1 U2 U3 U4 U5,
#if UNICODE_NUMBERS
"0:_I:: 12345"
#else
"20:__:: no number"
#endif
);
    pt(s, NN,        "12345",      "0:_I:: 12345");

#if   INT_TYPE_BITSIZE==64
#  define ITB3(i16,i32,i64) i64
#elif INT_TYPE_BITSIZE==32
#  define ITB3(i16,i32,i64) i32
#elif INT_TYPE_BITSIZE==16
#  define ITB3(i16,i32,i64) i16
#else
#  error weird INT_TYPE_BITSIZE
    ;
#endif

#if  FLOATING_TYPE==FT_FLOAT
#  define FDF(f32,f,d) ITB3(xxxx,f32,f)
#elif  FLOATING_TYPE==FT_DOUBLE
#  define FDF(f32,f,d) d
#endif

#define I2Nmb  FDF("2147483520","9223371487098961920","9223372036854774784")
#define I2Nmbd FDF("2147483583","9223371761976868863","9223372036854775295")
#define I2Nmbu FDF("2147483584","9223371761976868864","9223372036854775296")
#define I2Nm1  ITB3("32767","2147483647","9223372036854775807")
#define I2N    ITB3("32768","2147483648","9223372036854775808")
#define I2Np1  ITB3("32769","2147483649","9223372036854775809")
#define I2Npbu FDF("2147483776","9223372586610589696","9223372036854776832")
#define I2Npbd FDF("2147483777","9223372586610589697","9223372036854776833")


    ptc(s, NN,        I2Nm1, "0:_I:: "I2Nm1, "range tests");
    pt(s, NN,        I2N,   "0:_I:: -"I2N);
    pt(s, NN,        I2Np1, "0:_R:: int range");
    pt(s, 0,         I2Nm1, "0:_I:: "I2Nm1);
    pt(s, 0,         I2N,   "0:_R:: int range");
    pt(s, 0,         I2Np1, "0:_R:: int range");
#if INT_TYPE_BITSIZE > FLOAT_MANT_DIG
    pt(s, PF|FI|NN,  I2Nmbd".0", "0:_I:: "I2Nmb);
    pt(s, PF|FI,     I2Nmbd".0", "0:_I:: "I2Nmb);
    pt(s, PF|FI|NN,  I2Nmbu".0", "0:_F:: float range");
    pt(s, PF|FI,     I2Nmbu".0", "0:_F:: float range");
#else
    pt(s, PF|FI|NN,  I2Nm1".0", "0:_I:: "I2Nm1);
    pt(s, PF|FI,     I2Nm1".0", "0:_I:: "I2Nm1);
    pt(s, PF|FI|NN,  I2Nm1".4", "0:_I:: "I2Nm1);
    pt(s, PF|FI,     I2Nm1".4", "0:_I:: "I2Nm1);
#endif
    pt(s, PF|FI|NN,  I2N".0", "0:_F:: float range");
    pt(s, PF|FI,     I2N".0", "0:_F:: float range");
    pt(s, PF|FI,  "-"I2N".0", "0:_I:: -"I2N);
#if INT_TYPE_BITSIZE > FLOAT_MANT_DIG
    pt(s, PF|FI,  "-"I2Npbu".0", "0:_I:: -"I2N);
    pt(s, PF|FI,  "-"I2Npbd".0", "0:_F:: float range");
#else
    pt(s, PF|FI,  "-"I2N".4",    "0:_I:: -"I2N);
    pt(s, PF|FI,  "-"I2Np1".0",  "0:_F:: float range");
#endif
    pt(s, PF,       "1e99999",  "0:_F:: float range");
    pt(s, PF,       "-1e99999", "0:_F:: float range");

    pt(s, PF,       "+1",       "1:_P:: parse failed");
    pt(s, UG|PF,    "-.",       "2:__:: no number");
    pt(s, UG|PF,    "-",        "1:__:: no number");
    pt(s, UG|PF,    "-..",      "3:__:: no number");
    pt(s, UG|PF|NN, "-5",       "2:__:: no number");
    pt(s, UG|PF,    "-5",       "0:_I:: -5");
    pt(s, UG|PF|NN, "-5.0",     "4:__:: no number");

#endif /* !DO_TEST_TESTING_TESTS */

    exit(errcount ? 1 : 0);
}
