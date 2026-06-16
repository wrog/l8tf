/* ut-dbio.c -- unit test for dbio_read_*() and dbio_scxnf()  */

#include "config.h"
#include "options.h"

#include "my-string.h"

#include "db_io.h"
#include "db_private.h"
#include "log.h"
#include "streams.h"
#include "utf.h"
#include "utf-ctype.h"

#pragma GCC diagnostic ignored "-Wunused-function"


/*  FIX -- This assumes uintmax_t is 32 or 64,
 *  will need to rewrite if we ever get 128-bit integers
 */

#define TEST_FIND_BAD_WRITES 0
#define TEST_FBW_PRETEND_32 0

#if TEST_FIND_BAD_WRITES
#  if TEST_FBW_PRETEND_32
/*  Pretend we are in 32-bit Land.
    Only for find_bad_writes() and test_find_bad_writes() */
#    define uintmax_t uint32_t
#    undef PRIxMAX
#    define PRIxMAX   "x"
#  endif
#endif

#define VALUES_MAX 5
#define VALUES_SIZE (2*VALUES_MAX+1)
uintmax_t value_memory[VALUES_SIZE];
#define GARBAGE32 (0xdeadbeef)
#define GARBAGEMAX ((((uintmax_t)UINT32_MAX)+2)*GARBAGE32)

static uintmax_t umask32 = -1;
static uintmax_t umask16 = -1;
static uintmax_t umask8 = -1;

static void
initmasks(void)
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
    ((uint32_t *)&umask32)[0] = 0;
    ((uint16_t *)&umask16)[0] = 0;
    ((uint8_t *) &umask8)[0] = 0;
#pragma GCC diagnostic pop
}

static void
reset_values(void)
{
    unsigned i;
    for (i=0; i<VALUES_SIZE; ++i)
	value_memory[i] = GARBAGEMAX;
}
/* words to NOT test (0,2,4,6,8,10 are always zero) */
#define VMASK1   (1U<<1)
#define V2       (1U<<3)
#define V3       (1U<<5)
#define V4       (1U<<7)
#define V5       (1U<<9)
#define FAIL_BADWR    0x7ff
#define FAIL_SUCCEED 0x1000
#define FAIL_DIAG    0x2000

/* parts of word #1 to test */
#define VMASK1_32 (0U)
#define VMASK1_64 (1U<<23)
#define VMASK1_16 (1U<<24)
#define VMASK1_8  (VMASK1_64|VMASK1_16)
#define VMASK1_SZ  VMASK1_8

static uintmax_t my_oobdata;

static unsigned
find_bad_writes(unsigned mask)
{
    unsigned i, mb;
    my_oobdata = 0ULL;
    for (i=0, mb=1; i<VALUES_SIZE; ++i, mb<<=1) {
	if (!(mask&mb)) {
	    if (value_memory[i] != GARBAGEMAX)
		return ((my_oobdata = value_memory[i]), mb);
	}
	else if (mb > VMASK1) {
	    if ((value_memory[i]&umask32) != (GARBAGEMAX&umask32))
		return ((my_oobdata = value_memory[i]), mb+1);
	}
    }
    if (mask & VMASK1) {
	switch (mask & VMASK1_SZ) {
	default:
	    /* cannot happen */
	    break;
	case VMASK1_8:
	    if ((value_memory[1]&umask8) == (GARBAGEMAX&umask8))
		return 0;
	    break;
	case VMASK1_16:
	    if ((value_memory[1]&umask16) == (GARBAGEMAX&umask16))
		return 0;
	    break;
	case VMASK1_32:
	    if ((value_memory[1]&umask32) == (GARBAGEMAX&umask32))
		return 0;
	    break;
	case VMASK1_64:
	    return 0;
	}
	my_oobdata = value_memory[1];
	return (mask & (VMASK1|VMASK1_SZ));
    }
    return 0;
}


