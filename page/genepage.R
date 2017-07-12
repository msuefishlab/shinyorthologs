genepageUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('ortholog'), 'Ortholog', width=500),
        h3('Genes'),
        DT::dataTableOutput(ns('genes')),
        h3('Transcripts'),
        HTML('<button data-toggle="collapse" data-target="#transcripts_container">></button>'),
        tags$div(id = 'transcripts_container',  class="collapse",
            DT::dataTableOutput(ns('table')),
            uiOutput(ns('fasta')),
            downloadButton(ns('downloadData'), 'Download all FASTA')
        )
    )
}
genepageServer = function(input, output, session, box) {
    dataTable = reactive({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = 'SELECT s.transcriptome_fasta, s.species_id, o.ortholog_id, o.evidence, g.gene_id, g.symbol, od.description, t.transcript_id FROM orthologs o join genes g on g.gene_id = o.gene_id left join species s on s.species_id = o.species_id left join orthodescriptions od on o.ortholog_id = od.ortholog_id left join dbxrefs db on g.gene_id = db.gene_id join transcripts t on t.gene_id = g.gene_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })

    output$genes = DT::renderDataTable({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = 'SELECT s.species_id, o.ortholog_id, o.evidence, g.gene_id, od.symbol, od.description FROM orthologs o join genes g on g.gene_id = o.gene_id left join species s on s.species_id = o.species_id left join orthodescriptions od on o.ortholog_id = od.ortholog_id left join dbxrefs db on g.gene_id = db.gene_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    }, selection = 'single')

    output$table = DT::renderDataTable({
        dataTable()[,c(2,3,4,5,6,7,8)]
    }, selection = 'single')

    formatRow = function(row) {
        file = row$transcriptome_fasta
        transcript_id = row$transcript_id
        fa = open(Rsamtools::FaFile(file))
        idx = fastaIndexes[[file]]
        text = Rsamtools::getSeq(fa, idx[GenomicRanges::seqnames(idx) == transcript_id])
        sprintf('>%s [species=%s, gene_id=%s, gene_symbol=%s]\n%s', transcript_id, row$species_id, row$gene_id, row$symbol, text)
    }

    output$fasta = renderUI({
        if(is.null(input$table_rows_selected)) {
            return()
        }
        ret = dataTable()
        row = ret[input$table_rows_selected,]
        textAreaInput(session$ns('fastabox'), label = 'Transcript sequence', value = formatRow(row), width = '800px', height = '200px')
    })
    output$downloadData <- downloadHandler(
        filename = sprintf('%s.fa', input$ortholog),
        content = function(outfile) {
            tab = dataTable()
            o = file(outfile, 'w')
            for(i in 1:nrow(tab)) {
                row = tab[i, ]
                writeLines(formatRow(row), con = o)
            }
            close(o)
        }
    )
}
