library(Rsamtools)

geneUI = function(id) {
    ns = NS(id)
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

geneServer = function(input, output, session) {


    # reactives
    fastaIndexFile = reactive({
        scanFaIndex(open(FaFile(fastaFile())))
    })
    fastaFile = reactive({
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        data = geneTable()
        row = data[input$table_rows_selected, ]
        query = sprintf("SELECT transcriptome_fasta from species where species_name = '%s'", row$species_name)
        df = dbGetQuery(con, query)
        paste0(baseDir, '/', df)
    })
    geneTable = reactive({
        if (is.null(input$species)) {
            return(NULL)
        }
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        
        if (input$species != "All") {
            query = sprintf("SELECT gene_id, s.species_name from genes g join species s on g.species_id = s.species_id where s.species_name = '%s'", input$species)
        } else {
            query = sprintf("SELECT gene_id, s.species_name from genes g join species s on g.species_id = s.species_id")
        }
        dbGetQuery(con, query)
    })
    # output
    output$vals = renderUI({
        selectInput(session$ns('species'), 'Species', c('All', speciesData()$species_name))
    })

    output$table = DT::renderDataTable(geneTable(), selection = 'single')

    output$row = DT::renderDataTable({
        if (is.null(input$table_rows_selected)) {
            return()
        }
        data = geneTable()
        species = speciesData()

        file = fastaFile()
        fa = open(FaFile(file))
        idx = fastaIndexFile()

        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        
        row = data[input$table_rows_selected, ]
        query = sprintf("SELECT * from transcripts where gene_id = '%s'", row$gene_id)
        ret = dbGetQuery(con, query)
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
