# otel_logger_provider_file_options_defaults_

    Code
      logger_provider_file$options()
    Output
      $file_pattern
      [1] "logs-%N.jsonl"
      
      $alias_pattern
      [1] "logs-latest.jsonl"
      
      $flush_interval
      [1] 30
      
      $flush_count
      [1] 256
      
      $file_size
      [1] 20971520
      
      $rotate_size
      [1] 10
      

# otel_logger_provider_http_default_options_

    Code
      logger_provider_http$options()
    Output
      $url
      [1] "http://localhost:4318/v1/logs"
      
      $content_type
      http/protobuf 
                  1 
      
      $json_bytes_mapping
      [1] 0
      
      $use_json_name
      [1] FALSE
      
      $console_debug
      [1] FALSE
      
      $timeout
      [1] 10
      
      $http_headers
      named character(0)
      
      $ssl_insecure_skip_verify
      [1] FALSE
      
      $ssl_ca_cert_path
      [1] ""
      
      $ssl_ca_cert_string
      [1] ""
      
      $ssl_client_key_path
      [1] ""
      
      $ssl_client_key_string
      [1] ""
      
      $ssl_client_cert_path
      [1] ""
      
      $ssl_client_cert_string
      [1] ""
      
      $ssl_min_tls
      [1] ""
      
      $ssl_max_tls
      [1] ""
      
      $ssl_cipher
      [1] ""
      
      $ssl_cipher_suite
      [1] ""
      
      $compression
      [1] "none"
      
      $retry_policy_max_attempts
      [1] 5
      
      $retry_policy_initial_backoff
      [1] 1000
      
      $retry_policy_max_backoff
      [1] 5000
      
      $retry_policy_backoff_multiplier
      [1] 1.5
      
      $max_queue_size
      [1] 2048
      
      $max_export_batch_size
      [1] 512
      
      $schedule_delay
      [1] 5000
      

