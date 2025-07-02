# otel_decode_log_record_

    Code
      lrec
    Output
      $severity_text
      [1] "INFO"
      
      $trace_id
      [1] ""
      
      $span_id
      [1] ""
      
      $has_body
      [1] TRUE
      
      $body
      [1] "Test!"
      
      $attributes
      NULL
      
      $event_name
      [1] ""
      
      $dropped_attributes_count
      [1] 0
      

---

    Code
      ccall(otel_parse_log_record, logmsg)
    Condition
      Error:
      ! Failed to parse Protobuf log message @r-collector.c:14 (otel_parse_log_record)

# otel_decode_metrics_record_

    Code
      mets
    Output
      [[1]]
      [[1]]$schema_url
      [1] ""
      
      [[1]]$scope_metrics
      [[1]]$scope_metrics[[1]]
      [[1]]$scope_metrics[[1]]$schema_url
      [1] ""
      
      [[1]]$scope_metrics[[1]]$metrics
      [[1]]$scope_metrics[[1]]$metrics[[1]]
      [[1]]$scope_metrics[[1]]$metrics[[1]]$name
      [1] "ctr"
      
      [[1]]$scope_metrics[[1]]$metrics[[1]]$description
      [1] ""
      
      [[1]]$scope_metrics[[1]]$metrics[[1]]$unit
      [1] ""
      
      
      
      
      
      

---

    Code
      ccall(otel_parse_metrics_record, metmsg)
    Condition
      Error:
      ! Failed to parse Protobuf metrics message @r-collector.c:27 (otel_parse_metrics_record)

# otel_encode_response_

    Code
      encode_response("traces")
    Output
      raw(0)

---

    Code
      encode_response("traces", "partial-success", error_message = "partial fail!",
        rejected = 1L)
    Output
       [1] 0a 11 08 01 12 0d 70 61 72 74 69 61 6c 20 66 61 69 6c 21

---

    Code
      encode_response("traces", "failure", error_message = "fail!", error_code = 2L)
    Output
      [1] 08 02 12 05 66 61 69 6c 21

---

    Code
      encode_response("metrics")
    Output
      raw(0)

---

    Code
      encode_response("metrics", "partial-success", error_message = "partial fail!",
        rejected = 1L)
    Output
       [1] 0a 11 08 01 12 0d 70 61 72 74 69 61 6c 20 66 61 69 6c 21

---

    Code
      encode_response("logs")
    Output
      raw(0)

---

    Code
      encode_response("logs", "partial-success", error_message = "partial fail!",
        rejected = 1L)
    Output
       [1] 0a 11 08 01 12 0d 70 61 72 74 69 61 6c 20 66 61 69 6c 21

