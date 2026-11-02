#' Add or remove a span processor
#'
#' A span processor is a set of callbacks that otelsdk calls for every
#' span, no matter which package or function created it. You can use a
#' span processor to add attributes to spans that are created by code you
#' do not control, e.g. to add the current user to every span that Shiny
#' creates.
#'
#' Span processors are part of the OpenTelemetry SDK, not the API, so
#' they are meant to be set up by whoever configures the telemetry output
#' of an app, not by the authors of instrumented packages.
#'
#' Span processors are global: they apply to the spans of all tracer
#' providers.
#'
#' Currently span processors only support an `on_start` callback.
#'
#' ## `on_start`
#'
#' The `on_start` callback is called right after a span has started, for
#' every span that is recording. It is called with two arguments:
#'
#' * `span`: the new span, an `otel_span` object. You can call its
#'   methods, e.g. `span$set_attribute()` or `span$set_attributes()`.
#' * `info`: a named list with more information about the span:
#'   * `name`: span name.
#'   * `tracer_name`: name of the tracer that created the span. This is
#'     usually the name of the instrumented package.
#'   * `kind`: span kind, a string.
#'   * `parent`: the `parent` span option, if it was set explicitly when
#'     starting the span, or `NULL`.
#'
#' The return value of `on_start` is ignored.
#'
#' If a callback fails, otelsdk emits an `otel_error_message` message,
#' and continues with the next span processor. The span is still created.
#' Set the `OTEL_ENV=dev` environment variable to get errors instead.
#'
#' If a callback starts a new span, span processors are not called for
#' that span.
#'
#' ## Setting up span processors from an environment variable
#'
#' Use the `OTEL_R_SPAN_PROCESSORS` environment variable to set up span
#' processors that are defined in packages, without changing the code of
#' the app. It is a comma separated list of `pkg::name` entries. Each
#' entry must refer to a named list of callbacks, e.g.:
#'
#' ```r
#' span_processor <- list(
#'   on_start = function(span, info) {
#'     span$set_attribute("deployment.region", "eu-west-1")
#'   }
#' )
#' ```
#'
#' and then
#'
#' ```
#' OTEL_R_SPAN_PROCESSORS=mypkg::span_processor
#' ```
#'
#' otelsdk reads `OTEL_R_SPAN_PROCESSORS` when the first span is
#' started. The id of these span processors is `env:` followed by the
#' entry, e.g. `env:mypkg::span_processor`.
#'
#' If the list has callbacks that this version of otelsdk does not
#' support, otelsdk ignores them with a message, and uses the rest of the
#' span processor. This way a package can define callbacks for newer
#' otelsdk versions and still work with older ones.
#'
#' ## Example Shiny app
#'
#' This span processor adds the user and the session token to every span
#' that starts inside a Shiny session:
#'
#' ```{r eval = FALSE, code = c(readLines("inst/examples/shiny-span-processor/app.R")[1:20], "...")}
#' ```
#'
#' See the full example app, with instructions for running it, in the
#' `examples/shiny-span-processor` directory of the installed otelsdk
#' package:
#'
#' ```r
#' system.file(package = "otelsdk", "examples", "shiny-span-processor")
#' ```
#'
#' @param on_start Function to call when a span starts, or `NULL`. See
#'   details below.
#' @param ... Reserved for more callbacks in the future. Must be empty.
#' @param id Id of the span processor, a string. For
#'   `add_span_processor()` it may be `NULL`, then a new id is generated.
#'   If a span processor with the same id already exists, it is replaced.
#'   For `remove_span_processor()` it is the id returned by
#'   `add_span_processor()`.
#' @return `add_span_processor()` returns the id of the span processor,
#'   invisibly. `remove_span_processor()` returns `TRUE` if the span
#'   processor was removed and `FALSE` if there was no span processor
#'   with this id, invisibly.
#'
#' @export
#' @examples
#' id <- add_span_processor(
#'   on_start = function(span, info) {
#'     span$set_attribute("tracer", info$tracer_name)
#'   }
#' )
#' spns <- with_otel_record({
#'   trc <- otel::get_tracer("mytracer")
#'   spn <- trc$start_local_active_span("myspan")
#'   spn$end()
#' })
#' spns$traces$myspan$attributes
#' remove_span_processor(id)

