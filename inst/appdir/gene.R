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

    # reactives
    fastaIndexFile <- reactive({
        scanFaIndex(open(FaFile(fastaFile())))
    })
    fastaFile <- reactive({
        species = speciesData()
        data = geneTable()
        row = data[input$table_rows_selected, ]
        ss = row$species
        paste0(baseDir, '/', species[species$shortName == ss, ]$file)
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

    output$table = DT::renderDataTable(geneTable(), selection = 'single',
         
     )

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
        ret = transcripts[transcripts$gene_id == row$id]
        seq = sapply(ret$transcript_id, function(n) {
            as.character(getSeq(fa, idx[seqnames(idx) == n]))
        })
        cbind(ret, seq)
    },
      options = list(columnDefs = list(list(
                                            targets=3,
    render = JS(
      "function(data, type, row, meta) {",
      "console.log('here!',arguments);return type === 'display' && data.length > 100 ?",
      "'<span title=\"' + data + '\">' + data.substr(0, 100) + '...</span>' : data;",
      "}"
    )
  )))
  
  )

    source('common.R', local = TRUE)
}
