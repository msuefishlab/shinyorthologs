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
            DT::dataTableOutput(ns("row"))
        )
    )

}

geneServer <- function(input, output, session) {
    #library(RPostgreSQL)

    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, host=db_host, port=db_port, dbname=db_name, user=db_user, pass=db_pass)


    # reactives
    fastaIndexFile <- reactive({
        scanFaIndex(open(FaFile(fastaFile())))
    })
    fastaFile <- reactive({
        species = speciesData()
        data = geneTable()
        row = data[input$table_rows_selected, ]
        ss = row$species_id
        paste0(baseDir, '/', species[species$species_id == ss, ]$transcriptome_fasta)
    })
    geneTable = reactive({
        data = geneData()
        species = speciesData()
        if (is.null(input$species)) {
            return(NULL)
        }
        if (input$species != "All") {
            ss = species[species$species_name == input$species, ]$species_id
            data = data[data$species_id == ss, ]
        }
        if (input$gene != "") {
            query = sprintf("select * from data where id LIKE '%%%s%%'", input$gene_id)
            data = sqldf(query)
        }
        data
    })

    # output
    output$vals <- renderUI({
        selectInput(session$ns('species'), 'Species', c('All', speciesData()$species_id))
    })

    output$table = DT::renderDataTable(geneTable(), selection = 'single')

    output$row = DT::renderDataTable({
        if (is.null(input$table_rows_selected)) {
            return()
        }
        data = geneTable()
        species = speciesData()
        transcripts = transcriptData()

        file = fastaFile()
        fa = open(FaFile(file))
        idx = fastaIndexFile()
        row = data[input$table_rows_selected, ]
        ret = transcripts[transcripts$gene_id == row$gene_id]
        seq = sapply(ret$transcript_id, function(n) {
            as.character(getSeq(fa, idx[seqnames(idx) == n]))
        })
        cbind(ret, seq)
    },
    options = list(columnDefs = list(list(
        targets = 3,
        render = DT::JS(
            "function(data, type, row, meta) {",
            "return type === 'display' && data.length > 100 ?",
            "'<span title=\"' + data + '\">' + data.substr(0, 100) + '...</span>' : data;",
            "}"
        ))))
    )


    # reactives/config
    source('common.R', local = TRUE)


}
