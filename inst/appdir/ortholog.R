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
            DT::dataTableOutput(ns("row"))
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
        if (is.null(input$orthoTable_rows_selected)) {
            return()
        }
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))


        orthologs = orthologData()
        ids = orthologs[input$orthoTable_rows_selected, 2:ncol(orthologs)]
        ids = ids[!is.na(ids)]
        formatted_ids = sapply(ids, function(e) { paste0("'", e, "'") })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep=","))

        query = sprintf("SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from genes g join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where g.gene_id in %s", paste0('(', formatted_list, ')'))
        ret = dbGetQuery(con, query)
        rows = apply(ret, 1, function(row) {
            file = paste0(baseDir, '/', row[4])
            fa = open(FaFile(file))
            idx = scanFaIndex(fa)
            fasta = as.character(getSeq(fa, idx[seqnames(idx) == row[3]]))
            data.frame(gene_id = row[1], species_id = row[2], transcript_id = row[3], sequence = fasta)
        })
        do.call(rbind, rows)
    },
    options = list(columnDefs = list(list(
        targets = 4,
        render = DT::JS(
            "function(data, type, row, meta) {",
            "return type === 'display' && data.length > 100 ?",
            "'<span title=\"' + data + '\">' + data.substr(0, 60) + '...</span>' : data;",
            "}"
        ))))
    )

    source('common.R', local = TRUE)
}