add_span_processor <- function(on_start = NULL, ..., id = NULL) {
  if (...length() > 0) {
    stop(cnd(
      "Invalid argument: unknown argument(s) in `...`. `id` must be \\
       named. Currently the only supported callback is `on_start`."
    ))
  }
  on_start <- as_function(on_start)
  id <- as_string(id)
  id <- id %||% new_span_processor_id()
  procs <- the$span_processors %||% list()
  procs[[id]] <- list(on_start = on_start)
  the$span_processors <- procs
  invisible(id)
}

#' @export
#' @rdname add_span_processor

remove_span_processor <- function(id) {
  id <- as_string(id, null = FALSE)
  procs <- the$span_processors %||% list()
  found <- id %in% names(procs)
  procs[[id]] <- NULL
  the$span_processors <- procs
  invisible(found)
}

new_span_processor_id <- function() {
  the$span_processor_counter <- (the$span_processor_counter %||% 0L) + 1L
  paste0("span-processor-", the$span_processor_counter)
}

span_processor_callbacks <- "on_start"

# fmt: skip
# safe start
run_span_processors <- function(span, info) {
  if (!isTRUE(the$span_processors_env_loaded)) {
    the$span_processors_env_loaded <- TRUE
    load_span_processors_env()
  }
  procs <- the$span_processors
  if (length(procs) == 0 || isTRUE(the$in_span_processor)) {
    return(invisible())
  }
  if (!span$is_recording()) {
    return(invisible())
  }
  the$in_span_processor <- TRUE
  on.exit(the$in_span_processor <- FALSE, add = TRUE)
  for (id in names(procs)) {
    on_start <- procs[[id]][["on_start"]]
    if (is.null(on_start)) {
      next
    }
    tryCatch({                                                     # safe
      on_start(span, info)
    }, error = function(err) {                                     # safe
      errmsg(                                                      # safe
        "OpenTelemetry error in span processor '", id, "': ",      # safe
        conditionMessage(err)                                      # safe
      )                                                            # safe
    })                                                             # safe
  }
  invisible()
}
# safe end

# fmt: skip
# safe start
load_span_processors_env <- function() {
  ev <- trimws(Sys.getenv("OTEL_R_SPAN_PROCESSORS"))
  if (ev == "") {
    return(invisible())
  }
  entries <- trimws(strsplit(ev, ",", fixed = TRUE)[[1]])
  entries <- entries[entries != ""]
  for (entry in entries) {
    tryCatch({                                                     # safe
      proc <- get_span_processor_from_env(entry)
      add_span_processor(
        on_start = proc[["on_start"]],
        id = paste0("env:", entry)
      )
    }, error = function(err) {                                     # safe
      errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
    })                                                             # safe
  }
  invisible()
}
# safe end

get_span_processor_from_env <- function(entry) {
  pcs <- strsplit(entry, "::", fixed = TRUE)[[1]]
  if (length(pcs) != 2 || any(pcs == "")) {
    stop(cnd(
      "Invalid entry in `OTEL_R_SPAN_PROCESSORS`: '{entry}'. It must have \\
       the form `pkg::name`."
    ))
  }
  proc <- tryCatch(
    get_exported_object(pcs[1], pcs[2]),
    error = function(err) {
      msg <- conditionMessage(err)
      stop(cnd(
        "Cannot load span processor '{entry}' from \\
         `OTEL_R_SPAN_PROCESSORS`: {msg}"
      ))
    }
  )
  if (!is.list(proc) || !is_named(proc)) {
    stop(cnd(
      "Invalid span processor in `OTEL_R_SPAN_PROCESSORS`: '{entry}' must \\
       be a named list of callbacks, but it is {typename(proc)}."
    ))
  }
  # Unknown callbacks are only a message, so packages can define callbacks
  # that a newer otelsdk supports, and still work with an older otelsdk.
  bad <- setdiff(names(proc), span_processor_callbacks)
  if (length(bad) > 0) {
    bad <- paste0("'", bad, "'", collapse = ", ")
    good <- paste0("'", span_processor_callbacks, "'", collapse = ", ")
    errmsg(glue(
      "OpenTelemetry: span processor '{entry}' in \\
       `OTEL_R_SPAN_PROCESSORS` has unknown callback(s), these are \\
       ignored: {bad}. Supported callbacks: {good}."
    ))
  }
  on_start <- proc[["on_start"]]
  if (!is.null(on_start) && !is.function(on_start)) {
    stop(cnd(
      "Invalid span processor in `OTEL_R_SPAN_PROCESSORS`: `on_start` of \\
       '{entry}' must be a function, but it is {typename(on_start)}."
    ))
  }
  proc
}

get_exported_object <- function(pkg, name) {
  getExportedValue(pkg, name)
}
