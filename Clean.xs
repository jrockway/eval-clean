#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static PerlInterpreter *main_perl;
char *default_args[] =  { "a_perl", "-e", "0" };

static void xs_init (pTHX);

EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);

EXTERN_C void xs_init(pTHX) {
  char *file = __FILE__;
  /* DynaLoader is a special case */
  newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}

MODULE = Eval::Clean   PACKAGE = Eval::Clean

PROTOTYPES: DISABLE

BOOT:
        main_perl = PERL_GET_CONTEXT;

PerlInterpreter *
new_perl()
  CODE:
    PerlInterpreter *perl;

    perl = perl_alloc();

    my_perl = perl;
    PERL_SET_CONTEXT(my_perl);

    perl_construct(perl);
    perl_parse(perl, xs_init, 3, default_args, (char **)NULL);

    my_perl = main_perl;
    PERL_SET_CONTEXT(main_perl);

    RETVAL = perl;

  OUTPUT:
    RETVAL

void
free_perl(PerlInterpreter *perl)
  CODE:
    perl_destruct(perl);
    perl_free(perl);

const char *
eval(PerlInterpreter *code_perl, const char *code, const char *after_code)
  CODE:
    PerlInterpreter *after_perl;
    SV *code_result, *after_cv, *after_result;
    int count = 0;

    after_perl = perl_alloc();
    perl_construct(after_perl);

    my_perl = code_perl;
    PERL_SET_CONTEXT(code_perl);

    //printf("Running '%s'...\n", code);
    code_result = eval_pv(code, TRUE);
    //printf("got SV at %#x (%s)\n", code_result, SvPV_nolen(code_result));

    after_perl = perl_clone(code_perl, 0);
    //printf("oh hai, we have a new perl at %#x (old: %#x)\n", after_perl, code_perl);

    my_perl = after_perl;
    PERL_SET_CONTEXT(after_perl);

    //printf("Running '%s'...\n", after_code);
    after_cv = eval_pv(after_code, TRUE);
    //printf("got SV at %#x\n", after_result);

    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    XPUSHs(code_result);
    PUTBACK;

    count = call_sv(after_cv, G_SCALAR);

    if(count != 1)
      croak("Something bad happened; expecting 1 value but got %d", count);

    SPAGAIN;
    after_result = POPs;
    RETVAL = strdup(SvPV_nolen(after_result));

    PUTBACK;
    FREETMPS;
    LEAVE;

    perl_destruct(after_perl);
    perl_free(after_perl);

    my_perl = main_perl;
    PERL_SET_CONTEXT(main_perl);

  OUTPUT:
    RETVAL
