library(sqldf)
library(Rsamtools)


orthologUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4, uiOutput(ns("vals"))),
            column(4, textInput(ns("ortholog"), "Ortholog: "))
        ),

        fluidRow(
            DT::dataTableOutput(ns("orthoTable"))
        ),

        fluidRow(
            h2("Ortholog information"),
            column(4, uiOutput(ns("row")))
        )
    )

}

orthologServer <- function(input, output, session) {
    output$vals <- renderUI({
        selectInput(session$ns('test'), 'Species', c('All', speciesData()$name))
    })

    orthologTable = reactive({
        data = orthologData()
        data
    })

    output$orthoTable = DT::renderDataTable(orthologTable(), selection = 'single')


    output$row = DT::renderDataTable({
        if (is.null(input$table_rows_selected)) {
            return()
        }
        orthologs = orthologData()
        species = speciesData()
        transcripts = transcriptData()

        row = orthologs[input$table_rows_selected, ]

        for(i in 2:ncol(row)) {
            print(row[, i])
        }
    })

    source('common.R', local = TRUE)
}
