# Add the Shiny user and session token to every span that Shiny creates
# for this app. See README.md in this directory for how to run it.

library(shiny)

otelsdk::add_span_processor(
  id = "shiny-session",
  on_start = function(span, info) {
    session <- shiny::getDefaultReactiveDomain()
    if (is.null(session)) {
      return()
    }
    user <- if (is.null(session$user)) "anonymous" else session$user
    span$set_attribute("app.user", user)
    span$set_attribute("app.session.token", session$token)
  }
)

ui <- fluidPage(
  titlePanel("Span processor example"),
  sliderInput("n", "Number of points", min = 10, max = 500, value = 100),
  actionButton("resample", "Resample"),
  plotOutput("plot"),
  textOutput("summary")
)

server <- function(input, output, session) {
  points <- reactive({
    input$resample
    rnorm(input$n)
  })

  observe({
    message("New sample of ", length(points()), " points")
  })

  output$plot <- renderPlot({
    hist(points(), main = NULL, xlab = NULL)
  })

  output$summary <- renderText({
    sprintf("Mean: %.3f, SD: %.3f", mean(points()), sd(points()))
  })
}

shinyApp(ui, server)
