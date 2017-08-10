genepageUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('ortholog'), 'Ortholog', width=500),
        actionButton(ns('example'), 'Example'),
        uiOutput(ns('stats')),
        h3('Genes in orthogroup'),
        DT::dataTableOutput(ns('genes')),
        uiOutput(ns('fasta')),
        downloadButton(ns('downloadData'), 'Download FASTA')
    )
}
genepageServer = function(input, output, session, box) {
    dataTable = reactive({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = 'SELECT s.species_id, o.ortholog_id, o.evidence, g.gene_id, g.symbol, od.description, t.transcript_id, f.sequence FROM orthologs o join genes g on g.gene_id = o.gene_id left join species s on s.species_id = o.species_id left join orthodescriptions od on o.ortholog_id = od.ortholog_id left join dbxrefs db on g.gene_id = db.gene_id join transcripts t on t.gene_id = g.gene_id join fasta f on t.transcript_id = f.transcript_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })

    output$stats = renderUI({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = 'SELECT o.ortholog_id, o.evidence, od.symbol, od.description, e.link, e.title FROM orthologs o left join orthodescriptions od on o.ortholog_id = od.ortholog_id join evidence e on o.evidence = e.evidence_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        res = dbFetch(rs)
        tagList(
            div(class='search_results',
                h4('Ortholog information'),
                p(em('ID:'), res$ortholog_id),
                p(em('Descrition: '), res$description),
                p(em('Evidence: '), a(href=res$link, e.title)),
                p(em('Symbol: '), res$symbol)
            )
        )
    })

    output$genes = DT::renderDataTable({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = 'SELECT s.species_id, g.gene_id, g.symbol, od.description FROM orthologs o join genes g on g.gene_id = o.gene_id left join species s on s.species_id = o.species_id left join orthodescriptions od on o.ortholog_id = od.ortholog_id left join dbxrefs db on g.gene_id = db.gene_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    }, selection = 'single')

    output$table = DT::renderDataTable({
        d = dataTable()
        loginfo(colnames(d))
        d[,c('gene_id','transcript_id','sequence')]
    }, selection = 'single')

    formatRow = function(row) {
        sprintf('>%s [species=%s, gene_id=%s, gene_symbol=%s]\n%s', row$transcript_id, row$species_id, row$gene_id, row$symbol,  gsub('(.{1,80})', '\\1\n', row$sequence))
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
            out = file(outfile, 'w')
            for(i in 1:nrow(tab)) {
                writeLines(formatRow(tab[i,]), con = out)
            }
            close(out)
        }
    )
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = config$sample_ortholog_lookup)
    })
}
