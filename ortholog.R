library(sqldf)
library(data.table)
library(Rsamtools)


orthologUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4, uiOutput(ns("vals"))),
            column(4, textInput(ns("ortholog"), "Ortholog: "))
        ),

        fluidRow(
            DT::dataTableOutput(ns("table"))
        ),

        fluidRow(
            h2("Ortholog information"),
            column(4, uiOutput(ns("row")))
        )
    )

}

orthologServer <- function(input, output, session) {
    output$vals <- renderUI({
        selectInput(session$ns('test'), 'Species', c('All'))
    })
}



