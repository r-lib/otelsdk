parse_log_record_message <- function(msg) {
  ccall(otel_parse_log_record, msg)
}

collector_app <- function() {
  app <- webfakes::new_app()
  app$locals$logs <- list()
  app$locals$traces <- list()
  app$locals$metrics <- list()
  app$post(
    c("/v1/traces", "/v1/metrics", "/v1/logs"),
    function(req, res) {
      if (req$get_header("content-type") != "application/x-protobuf") {
        bd <- encode_response(
          "traces",
          "failure",
          error_message = "missing or wrong content-type header"
        )
        res$set_status(400L)
        res$send(bd)
        return()
      }
      "next"
    }
  )
  app$post("/v1/traces", function(req, res) {
    # TODO
  })
  app$post("/v1/metrics", function(req, res) {
    # TODO
  })
  app$post("/v1/logs", function(req, res) {
    record <- ccall(otel_parse_log_record, req$.body)
    app$locals$logs <- c(app$locals$logs, list(record))
    bd <- encode_response("logs")
    res$set_status(200)
    res$send(bd)
  })
  app$get("/logs", function(req, res) {
    if (length(app$locals$logs) == 0) {
      res$set_status(404)
      res$send("No logs available")
      return()
    }
    res$set_status(200)
    res$send_json(app$locals$logs, auto_unbox = TRUE)
    app$locals$logs <- list()
  })
  app$get("/metrics", function(req, res) {
    # TODO
  })
  app$get("/traces", function(req, res) {
    # TODO
  })
  app
}

as_otlp_signal <- function(x) {
  choices <- c("traces", "metrics", "logs")
  x <- as_choice(x, choices, null = FALSE)
  x
}

as_otlp_result <- function(x) {
  choices <- c("success", "partial-success", "failure")
  x <- as_choice(x, choices, null = FALSE)
  x
}

encode_response <- function(
  signal,
  result = "success",
  error_message = NULL,
  rejected = 0L,
  error_code = 0L
) {
  signal <- as_otlp_signal(signal)
  result <- as_otlp_result(result)
  error_message <- as_string(error_message)
  rejected <- as_count(rejected)
  error_code <- as_count(error_code)
  ccall(
    otel_encode_response,
    signal,
    result,
    error_message,
    rejected,
    error_code
  )
}
