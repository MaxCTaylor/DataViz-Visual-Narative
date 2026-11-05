# ------------------------------------------------------------
# App 4: Fuel Economy Dashboard (final product)
# A polished but beginner-friendly bslib dashboard built on the
# mpg dataset from ggplot2.
#
# Structure:
#   sidebar      -> filters (inputs)
#   value boxes  -> headline numbers
#   cards        -> two charts and a table
#   reactive()   -> one filtered dataset shared by every output
#
# Run it:  shiny::runApp("04-mpg-dashboard")
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)

# ---- Data ----------------------------------------------------
cars <- mpg |>
  mutate(
    drive = recode(drv, "f" = "Front", "r" = "Rear", "4" = "4WD"),
    make  = tools::toTitleCase(manufacturer)
  )

all_classes <- sort(unique(cars$class))

# ---- Theme ---------------------------------------------------
my_theme <- bs_theme(
  version   = 5,
  bootswatch = "flatly",
  primary   = "#2c7fb8"
)

# Shared ggplot style so every chart looks consistent
theme_dash <- theme_minimal(base_size = 14) +
  theme(panel.grid.minor = element_blank(),
        legend.position  = "bottom")

# ---- UI ------------------------------------------------------
ui <- page_sidebar(
  title = "Fuel Economy Dashboard",
  theme = my_theme,

  sidebar = sidebar(
    width = 280,

    selectInput("class", "Vehicle class",
                choices  = c("All classes", all_classes),
                selected = "All classes"),

    checkboxGroupInput("year", "Model year",
                       choices  = c(1999, 2008),
                       selected = c(1999, 2008),
                       inline   = TRUE),

    checkboxGroupInput("drive", "Drive type",
                       choices  = c("Front", "Rear", "4WD"),
                       selected = c("Front", "Rear", "4WD")),

    sliderInput("cyl", "Cylinders",
                min = 4, max = 8, value = c(4, 8), step = 1),

    hr(),
    p(class = "text-muted small",
      "Data: ggplot2::mpg, EPA fuel economy for 38 popular models, 1999 and 2008.")
  ),

  # Row 1: headline numbers
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Cars selected",
      value = textOutput("n_cars"),
      showcase = icon("car"),
      theme = "primary"
    ),
    value_box(
      title = "Average highway MPG",
      value = textOutput("avg_hwy"),
      showcase = icon("road"),
      theme = "success"
    ),
    value_box(
      title = "Average city MPG",
      value = textOutput("avg_cty"),
      showcase = icon("city"),
      theme = "info"
    )
  ),

  # Row 2: two charts side by side
  layout_columns(
    col_widths = c(7, 5),
    card(
      full_screen = TRUE,
      card_header("Bigger engines, lower mileage"),
      plotOutput("scatter")
    ),
    card(
      full_screen = TRUE,
      card_header("Highway MPG by manufacturer"),
      plotOutput("by_make")
    )
  ),

  # Row 3: table of the most efficient cars
  card(
    card_header("Top 10 most fuel-efficient models (highway)"),
    tableOutput("top10")
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  # One filtered dataset, reused by every output
  filtered <- reactive({
    data <- cars |>
      filter(year  %in% input$year, # nolint
             drive %in% input$drive, # nolint
             cyl   >= input$cyl[1], # nolint
             cyl   <= input$cyl[2])

    if (input$class != "All classes") {
      data <- filter(data, class == input$class)
    }
    data
  })

  # Friendly message when the filters remove every car
  check_data <- function() {
    validate(need(nrow(filtered()) > 0,
                  "No cars match these filters. Try widening them."))
  }

  # ---- Value boxes ----
  output$n_cars  <- renderText(nrow(filtered()))
  output$avg_hwy <- renderText({
    check_data()
    round(mean(filtered()$hwy), 1)
  })
  output$avg_cty <- renderText({
    check_data()
    round(mean(filtered()$cty), 1)
  })

  # ---- Charts ----
  output$scatter <- renderPlot({
    check_data()
    ggplot(filtered(), aes(displ, hwy, color = drive)) + # nolint
      geom_jitter(size = 3, alpha = 0.7, width = 0.05, height = 0.3) +
      scale_color_manual(values = c(Front = "#2C7FB8", Rear = "#E6550D",
                                    `4WD` = "#31A354")) +
      labs(x = "Engine size (liters)", y = "Highway MPG", color = "Drive") +
      theme_dash
  })

  output$by_make <- renderPlot({
    check_data()
    filtered() |>
      group_by(make) |> # nolint
      summarise(hwy = mean(hwy)) |> # nolint
      ggplot(aes(x = hwy, y = reorder(make, hwy))) +
      geom_col(fill = "#2C7FB8") +
      geom_text(aes(label = round(hwy, 1)), hjust = -0.2, size = 4) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
      labs(x = "Average highway MPG", y = NULL) +
      theme_dash
  })

  # ---- Table ----
  output$top10 <- renderTable({
    check_data()
    filtered() |>
      arrange(desc(hwy), desc(cty)) |> # nolint
      distinct(make, model, year, .keep_all = TRUE) |> # nolint
      slice_head(n = 10) |>
      transmute(Make = make, Model = model, Year = as.integer(year),
                Class = class, Drive = drive, # nolint
                `City MPG` = as.integer(cty), `Highway MPG` = as.integer(hwy))
  }, striped = TRUE, hover = TRUE, width = "100%")
}

shinyApp(ui, server)
