library(sqldf)
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

    # reactives
    myIdx <- reactive({
        scanFaIndex(open(FaFile(myFile())))
    })
    myFile <- reactive({
        species = speciesData()
        data = geneTable()
        row = data[input$table_rows_selected, ]
        ss = row$species
        species[species$shortName == ss, ]$file
    })
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

    # output
    output$vals <- renderUI({
        selectInput(session$ns('species'), 'Species', c('All', speciesData()$name))
    })

    output$table = DT::renderDataTable(geneTable(), selection = 'single')

    output$row = renderTable({
        if (is.null(input$table_rows_selected)) {
            return()
        }
        data = geneTable()
        species = speciesData()
        transcripts = transcriptData()

        row = data[input$table_rows_selected, ]
        ret = transcripts[transcripts$gene_id == row$id, ]
        ss = row$species
        file = species[species$shortName == ss, ]$file
        fa = open(FaFile(file))
        idx = myIdx()
        seq = sapply(ret$transcript_id, function(n) {
            as.character(getSeq(fa, idx[seqnames(idx) == n]))
        })
        cbind(ret, seq)
    })

    source('common.R', local = TRUE)
}