static void
test_find_bad_writes(void)
{
    Stream *s = new_stream(0);
    unsigned mask[] = {
	VMASK1|VMASK1_64,
	VMASK1|VMASK1_32,
	VMASK1|VMASK1_16,
	VMASK1|VMASK1_8,
	V2,
	V3,
	V4,
	V3|V4,
	V5,
	V5|VMASK1|VMASK1_8,
	0,
	1
    };

    printf("umask32 = 0x%"PRIxMAX"\n", umask32);
    printf("umask16 = 0x%"PRIxMAX"\n", umask16);
    printf("umask8  = 0x%"PRIxMAX"\n", umask8);
    unsigned *m;
    for (m = mask; *m != 1; ++m) {
	unsigned b;
	for (b = 0; b < (sizeof value_memory); ++b) {
	    reset_values();
	    ((char *)value_memory)[b] = '\n';
	    if (!find_bad_writes(*m))
		stream_printf(s, ",%u", b);
	}
	printf("%8x => %s\n", *m, reset_stream(s));
    }
    free_stream(s);
}
/*
what test_find_bad_writes() *should* produce This is listing all of
the bytes where changes are *supposed* to be happening.
(FIX -- Someone needs to run this on a bigendian machine.)

--------------- TEST_FBW_PRETEND_32=0 results
umask32 = 0xffffffff00000000
umask16 = 0xffffffffffff0000
umask8  = 0xffffffffffffff00
  800002 => ,8,9,10,11,12,13,14,15
       2 => ,8,9,10,11
 1000002 => ,8,9
 1800002 => ,8
       8 => ,24,25,26,27
      20 => ,40,41,42,43
      80 => ,56,57,58,59
      a0 => ,40,41,42,43,56,57,58,59
     200 => ,72,73,74,75
 1800202 => ,8,72,73,74,75
       0 =>

--------------- TEST_FBW_PRETEND_32 results ------
umask32 = 0x0
umask16 = 0xffff0000
umask8  = 0xffffff00
  800002 => ,4,5,6,7
       2 => ,4,5,6,7
 1000002 => ,4,5
 1800002 => ,4
       8 => ,12,13,14,15
      20 => ,20,21,22,23
      80 => ,28,29,30,31
      a0 => ,20,21,22,23,28,29,30,31
     200 => ,36,37,38,39
 1800202 => ,4,36,37,38,39
       0 =>
*/

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"

/* static Num * vptr1_num = (Num *)(value_memory+1); */
#define DBIO_DO_(FOO,foo_t,foo,_4)			\
static foo_t *vptr1_##foo = (foo_t *)(value_memory+1);	\

DBIO_INT_TYPE_LIST(DBIO_DO_)
#undef DBIO_DO_

static int *vptr2_int = (int *)(value_memory+3);
static int *vptr3_int = (int *)(value_memory+5);
static int *vptr4_int = (int *)(value_memory+7);
static int *vptr5_int = (int *)(value_memory+9);

#pragma GCC diagnostic pop


#define V1_UNUM V1_NUM
#if NUM_MAX == INT32_MAX
#  define V1_NUM   (VMASK1|VMASK1_32)
#elif NUM_MAX == INT16_MAX
#  define V1_NUM   (VMASK1|VMASK1_16)
#else
#  define V1_NUM   (VMASK1|VMASK1_64)
#endif

#if TASK_MAX == NUM_MAX
#  define V1_TASK V1_NUM
#else
#  define V1_TASK (VMASK1|VMASK1_32)
#endif

#define V1_INTMAX   (VMASK1|VMASK1_64)
#define V1_UINT16    V1_INT16
#define V1_INT16    (VMASK1|VMASK1_16)
#define V1_ERR      (VMASK1|VMASK1_32)
#define V1_UINT      V1_INT
#if   INT_MAX == INT64_MAX
#  define V1_INT   (VMASK1|VMASK1_64)
#elif INT_MAX == INT32_MAX
#  define V1_INT   (VMASK1|VMASK1_32)
#elif INT_MAX == INT16_MAX
#  define V1_INT   (VMASK1|VMASK1_16)
#else
#  error "int is weird integer size?"
#endif


/*
 * the script
 */
static const char *my_script = __FILE__;
static unsigned my_line = 0;
static const char *my_comment = NULL;

/*
 * the log (for test_dbio_read_*())
 */
static FILE *my_log = NULL;
static const char *my_log_buffer;
static size_t my_log_size;

static void
reset_log(void)
{
    if (!my_log) {
	my_log = open_memstream((char **)&my_log_buffer, &my_log_size);
	if(!my_log) {
	    perror("open_memstream");
	    exit(2);
	}
	/* setbuf(my_log, NULL); segfaults, don't do this. */
	set_log_file(my_log);
    }
    else {
	rewind(my_log);
    }
    fputc(0, my_log);
    fflush(my_log);
    rewind(my_log);
}

static void
close_log(void)
{
    fclose(my_log);
    my_log = NULL;
    free((char *)my_log_buffer);
    my_log_buffer = NULL;
}


/*
 * stdin
 */
static FILE *my_stdin = NULL;

