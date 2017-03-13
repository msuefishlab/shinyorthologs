genepageUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns("ortholog"), "Ortholog"),
        DT::dataTableOutput(ns("table")),
        textAreaInput(ns("fasta"), "Selected transcript sequence")
    )
}
genepageServer = function(input, output, session, box) {
    dataTable = reactive({
        if(is.null(input$ortholog) || input$ortholog == "") {
            return()
        }
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = "SELECT s.transcriptome_fasta, s.species_id, o.ortholog_id, o.evidence, g.gene_id, g.symbol, od.description, t.transcript_id FROM orthologs o join genes g on g.gene_id = o.gene_id left join species s on s.species_id = o.species_id left join orthodescriptions od on o.ortholog_id = od.ortholog_id left join dbxrefs db on g.gene_id = db.gene_id join transcripts t on t.gene_id = g.gene_id where o.ortholog_id = ?orthoid"
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })
    output$table = DT::renderDataTable({
        dataTable()[,c(2,3,4,5,6,7,8)]
    }, selection = 'single')

    observeEvent(input$table_rows_selected, {
        ret = dataTable()
        row = ret[input$table_rows_selected,]

        file = file.path(basedir, row[[1]])
        transcript_id = row[[8]]
        fa = open(Rsamtools::FaFile(file))
        idx = fastaIndexes[[row[[1]]]]
        fasta = as.character(Rsamtools::getSeq(fa, idx[GenomicRanges::seqnames(idx) == transcript_id]))
        updateTextAreaInput(session, 'fasta', value = paste0('>',transcript_id,'\n',as.character(fasta)))
    })
}
