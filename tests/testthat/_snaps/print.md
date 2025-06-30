# generic_print

    Code
      out <- generic_print(1:3)
    Output
      line 1
      line 2
      line 3

# generic_format

    Code
      writeLines(generic_format(x))
    Output
      <cls>
      a : 1
      b : foo

---

    Code
      writeLines(generic_format(x))
    Output
      <list>
      a    : 1
      attr : 
          x : 
               [1]  1  2  3  4  5  6  7  8  9 10
      b    : foo

# with_width

    Code
      with_width(print(1:30), 40)
    Output
       [1]  1  2  3  4  5  6  7  8  9 10 11 12
      [13] 13 14 15 16 17 18 19 20 21 22 23 24
      [25] 25 26 27 28 29 30

# format.trace_flags

    Code
      tf1 <- structure(c(sampled = TRUE, random = TRUE), class = "otel_trace_flags")
      format(tf1)
    Output
      [1] "+sampled +random"
    Code
      tf2 <- structure(c(sampled = FALSE, random = FALSE), class = "otel_trace_flags")
      format(tf2)
    Output
      [1] "-sampled -random"

# format.otel_attributes

    Code
      writeLines(format(structure(list(), names = character(), class = "otel_attributes")))

---

    Code
      writeLines(format(structure(list(a = "this", b = 1:4), class = "otel_attributes")))
    Output
      a : this
      b : 
          [1] 1 2 3 4

# format.otel_span_data, print.otel_span_data

    Code
      spns[["s"]]
    Output
      <otel_span_data>
      trace_id              : <trace-id>
      span_id               : <span-id>
      name                  : s
      flags                 : +sampled -random
      parent                : 0000000000000000
      description           : 
      resource_attributes   : 
          os.type                     : <os-type>
          process.pid                 : <process-pid>
          process.runtime.description : <r-version-string>
          process.runtime.name        : R
          telemetry.sdk.version       : <otel-version>
          process.runtime.version     : <r-version>
          telemetry.sdk.name          : opentelemetry
          process.owner               : <username>
          telemetry.sdk.language      : R
          service.name                : unknown_service
      schema_url            : 
      instrumentation_scope : 
          <otel_instrumentation_scope_data>
          name       : org.r-lib.otel
          version    : 
          schema_url : 
          attributes : 
      kind                  : internal
      status                : ok
      start_time            : <timestamp>
      duration              : <duration>
      attributes            : 
      events                : 
      links                 : 

# format.otel_instrumentation_scope_data

    Code
      writeLines(format(spns[["s"]][["instrumentation_scope"]]))
    Output
      <otel_instrumentation_scope_data>
      name       : org.r-lib.otel
      version    : 
      schema_url : 
      attributes : 

---

    Code
      spns[["s"]][["instrumentation_scope"]]
    Output
      <otel_instrumentation_scope_data>
      name       : org.r-lib.otel
      version    : 0.1.0
      schema_url : https://opentelemetry.io/schemas/1.13.0
      attributes : 
          bar : that
          foo : 
              [1] 1 2 3 4 5

# format.otel_sum_point_data

    Code
      mtrs
    Output
      <otel_metrics_data>
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [0]:
          
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [1]:
          <otel_scope_metrics>
          instrumentation_scope:
              <otel_instrumentation_scope_data>
              name       : org.r-project.R
              version    : 
              schema_url : 
              attributes : 
          metric_data [1]:
              <otel_metric_data>
              instrument_name        : c
              instrument_description : 
              instrument_unit        : 
              instrument_type        : counter
              instrument_value_type  : double
              aggregation_temporality: cumulative
              start_time             <timestamp>
              end_time               <timestamp>
              point_data_attributes [1]:
                  <otel_point_data_attributes>
                  attributes : 
                  point_type : sum_point_data
                  value      : 
                      <otel_sum_point_data>
                      value_type  : double
                      value       : 5
                      is_monotonic: TRUE

# format.otel_histogram_point_data

    Code
      mtrs
    Output
      <otel_metrics_data>
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [0]:
          
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [1]:
          <otel_scope_metrics>
          instrumentation_scope:
              <otel_instrumentation_scope_data>
              name       : org.r-project.R
              version    : 
              schema_url : 
              attributes : 
          metric_data [1]:
              <otel_metric_data>
              instrument_name        : h
              instrument_description : 
              instrument_unit        : 
              instrument_type        : histogram
              instrument_value_type  : double
              aggregation_temporality: cumulative
              start_time             <timestamp>
              end_time               <timestamp>
              point_data_attributes [1]:
                  <otel_point_data_attributes>
                  attributes : 
                  point_type : histogram_point_data
                  value      : 
                      <otel_histogram_point_data>
                      value_type    : double
                      record_min_max: TRUE
                      sum           : 55
                      min           : 1
                      max           : 10
                      count         : 10
                      counts [16]:
                           [1] 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0
                      boundaries [15]:
                           [1]     0     5    10    25    50    75   100   250   500   750  1000
                          [12]  2500  5000  7500 10000

# format.otel_last_value_point_data

    Code
      mtrs
    Output
      <otel_metrics_data>
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [0]:
          
      <otel_resouce_metrics>
      attributes:telemetry.sdk.version  : 1.21.0
      attributes:telemetry.sdk.name     : opentelemetry
      attributes:telemetry.sdk.language : cpp
      attributes:service.name           : unknown_service
      scope_metric_data [1]:
          <otel_scope_metrics>
          instrumentation_scope:
              <otel_instrumentation_scope_data>
              name       : org.r-project.R
              version    : 
              schema_url : 
              attributes : 
          metric_data [1]:
              <otel_metric_data>
              instrument_name        : g
              instrument_description : 
              instrument_unit        : 
              instrument_type        : gauge
              instrument_value_type  : double
              aggregation_temporality: cumulative
              start_time             <timestamp>
              end_time               <timestamp>
              point_data_attributes [1]:
                  <otel_point_data_attributes>
                  attributes : 
                  point_type : last_value_point_data
                  value      : 
                      <otel_last_value_point_data>
                      value_type        : double
                      value             : 5
                      is_lastvalue_valid: TRUE
                      sample_ts         <timestamp>

# format.otel_drop_point_data

    Code
      x
    Output
      <otel_drop_point_data>

