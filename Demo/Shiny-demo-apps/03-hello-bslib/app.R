# ------------------------------------------------------------
# App 3: Hello, bslib!
# The smallest possible dashboard: a sidebar, two value boxes,
# and one chart card. Uses made-up (toy) data.
#
# Same Shiny engine as App 1. Only the UI functions change:
#   fluidPage()  ->  page_sidebar()
#   panels       ->  card() and value_box()
#
# Run it:  shiny::runApp("03-hello-bslib")
# ------------------------------------------------------------

library(shiny)
library(bslib)

# Toy data: daily visitors to a coffee shop for 60 days
set.seed(42)
coffee <- data.frame(
  day      = 1:60,
  visitors = round(120 + 2 * (1:60) + rnorm(60, sd = 15))
)

# ---- UI ------------------------------------------------------
ui <- page_sidebar(
  title = "Coffee Shop Dashboard",

  sidebar = sidebar(
    sliderInput("days", "Show the last N days:",
                min = 7, max = 60, value = 30)
  ),

  # Two headline numbers side by side
  layout_columns(
    value_box(
      title = "Total visitors",
      value = textOutput("total"),
      showcase = icon("users"),
      theme = "primary"
    ),
    value_box(
      title = "Average per day",
      value = textOutput("average"),
      showcase = icon("mug-hot"),
      theme = "secondary"
    )
  ),

  # One chart in a card
  card(
    card_header("Daily visitors"),
    plotOutput("trend")
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  recent <- reactive({
    tail(coffee, input$days)
  })

  output$total   <- renderText(format(sum(recent()$visitors), big.mark = ","))
  output$average <- renderText(round(mean(recent()$visitors)))

  output$trend <- renderPlot({
    plot(recent()$day, recent()$visitors, type = "b", pch = 19,
         col = "steelblue", xlab = "Day", ylab = "Visitors")
  })
}

shinyApp(ui, server)
