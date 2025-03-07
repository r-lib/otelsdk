#ifndef OTEL_COMMON_H
#define OTEL_COMMON_H

#ifdef __cplusplus
extern "C" {
#endif

struct otel_scoped_span {
  void *span;
  void *scope;
};

void otel_tracer_provider_finally_(void *tracer_provider);
void otel_tracer_finally_(void *tracer);
void otel_span_finally_(void *span);
void otel_scope_finally_(void *scope);

void *otel_create_tracer_provider_stdout_(void);
void *otel_get_tracer_(void *tracer_provider, const char *name);
struct otel_scoped_span otel_start_span_(void *tracer, const char *name, void *parent);
void otel_span_end_(void *span, void *scope);

#ifdef __cplusplus
}
#endif

#endif
