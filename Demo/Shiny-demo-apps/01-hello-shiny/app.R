library(shiny)

# ---- UI: what the user sees ---------------------------------
ui <- fluidPage(
  titlePanel("Hello, Shiny!"),

  sidebarLayout(
    sidebarPanel(
      textInput("name", "What is your name?", value = "student"),
      sliderInput("n", "Number of random points:",
                  min = 10, max = 1000, value = 100)
    ),

    mainPanel(
      textOutput("greeting"),
      plotOutput("hist")
    )
  )
)

# ---- Server: the logic behind the page ----------------------
server <- function(input, output, session) {

  # Re-runs whenever input$name changes
  output$greeting <- renderText({
    paste0("Hello, ", input$name, "! Here are ", input$n, " random numbers.")
  })

  # Re-runs whenever input$n changes
  output$hist <- renderPlot({
    hist(rnorm(input$n),
         col = "steelblue", border = "white",
         main = "Histogram of random values", xlab = "Value")
  })
}

# ---- Connect the two ----------------------------------------
shinyApp(ui = ui, server = server)
