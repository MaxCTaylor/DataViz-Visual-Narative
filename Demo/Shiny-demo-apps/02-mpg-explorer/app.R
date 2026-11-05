# ------------------------------------------------------------
# App 2: MPG Explorer
# A classic Shiny app (not a dashboard) that shows off more widgets
# and the key reactivity tools:
#   - several input types (select, checkbox group, slider, radio)
#   - reactive() to share one filtered dataset across outputs
#   - tabsetPanel() for multiple views
#   - observeEvent() + update*Input() for a "Reset" button
#   - downloadHandler() to export the filtered data
#
# Run it:  shiny::runApp("02-mpg-explorer")
# ------------------------------------------------------------

library(shiny)
library(ggplot2)
library(dplyr)

# mpg ships with ggplot2: 234 cars from 1999 and 2008
cars <- mpg

# Friendly labels for the numeric variables users can plot
num_vars <- c(
  "Engine size (L)" = "displ",
  "City MPG"        = "cty",
  "Highway MPG"     = "hwy",
  "Cylinders"       = "cyl"
)

# ---- UI ------------------------------------------------------
ui <- fluidPage(
  titlePanel("MPG Explorer"),

  sidebarLayout(
    sidebarPanel(
      h4("Filter the cars"),

      selectInput("class", "Vehicle class:",
                  choices  = sort(unique(cars$class)),
                  selected = sort(unique(cars$class)),
                  multiple = TRUE),

      checkboxGroupInput("year", "Model year:",
                         choices  = c(1999, 2008),
                         selected = c(1999, 2008),
                         inline   = TRUE),

      sliderInput("displ", "Engine size (L):",
                  min = min(cars$displ), max = max(cars$displ),
                  value = range(cars$displ), step = 0.1),

      hr(),
      h4("Plot settings"),

      selectInput("x", "X axis:", choices = num_vars, selected = "displ"),
      selectInput("y", "Y axis:", choices = num_vars, selected = "hwy"),

      radioButtons("color", "Color points by:",
                   choices = c("Class" = "class", "Drive type" = "drv",
                               "Year" = "year", "None" = "none"),
                   selected = "class"),

      hr(),
      actionButton("reset", "Reset filters", icon = icon("rotate-left")),
      downloadButton("download", "Download data")
    ),

    mainPanel(
      textOutput("count"),
      br(),
      tabsetPanel(
        tabPanel("Plot",    plotOutput("scatter", height = "450px")),
        tabPanel("Summary", tableOutput("summary")),
        tabPanel("Data",    tableOutput("table"))
      )
    )
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  # One reactive expression feeds every output below.
  # It re-runs only when one of the filter inputs changes.
  filtered <- reactive({
    cars |>
      filter(class %in% input$class,
             year  %in% input$year, # nolint: object_usage_linter.
             displ >= input$displ[1], # nolint: object_usage_linter.
             displ <= input$displ[2])
  })

  output$count <- renderText({
    paste(nrow(filtered()), "of", nrow(cars), "cars match your filters.")
  })

  output$scatter <- renderPlot({
    # validate() shows a friendly message instead of an error
    validate(need(nrow(filtered()) > 0, "No cars match these filters."))

    p <- ggplot(filtered(), aes(x = .data[[input$x]], y = .data[[input$y]]))

    if (input$color == "none") {
      p <- p + geom_point(size = 3, alpha = 0.7, color = "steelblue")
    } else {
      color_labels <- c(class = "Class", drv = "Drive type", year = "Year")
      p <- p +
        geom_point(aes(color = factor(.data[[input$color]])),
                   size = 3, alpha = 0.7) +
        labs(color = color_labels[[input$color]])
    }

    p +
      labs(x = names(num_vars)[num_vars == input$x],
           y = names(num_vars)[num_vars == input$y]) +
      theme_minimal(base_size = 15)
  })

  output$summary <- renderTable({
    filtered() |>
      group_by(class) |>
      summarise(cars         = n(),
                avg_city_mpg = mean(cty), # nolint: object_usage_linter.
                avg_hwy_mpg  = mean(hwy)) |> # nolint: object_usage_linter.
      arrange(desc(avg_hwy_mpg)) # nolint: object_usage_linter.
  }, digits = 1)

  output$table <- renderTable({
    filtered() |>
      select(manufacturer, model, year, class, displ, cyl, drv, cty, hwy) # nolint: object_usage_linter.
  })

  # observeEvent() runs code for its side effect (here: changing inputs)
  observeEvent(input$reset, {
    updateSelectInput(session, "class", selected = sort(unique(cars$class)))
    updateCheckboxGroupInput(session, "year", selected = c(1999, 2008))
    updateSliderInput(session, "displ", value = range(cars$displ))
  })

  output$download <- downloadHandler(
    filename = function() "mpg-filtered.csv",
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
