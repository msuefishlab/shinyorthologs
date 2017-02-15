library(sqldf)
library(data.table)
library(Rsamtools)


geneUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4, uiOutput(ns("vals"))),
            column(4, textInput(ns("gene"), "Gene: "))
        ),

        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),

        fluidRow(
            h2("Gene information"),
            column(4, uiOutput(ns("row")))
        )
    )

}

geneServer <- function(input, output, session) {
    output$vals <- renderUI({
        selectInput(session$ns('species'), 'Species', c('All', speciesData()$name))
    })

    output$table = DT::renderDataTable(geneTable(), selection = 'single')

    geneTable = reactive({
        data = geneData()
        species = speciesData()
        if (is.null(input$species)) {
            return(NULL)
        }
        if (input$species != "All") {
            ss = species[species$name == input$species, ]$shortName
            data = data[data$species == ss, ]
        }
        if (input$gene != "") {
            query = sprintf("select * from data where id LIKE '%%%s%%'", input$gene)
            data = sqldf(query)
        }
        data
    })


    source('common.R', local=TRUE)
}



