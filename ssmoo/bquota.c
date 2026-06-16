#include "config.h"
#include "options.h"

#include "structures.h"
#include "db_private.h"
#include "execute.h"
#include "list.h"
#include "numbers.h"
#include "tasks.h"
#include "utils.h"

/*
b+4f+8v=w
b+4f+4v=l
v = (w-l)/4
f = (2l-w-b)/4
*/

static size_t
sizeof_floatvar(void)
{
    Var flst = parse_number_from_string("0",PN_REQ_FLOAT);
    size_t r = value_bytes(flst);
    free_var(flst);
    return r;
}



#if   BYTE_QUOTA_MODEL == BQM_HW
#  define _I(if32,if64) 0
#  define _W 0
#elif BYTE_QUOTA_MODEL == BQM_32
#  define _I(if32,if64) (if32)
#  define _W 4
#elif BYTE_QUOTA_MODEL == BQM_64 || BYTE_QUOTA_MODEL == BQM_64B
#  define _I(if32,if64) (if64)
#  define _W 8
#else
#  error "unknown BYTE_QUOTA_MODEL"
#endif
#if   BQM_BOXED_FLOATS
#  define _B 8
#else
#  define _B 0
#endif
#if   !BQM_INCLUDES_WAIFS
#  undef _W
#  define _W 0
#endif

#define DO_ALL_OF_THE_THINGS(DTH)                                       \
    DTH("Object",       _I(60,112)+_W,  BQM_SIZEOF(Object));            \
    DTH("Object *",     _I( 4,  8),     BQM_SIZEOF_PTR_TO(Object));     \
    DTH("Propdef",      _I( 8, 16),     BQM_SIZEOF(Propdef));           \
    DTH("Pval",         _I(16, 32),     BQM_SIZEOF(Pval));              \
    DTH("Verbdef",      _I(20, 40),     BQM_SIZEOF(Verbdef));           \
    DTH("Program",      _I(68,104),     BQM_SIZEOF(Program));           \
    DTH("Bytecodes",    _I(20, 24),     BQM_SIZEOF(Bytecodes));         \
    DTH("Var",          _I( 8, 16),     BQM_SIZEOF(Var));               \
    DTH("0.0",          _I( 8, 16)+_B,  sizeof_floatvar());             \
    DTH("FlNum",                 8,     BQM_SIZEOF(FlNum));             \
    DTH("const char *", _I( 4,  8),     BQM_SIZEOF_PTR_TO_CONST(char)); \
    DTH("forked_task",  _I(92,168)+_W*2, sizeof_forked_task());         \
    DTH("activation",   _I(72,128)+_W*2, BQM_SIZEOF(activation));       \
    DTH("vmstruct",     _I(24, 32),     BQM_SIZEOF(vmstruct));          \
    DO_WAIFS(DTH)

#if WAIF_CORE
#  define DO_WAIFS(DTH) DTH("Waif", _I(28, 56), BQM_SIZEOF(Waif));
#else
#  define DO_WAIFS(DTH)
#endif
        ;
int
main(int argc, const char *argv[]) {
    if (argc == 2 && 0==strcmp(argv[1],"--report")) {

#define REPORT(lbl,_,sz)  printf("%-12s = %zu\n", lbl, sz);
        DO_ALL_OF_THE_THINGS(REPORT);

    }
    else if (argc != 1) {
        printf("Usage:  %s [--report]\n"
               "\n"
               "   --report lists the various structure sizes\n"
               "   omitting --report runs the unit test\n"
               , argv[0]);
    }
    else {

#if   BYTE_QUOTA_MODEL == BQM_HW
        printf("# hardware byte quota model; skipping all tests\n");
        exit (77);
#else  /* BYTE_QUOTA_MODEL != BQM_HW */
        int fails = 0;
        int count = 0;
        size_t expect = 0;
        size_t actual = 0;
#define CHECK(lbl,exp,sz)                               \
        expect = (exp);                                 \
        actual = (sz);                                  \
        ++count;                                        \
        if (expect == actual)                           \
            printf("ok %d\n", count);                   \
        else {                                          \
            printf("not ok %d - %s\n", count, lbl);     \
            printf("# Failed test %d\n", count);        \
            printf("#      got: '%zu'\n", sz);          \
            printf("# expected: '%zu'\n", expect);      \
            ++fails;                                    \
        }
        DO_ALL_OF_THE_THINGS(CHECK);
        if (fails) {
            printf("%d out of %d tests failed\n", fails, count);
            exit(1);
        }
#endif  /* BYTE_QUOTA_MODEL != BQM_HW */
    }
}
