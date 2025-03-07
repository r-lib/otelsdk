default_tracer_provider_option <- "opentelemetry.default_tracer_provider"
default_tracer_provider_envvar <- "R_OPENTELEMETRY_DEFAULT_TRACER_PROVIDER"

#' @export

set_default_tracer_provider <- function(tracer_provider) {
  if (!inherits(tracer, "opentelemetry_tracer_provider")) {
    stop(
      "Cannot set default opentelemetry tracer provider, not an ",
      "opentelemetry_tracer_provider object"
    )
  }
  old <- getOption(default_tracer_provider_option)
  options(structure(
    list(tracer_provider),
    names = default_tracer_provider_option
  ))
  invisible(old)
}

#' @export

get_default_tracer_provider <- function() {
  tp <- getOption(default_tracer_provider_option)
  if (is.null(tp)) {
    setup_default_tracer_provider()
  }
  getOption(default_tracer_provider_option)
}

setup_default_tracer_provider <- function() {
  ev <- Sys.getenv(default_tracer_provider_envvar, NA_character_)
  tp <-  if (is.na(ev)) {
    tracer_provider_noop$new()
  } else if (grepl("::", ev)) {
    evx <- strsplit(ev, "::", fixed = TRUE)[[1]]
    pkg <- evx[1]
    prv <- evx[2]
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(
        "Cannot set tracer provider ", ev,
        " from ", default_tracer_provider_envvar,
        " environment variable, cannot load package ", pkg, "."
      )
    }
    if (!prv %in% names(asNamespace(pkg))) {
      stop(
        "Cannot set tracer provider ", ev,
        " from ", default_tracer_provider_envvar,
        " environment variable, cannot find provider ", prv,
        " in package ", pkg, "."
      )
    }
    tp <- asNamespace(pkg)[[prv]]
    if ((!is.list(tp) && !is.environment(tp)) || !"new" %in% names(tp)) {
      stop(
        "Cannot set tracer provider ", ev,
        " from ", default_tracer_provider_envvar,
        " environment variable, it is not a list or environment with ",
        "a 'new' member."
      )
    }
    tp$new()

  } else {
    switch(
      ev,
      "stdout" = {
        tracer_provider_stdout$new()
      },
      "http" = {
        tracer_provider_http$new()
      },
      stop(
        "Unknown opentelemetry tracer provider from ",
        default_tracer_provider_envvar, " environment variable: ", ev
      )
    )
  }

  options(structure(list(tp), names = default_tracer_provider_option))
  invisible(tp)
}

# -------------------------------------------------------------------------
# Simplified API

#' @export

setup_default_tracer <- function(name) {
  # does setup if necessary
  tp <- get_default_tracer_provider()
  trc <- tp$get_tracer(name)
  invisible(trc)
}
