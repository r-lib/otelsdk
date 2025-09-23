# env vars are current for otel spec

    Code
      gh::gh("https://api.github.com/repos/{owner}/{repo}/releases/latest", owner = "open-telemetry",
        repo = "opentelemetry-specification")$tag_name
    Output
      [1] "v1.49.0"

