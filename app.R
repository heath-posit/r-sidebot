# A Shiny app that includes a ChatGPT sidebot


# Required packages
library(shiny)
library(bslib)
library(fontawesome)
library(reactable)
library(here)
library(plotly)
library(ggplot2)
library(ggridges)
library(dplyr)
library(querychat)

source("./R/explain-plot.R")
source("./R/import_format.R")

# Load the data
dat_in <- import_format()

# Define the query chat handle
querychat_handle <- querychat_init(
  df = dat_in,
  # This is the greeting that should initially appear in the sidebar when the app
  # loads.
  greeting = readLines(here("greeting.md"),
                       warn = FALSE),
#  create_chat_func = purrr::partial(ellmer::chat_azure,
#                                    deployment_id = "gpt-4o-mini",
#                                    endpoint = "https://openai-doichatgpt-dev.openai.azure.com/"),
#  system_prompt = readLines(here("prompt.md"),
#                            warn = FALSE)
)

# Create icon
icon_explain <- tags$img(src = "stars.svg")


## Define the user interface
ui <- page_sidebar(
  style = "background-color: rgb(248, 248, 248);",
  title = "Aviation Data",
  includeCSS(here("styles.css")),
  sidebar = querychat_sidebar("chat"),
  useBusyIndicators(),

  # 🏷️ Header
  textOutput("show_title", container = h3),
  verbatimTextOutput("show_query") |>
    tagAppendAttributes(style = "max-height: 100px; overflow: auto;"),

  # 🎯 Value boxes
  layout_columns(
    fill = FALSE,
    value_box(
      showcase = fa_i("plane"),
      "Total flights",
      textOutput("total_flights", inline = TRUE)
    ),
    value_box(
      showcase = fa_i("wallet"),
      "Average cost per flight",
      textOutput("average_cost", inline = TRUE)
    ),
    value_box(
      showcase = fa_i("dollar-sign"),
      "Total cost",
      textOutput("total_cost", inline = TRUE)
    ),
  ),
  layout_columns(
    style = "min-height: 450px;",
    col_widths = c(6, 6, 12),

    # 🔍 Data table
    card(
      style = "height: 500px;",
      card_header("Aviation data"),
      reactableOutput("table", height = "100%")
    ),

    # 📊 Histogram plot
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "Flight costs",
        span(
          actionLink(
            "interpret_histo",
            icon_explain,
            class = "me-3 text-decoration-none",
            aria_label = "Explain plot"
          )
        )
      ),
      plotlyOutput("histo")
    ),

    # 📊 Time series plot
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        "Weekly costs",
        span(
          actionLink(
            "interpret_bar",
            icon_explain,
            class = "me-3 text-decoration-none",
            aria_label = "Explain plot")
        )
      ),
      plotOutput("bar_plot")
    )
  )
)

# Define the server
server <- function(input, output, session) {
  # 🔄 Reactive state/computation --------------------------------------------

  querychat <- querychat_server("chat", querychat_handle)

  # We don't normally need the chat object, but in this case, we want it so we
  # can pass it to explain_plot
  chat <- querychat$chat

  # The reactive data frame. Either returns the entire dataset, or filtered by
  # whatever querychat decided.
  #
  # querychat$df is already a reactive data frame, we're just creating an alias
  # to it called `dat` so the code below can be more readable.
  dat <- querychat$df



  # 🏷️ Header outputs --------------------------------------------------------

  output$show_title <- renderText({
    querychat$title()
  })

  output$show_query <- renderText({
    querychat$sql()
  })



  # 🎯 Value box outputs -----------------------------------------------------

  output$total_flights <- renderText({
    nrow(dat())
  })

  output$average_cost <- renderText({
    x <- mean(dat()$cost, na.rm = T)
    paste0("$", formatC(x, format = "f", digits = 2, big.mark = ","))
  })

  output$total_cost <- renderText({
    x <- sum(dat()$cost, na.rm = T)
    paste0("$", formatC(x, format = "f", digits = 2, big.mark = ","))
  })



  # 🔍 Data table ------------------------------------------------------------

  output$table <- renderReactable({
    reactable(dat(),
              pagination = FALSE,
              compact = TRUE)
  })



  # 📊 Histogram plot ----------------------------------------------------------

  histo <- reactive({
    req(nrow(dat()) > 0)

    color <- input$scatter_color

    data <- dat()

    p <- plot_ly(data,
                 x = ~cost,
                 alpha = 0.7,
                 type = "histogram")
    p <- p %>%
      layout(barmode = "stack")

    return(p)
  })

  output$histo <- renderPlotly({
    histo()
  })

  observeEvent(input$interpret_histo, {
    explain_plot(chat,
                 histo(),
                 .ctx = ctx)
  })



  # 📊 Time series plot ------------------------------------------------------------

  bar_plot <- reactive({
    req(nrow(dat()) > 0)

    df <- dat() |>
      mutate(year_week = floor_date(date, "1 week")) |>
      group_by(year_week) |>
      summarize(cost = sum(cost, na.rm = T))

    ggplot(
      df,
      aes(x = year_week, y = cost)) +
      geom_bar(stat = "identity") +
      stat_smooth(method = "gam") +
      xlab("Week")
  })

  output$bar_plot <- renderPlot({
    bar_plot()
  })

  observeEvent(input$interpret_bar, {
    explain_plot(chat,
                 bar_plot(),
                 .ctx = ctx)
  })

}

shinyApp(ui, server)
