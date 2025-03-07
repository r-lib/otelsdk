default_tracer_provider_option <- "opentelemetry.default_tracer_provider"
default_tracer_provider_envvar <- "R_OPENTELEMETRY_DEFAULT_TRACER_PROVIDER"

#' Set the default tracer provider
#' @param tracer_provider An OpenTelemetry tracer provider
#'   (`opentelemetry_tracer_provider` object) to set as default.
#' @return The previously set default tracer provider, or `NULL`, if no
#'   default was set before.
#'
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

#' Get the default tracer provider
#'
#' If there is no default set currently, then it creates and sets a
#' default.
#'
#' The default tracer provider is created based on the
#' `r default_tracer_provider_envvar` environment variable.
#' The following values are allowed:
#' - `stdout`: uses [tracer_provider_stdout], to write traces to the
#'   standard output.
#' - `http`: uses [tracer_provider_http], to send traces over HTTP.
#' - `<package>::<provider>`: will select the `<provider>` object from
#'   the `<package>` package to use as a tracer provider. It calls
#'   `<package>::<provider>$new()` to create the new traver provider.
#'   If this fails for some reason, e.g. the package is not installed,
#'   then it throws an error.
#'
#' @return The default tracer provider, an `opentelemetry_tracer_provider`
#'   object.
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

#' Get a tracer from the default tracer provider
#'
#' Calls [get_default_tracer_provider()] to get the default tracer
#' provider. Then calls its `$get_tracer()` method to create a new tracer.
#'
#' @param name Name of the new tracer. This is typically the R package
#'   name.
#' @return An OpenTelemetry tracer, an `opentelemetry_tracer` object.
#' @export

setup_default_tracer <- function(name) {
  # does setup if necessary
  tp <- get_default_tracer_provider()
  trc <- tp$get_tracer(name)
  invisible(trc)
}
