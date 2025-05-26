# log to file

    Code
      spns[[1]][test_fields]
    Output
      $severity_num
      [1] "9"
      
      $severity_text
      [1] "INFO"
      
      $body
      [1] "This is a simple log message"
      
      $attributes
      named list()
      
      $trace_id
      [1] "00000000000000000000000000000000"
      
      $span_id
      [1] "0000000000000000"
      
    Code
      spns[[2]][test_fields]
    Output
      $severity_num
      [1] "13"
      
      $severity_text
      [1] "WARN"
      
      $body
      [1] "This is a warning"
      
      $attributes
      named list()
      
      $trace_id
      [1] "00000000000000000000000000000000"
      
      $span_id
      [1] "0000000000000000"
      
    Code
      spns[[3]][test_fields]
    Output
      $severity_num
      [1] "9"
      
      $severity_text
      [1] "INFO"
      
      $body
      [1] "This is a structured log message."
      
      $attributes
      $attributes$type
      [1] "structured"
      
      
      $trace_id
      [1] "00000000000000000000000000000000"
      
      $span_id
      [1] "0000000000000000"
      
    Code
      spns[[4]][test_fields]
    Output
      $severity_num
      [1] "9"
      
      $severity_text
      [1] "INFO"
      
      $body
      [1] "This is a structured log message with attributes"
      
      $attributes
      $attributes$foo
      [1] "bar"
      
      $attributes$type
      [1] "structured"
      
      
      $trace_id
      [1] "00000000000000000000000000000000"
      
      $span_id
      [1] "0000000000000000"
      

