library(shiny)
library(ggplot2)
shinyUI(
  fluidPage(
    titlePanel("shinyorthologs"),

    # Create a new Row in the UI for selectInputs
    fluidRow(
      column(4, uiOutput("species")),
      column(4, textInput("gene", "Gene: "))
    ),

    fluidRow(
      DT::dataTableOutput("table")
    )
  )
)
