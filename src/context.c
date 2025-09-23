#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <Rversion.h>

// TODO: not yet on R 4.6.x, except if forced for CI testing
#if R_VERSION < R_Version(3,5,0) || !defined(OTEL_BUILD_SAFE)

SEXP otel_error_object(void) {
  SEXP ret = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(ret, 0, Rf_ScalarLogical(0));
  SET_VECTOR_ELT(ret, 1, R_NilValue);
  UNPROTECT(1);
  return ret;
}

#else

#ifdef WIN32
#include <setjmp.h>
typedef int sigset_t;
typedef struct {
  jmp_buf jmpbuf;
  int mask_was_saved;
  sigset_t saved_mask;
} sigjmp_buf[1];
#else
#include <setjmp.h>
#endif
#define JMP_BUF sigjmp_buf

struct R_bcstack_t;
struct RPRSTACK;
#if R_VERSION >= R_Version(4,4,0)
typedef struct {
    int tag;
    int flags;
    union {
	int ival;
	double dval;
	SEXP sxpval;
    } u;
} R_bcstack_t;
#endif

struct r_context {
    struct r_context *nextcontext;
    int callflag;
    JMP_BUF cjmpbuf;
    int cstacktop;
    int evaldepth;
    SEXP promargs;
    SEXP callfun;
    SEXP sysparent;
    SEXP call;
    SEXP cloenv;
    SEXP conexit;
    void (*cend)(void *);
    void *cenddata;
    void *vmax;
    int intsusp;
    int gcenabled;
    int bcintactive;
    SEXP bcbody;
    void* bcpc;
#if R_VERSION >= R_Version(4,4,0)
    ptrdiff_t relpc;
#endif
    SEXP handlerstack;
    SEXP restartstack;
    struct RPRSTACK *prstack;
    struct R_bcstack_t *nodestack;
#if R_VERSION >= R_Version(4,0,0)
    struct R_bcstack_t *bcprottop;
#endif
    SEXP srcref;
    int browserfinish;
#if R_VERSION < R_Version(4,4,0)
    SEXP returnValue;
#else
    R_bcstack_t returnValue;
#endif
    struct r_context *jumptarget;
    int jumpmask;
};

extern struct r_context *R_GlobalContext;
SEXP otel_error_object(void) {
  SEXP ret = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(ret, 0, Rf_ScalarLogical(1));
  SET_VECTOR_ELT(ret, 1, R_NilValue);

  struct r_context *c = R_GlobalContext;
  for (; c != NULL; c = c->nextcontext) {
    for (SEXP hs = c->handlerstack; hs != R_NilValue; hs = CDR(hs)) {
      if (TYPEOF(CAR(hs)) == VECSXP && Rf_length(CAR(hs)) >= 5) {
        SEXP hs5 = VECTOR_ELT(CAR(hs), 4);
        if (TYPEOF(hs5) == VECSXP && Rf_length(hs5) >= 1) {
          SEXP hs51 = VECTOR_ELT(hs5, 0);
          if (!Rf_isNull(hs51)) {
            SET_VECTOR_ELT(ret, 1, VECTOR_ELT(hs5, 0));
            UNPROTECT(1);
            return ret;
          }
        }
      }
    }
  }

  UNPROTECT(1);
  return ret;
}

#endif