static void
close_input(void)
{
    if (my_stdin) {
	if (0 != fclose(my_stdin)) {
	    perror("fclose input");
	    exit(2);
	}
    }
    my_stdin = NULL;
}

static void
rewind_input(void)
{
    if (!my_stdin) {
	fprintf(stderr, "rewind_input(): no input\n");
	exit(2);
    }
    rewind(my_stdin);
}

static void
set_input(const char *str)
{
    close_input();
    my_stdin = fmemopen((char *)str, strlen(str), "r");
    if (!my_stdin) {
	perror("fmemopen");
	exit(2);
    }
    dbpriv_set_dbio_input(my_stdin);
}


static unsigned my_mask = 0;
static const char *my_pattern;
static unsigned my_oob;
static int my_result;


#define DBIO_DO_(INTXX,intxx_t,intxx,_4)			\
static void							\
test_dbio_read_##intxx(void)					\
{								\
    reset_values();						\
    reset_log();						\
    my_result = dbio_read_##intxx(vptr1_##intxx);		\
    my_oob = find_bad_writes(my_result ? V1_##INTXX : 0);	\
}								\

DBIO_INT_TYPE_LIST(DBIO_DO_)
#undef DBIO_DO_


#define DBIO_DO_(INTXX,intxx_t,intxx,_4)		\
static void						\
test_dbio_scxnf_##intxx(void)				\
{							\
    reset_values();					\
    my_result = dbio_scxnf(				\
	my_pattern, vptr1_##intxx,			\
	vptr2_int, vptr3_int, vptr4_int, vptr5_int);	\
    my_oob = find_bad_writes(my_mask);			\
}							\

DBIO_INT_TYPE_LIST(DBIO_DO_)
#undef DBIO_DO_
    ;

static unsigned count = 0;

static int
ok(int ok)
{
    if (my_oob)
	ok=0;
    printf("%sok %d", ok ? "" : "not ", ++count);
    if (my_comment) {
	printf(" - %s", my_comment);
	my_comment = NULL;
    }
    printf("\n");
    if (ok && !my_oob)
	return 1;
    printf("# Failed test %d in %s at line %u\n",
	   count, my_script+6, my_line);
    if (my_oob) {
	printf("# out-of-bounds write: %x (%jx)\n", my_oob, my_oobdata);
	my_oob=0;
	return 1;
    }
    return 0;
}

static void
expect_int(const char *what, intmax_t got, intmax_t expected)
{
    if (!ok(got == expected)) {
	printf("# %8s: %jd\n", what, got);
	printf("# %8s: %jd\n", "expected", expected);
    }
}

static void
print_expected(const char *what, const char *str, size_t limit)
{
    if (!str)
	printf("# %8s NULL\n", what);
    else if (!str[0])
	printf("# %8s BLANK\n", what);
    else {
	Stream *s = new_stream(0);
	const unsigned char *here = (const unsigned char *)str;
	const unsigned char *end = here + limit;
	while (here < end) {
	    uint32_t c = *here;
	    switch (c) {
	    default:
#if UNICODE_STRINGS
		size_t cl = clearance_utf(c);
		if (cl > 1 && end - here >= (ptrdiff_t)cl) {
		    const unsigned char *h = here;
		    c = get_utf((const char **)&here);
		    if (c == INVALID_RUNE) {
			c = h[0];
			here = h+1;
		    }
		}
		else
#endif
		    ++here;
#if UNICODE_STRINGS
		if (c <= 0xff) {
#endif
		    if (' ' <= c && c <= '~')
			stream_add_char(s, c);
		    else
			stream_printf(s, "\\x%02x", c);
#if UNICODE_STRINGS
		}
		else if (my_is_printable(c))
		    stream_add_utf(s, c);
		else
		    stream_printf(s, "\\U{%x}", c);
#endif
		continue;

	    case 0:
		goto done;
	    case '\\':
		stream_add_string(s,"\\\\");
		break;
	    case '\a':
		stream_add_string(s,"\\a");
		break;
	    case '\b':
		stream_add_string(s,"\\b");
		break;
	    case '\t':
		stream_add_string(s,"\\t");
		break;
	    case '\n':
		stream_printf(s,"\n#%11s","");
		break;
	    case '\v':
		stream_add_string(s,"\\v");
		break;
	    case '\f':
		stream_add_string(s,"\\f");
		break;
	    case '\r':
		stream_add_string(s,"\\r");
		break;
	    }
	    ++here;
	}
	stream_add_string(s,"...");
    done:
	printf("# %8s: %s\n", what, reset_stream(s));
	free_stream(s);
    }
}

/*
 * expect_string -  EXPECTED can end with .* or .+
 */
static void
expect_string(const char *what, const char *got, const char *expected)
{
    size_t elen = -1;
    int o = -1;
    if (!expected)
	o = ok(!got);
    else if (!(elen = strlen(expected)))
	o = ok(got && !*got);
    else if (elen >= 2
	     && '.' == expected[elen-2]
	     && (   '*' == expected[elen-1]
		 || '+' == expected[elen-1]))
	o = ok(got
	       && (0 == strncmp(got,expected,elen-2)
		   && ('*' == expected[elen-1]
		       || got[elen-2])));
    else
	o = ok(got
	       && (0 == strncmp(got,expected,elen)));
    if(o)
	return;
    print_expected(what, got, elen);
    print_expected("expected", expected, elen);
}

static void
expect_log(const char *expected)
{
    fflush(my_log);
    const char *got =
	(my_log_buffer && strlen(my_log_buffer)>17)
	? my_log_buffer+17 : my_log_buffer;
    expect_string("log", got, expected);
}

/*
  Fn(..N..) - define input
  In  - define/open input
  P(n,"...")     - define/use scxnf pattern
  Rt,!Rt - dbio_read_(type) expect (fail)
  Sn,!Sn - scxnf expect
  Vn(..) - value expect
*/

int
main(void)
{
    initmasks();

#if TEST_FIND_BAD_WRITES
    test_find_bad_writes();
#endif
#if TEST_PRINT_EXPECTED
    print_expected("null", NULL, 10);
    print_expected("blank", "", 10);
    print_expected("fred", "fred", 10);
    print_expected("long", "fredfredfredfred", 10);
    print_expected("nl", "fredfred\nfredfred", 30);
    print_expected("dos", "fredfred\r\nfredfred", 30);
    print_expected("escs", "actual tab:\t\nesctab \\t", 30);
    print_expected("", "fred\a\b\t\v\ffred", 30);
    print_expected("uni", "fred𝟏𝟐𝟑\U0001ffff", 50);
    print_expected("uni1", "fred\xf0\x9d\x9f\x8f", 50);
    print_expected("baduni1", "fred\xf0\x9d\x9f", 50);
    print_expected("baduni2", "fred\xf0\x9d", 50);
    print_expected("baduni3", "fred\xf0", 50);
    print_expected("baduni4", "fred\x9d", 50);

    my_line = __LINE__;
    expect_string("t","hello world","hello world");
    expect_string("t","hello world","hello world.+");
    expect_string("t","hello world","hello world.*");
    expect_string("t","hello world","hell.+");
    expect_string("t","hello world","hell.*");

#endif
#if !TEST_TEST
    set_input("5");
    my_line = __LINE__;
    test_dbio_read_err();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Unexpected end of file");

    set_input("2\n");
    my_line = __LINE__;
    test_dbio_read_err();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_err,2);
    expect_log("");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_int();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_int,2);
    expect_log("");

    set_input("-12345\n");
    my_line = __LINE__;
    test_dbio_read_err();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer must be uns.*");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_int16,-12345);
    expect_log("");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_uint16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer must be uns.*");

    set_input("65537\n");
    my_line = __LINE__;
    test_dbio_read_err();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer too large.*");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer too large.*");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_uint16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer too large.*");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_int();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_int,65537);
    expect_log("");

    set_input("10983274019328470183294019832470918327410329847\n");
    test_dbio_read_intmax();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer overflow on read.*");

    set_input("-32769\n");
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer too negative.*");

    set_input("biteme\n");
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer expected.*");

    set_input("3.14159\n");
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Did not read entire line.*");

    set_input("3 \n");
    my_line = __LINE__;
    test_dbio_read_int16();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Did not read entire line.*");

