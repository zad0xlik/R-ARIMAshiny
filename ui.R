library(shiny)
## Create the shiny user interface
shinyUI(pageWithSidebar(
  ## Main title
  headerPanel("Estimate Performance"),
 
  sidebarPanel(
    helpText("This app estimates different measures based on current data"),
    wellPanel(
    p(strong("Measures")),
    checkboxInput(inputId = "gdp", label = "GDP", value = TRUE),
    checkboxInput(inputId = "hpi", label = "HPI", value = FALSE),
    checkboxInput(inputId = "unrate",  label = "UNRATE", value = FALSE)),

    submitButton("Submit"),
    p("Documentation:", a("About", href = "About.html"))
    ),
  mainPanel(
    tabsetPanel(
      ## Tab with the plot of the Forecast object
      tabPanel("Arima Plot",
      conditionalPanel(condition = "input.gdp",
                       br(),
                       div(plotOutput(outputId = "plot_gdp"))),
      
      conditionalPanel(condition = "input.hpi",
                       br(),
                       div(plotOutput(outputId = "plot_hpi"))),
      
      conditionalPanel(condition = "input.unrate",
                       br(),
                       div(plotOutput(outputId = "plot_unrate")))),
      ## Tab with the actual Forecast object
      tabPanel("Arima Forecast",
               conditionalPanel(condition = "input.gdp",
                                br(),
                                div(dataTableOutput(outputId = "Fcast_gdp"))),
               
               conditionalPanel(condition = "input.hpi",
                                br(),
                                div(plotOutput(outputId = "Fcast_hpi"))),
               
               conditionalPanel(condition = "input.unrate",
                                br(),
                                div(plotOutput(outputId = "Fcast_unrate"))))
    
    )
  )
)
)