library(sqldf)
library(Rsamtools)
library(RPostgreSQL)

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

    use_name = exists('db_name')
    use_port = exists('db_port')
    use_user = exists('db_user')
    use_pass = exists('db_pass')
    use_host = exists('db_host')
    if(!exists('db_port')) db_port=NULL
    if(!exists('db_host')) db_host=NULL
    if(!exists('db_name')) db_name=NULL
    if(!exists('db_pass')) db_pass=NULL
    if(!exists('db_user')) db_user=NULL
	args = c(
        PostgreSQL(),
		list(dbname = db_name)[use_name],
		list(host = db_host)[use_host],
		list(user = db_user)[use_user],
		list(password = db_pass)[use_pass],
		list(port = db_port)[use_port]
	)

    # reactives
    fastaIndexFile <- reactive({
        scanFaIndex(open(FaFile(fastaFile())))
    })
    fastaFile <- reactive({
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        data = geneTable()
        row = data[input$table_rows_selected, ]
        query <- sprintf("SELECT transcriptome_fasta from species where species_id = '%s'", row$species_id)
        df <- dbGetQuery(con, query)
        paste0(baseDir, '/', df)
    })
    geneTable = reactive({
        if (is.null(input$species)) {
            return(NULL)
        }
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        
        if (input$species != "All") {
            query <- sprintf("SELECT * from genes join species s on species_id == s.species_id where s.species_name = '%s'", input$species)
        } else {
            query <- sprintf("SELECT * from genes")
        }
        dbGetQuery(con, query)
    })
    
    # output
    output$vals <- renderUI({
        selectInput(session$ns('species'), 'Species', c('All', speciesData()$species_name))
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
