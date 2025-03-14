function(input, output, session) {

  session$userData$tracer <-
    opentelemetry::setup_default_tracer("kmeans-shiny-app")
  session$userData$session_span <-
    session$userData$tracer$start_span("session", parent = NA, scope = NULL)
  session$onSessionEnded(function() session$userData$session_span$end())

  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })

  clusters <- reactive({
    session$userData$tracer$start_span("kmeans")
    Sys.sleep(1)
    kmeans(selectedData(), input$clusters)
  })

  output$plot1 <- renderPlot({
    session$userData$tracer$start_span("plot")
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
      "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))

    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })

}