#if   INT_TYPE_BITSIZE==64
#  define ITB(i16,i32,i64) i64
#elif INT_TYPE_BITSIZE==32
#  define ITB(i16,i32,i64) i32
#elif INT_TYPE_BITSIZE==16
#  define ITB(i16,i32,i64) i16
#else
#  error weird INT_TYPE_BITSIZE
    ;
#endif
#if  NUM_MAX == INTMAX_MAX
#  define ITOOBIG(s) "Integer overflow on read"
#else
#  define ITOOBIG(s) s
#endif

    set_input(ITB("32767\n","2147483647\n","9223372036854775807\n"));
    my_line = __LINE__;
    test_dbio_read_num();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_num,
	       ITB(32767,2147483647,9223372036854775807));
    expect_log("");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_unum();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_unum,
	       ITB(32767,2147483647,9223372036854775807));
    expect_log("");

    set_input(ITB("-32768\n","-2147483648\n","-9223372036854775808\n"));
    my_line = __LINE__;
    test_dbio_read_num();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_num,
	       ITB(-32768,(-2147483647 -1),(-9223372036854775807L -1)));
    expect_log("");

    rewind_input();
    my_line = __LINE__;
    test_dbio_read_unum();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: Integer must be unsigned.*");

    set_input(ITB("32768\n","2147483648\n","9223372036854775808\n"));
    my_line = __LINE__;
    test_dbio_read_unum();
    expect_int("result",my_result,0);
    expect_log("*** DBIO_READ_INTEGER: "ITOOBIG("Integer too large")".*");


    my_pattern = "hey %"SCNdN" there";
    set_input("hey 500 there");
    my_line = __LINE__;
    my_mask = 0;
    test_dbio_scxnf_num();
    expect_int("result",my_result,0);
    expect_string("reason",dbio_last_error,"premature EOF");

    set_input("hey 500 ther\n");
    my_line = __LINE__;
    my_mask = V1_NUM;
    test_dbio_scxnf_num();
    expect_int("result",my_result,0);
    expect_int("value",*vptr1_int,500);  /** UNSPECIFIED **/
    expect_string("reason",dbio_last_error,"could not match entire format");

    set_input("hey 500 theree\n");
    my_line = __LINE__;
    my_mask = V1_NUM;
    test_dbio_scxnf_num();
    expect_int("result",my_result,0);
    expect_int("value",*vptr1_int,500);  /** UNSPECIFIED **/
    expect_string("reason",dbio_last_error,"unexpected junk at end-of-line");


    set_input("hey 500 there\nhey 600 there\nhow there\n");
    my_mask = V1_NUM;
    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_int,500);

    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);
    expect_int("value",*vptr1_int,600);

    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,0);
    expect_string("reason",dbio_last_error,"character mismatch");

    set_input("hey 500 there\nhey 600 there\n");
    my_pattern = "\vhey %"SCNdN" there";
    my_mask = V1_NUM;
    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,2);
    expect_int("value",*vptr1_num,500);
    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,2);
    expect_int("value",*vptr1_num,600);
    my_line = __LINE__;
    my_mask = 0;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);
    my_line = __LINE__;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);

    my_pattern = "h\vey %"SCNdN" there";
    set_input("hey 500 there\nh\nhey\n");
    my_line = __LINE__;
    my_mask = V1_NUM;
    test_dbio_scxnf_num();
    expect_int("result",my_result,2);
    expect_int("value",*vptr1_num,500);
    my_line = __LINE__;
    my_mask = 0;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);
    test_dbio_scxnf_num();
    expect_int("result",my_result,0);

    my_pattern = "\vhey\v%"SCNdN" there\v%d";
    set_input("hey\nhey 400 there300\nhey 500 there\n");
    my_line = __LINE__;
    my_mask = 0;
    test_dbio_scxnf_num();
    expect_int("result",my_result,2);
    my_line = __LINE__;
    my_mask = V1_NUM|V2;
    test_dbio_scxnf_num();
    expect_int("result",my_result,4);
    expect_int("value",*vptr1_num,400);
    expect_int("value",*vptr2_int,300);
    my_line = __LINE__;
    my_mask = V1_NUM;
    test_dbio_scxnf_num();
    expect_int("result",my_result,3);
    expect_int("value",*vptr1_num,500);
    my_line = __LINE__;
    my_mask = 0;
    test_dbio_scxnf_num();
    expect_int("result",my_result,1);

#if 0
"\vhey %"SCNdN" there", &n); m=n; break;
"h\vey %"SCNdN" there", &n); m=n;break;
"\vhey\v%"SCNdN" there", &n); m=n; break;
"hey %jd there", &m); break;
"hey %"SCNd16" there", &i); m=i; break;
"hey %"SCNu16, &u); m=u; break;
"hey %"SCNu16"\v %"SCNd16, &u, &i); m=i; break;
"hey %*d there"); m=n; break;
"hey %"SCNu16"\v %ms", &u, &ss); m=u; break;

"hey %*d %*s"); break;
"hey\nthere"); break;
"hey\n\vthere%*s\n\vhow %jd", &m); break;
#endif

#endif
}
