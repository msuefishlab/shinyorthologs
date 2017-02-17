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
        selectInput(session$ns('test'), 'Species', c('All', speciesData()$species_name))
    })

    orthologTable = reactive({
        data = orthologData()
        data
    })

    output$orthoTable = DT::renderDataTable(orthologTable(), selection = 'single')


    output$row = DT::renderDataTable({
        print(input$orthoTable_rows_selected)
        if (is.null(input$orthoTable_rows_selected)) {
            return()
        }
        orthologs = orthologData()
        species = speciesData()
        transcripts = transcriptData()

        row = orthologs[input$orthoTable_rows_selected, ]
        ids = row[2:length(row)]

        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        df = dbGetQuery(con, "select transcript_id from species")
        query = sprintf("SELECT * FROM crosstab('select ortholog_id, species_id, gene_id from orthologs order by 1,2', 'select species_id from species')")
        
        subquery = ''
        for(species in df$species_id) {
            subquery = paste(subquery, ",", species, "varchar(255)")
        }
        query = sprintf("%s AS ct(ortholog_id varchar(255) %s)", query, subquery)
        dbGetQuery(con, query)

    })





    output$row = DT::renderDataTable({
        if (is.null(input$orthoTable_rows_selected)) {
            return()
        }
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))


        orthologs = orthologData()
        ids = orthologs[input$orthoTable_rows_selected, 2:ncol(orthologs)]
        formatted_ids = sapply(ids, function(e) { paste0("'", e, "'") })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep=","))

        query = sprintf("SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from genes g join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where g.gene_id in %s", paste0('(', formatted_list, ')'))
        print(query)
        ret = dbGetQuery(con, query)
        apply(ret, 1, function(row) {
            print(row)
            file = paste0(baseDir, '/', row[4])
            fa = open(FaFile(file))
            idx = scanFaIndex(fa)
            fasta = as.character(getSeq(fa, idx[seqnames(idx) == row[3]]))
            c(row[1],row[2],row[3],fasta)
        })
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

    source('common.R', local = TRUE)
}
