msaUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2('Multiple sequence alignment, ortholog')
        ),

        fluidRow(
            h2('MSA'),
            textInput(ns("ortholog"), "Ortholog"),
            msaR::msaROutput(ns('msaoutput'))
        )
    )
}
msaServer = function(input, output, session, box) {
    output$msaoutput = msaR::renderMsaR({
        
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = "SELECT o.gene_id FROM orthologs o join species s on s.species_id = o.species_id where ortholog_id = ?orthoid"
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)
        print(ret)
        
        ids = ret[!is.na(ret[,1]),]
        formatted_ids = sapply(ids, function(e) {
            paste0("'", e, "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))

        query = "SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from genes g join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where g.gene_id in ?geneids"
        q = sqlInterpolate(conn, query, geneids = paste0('(', formatted_list, ')'))
        print(q)
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)

        sequences = apply(ret, 1, function(row) {
            file = file.path(basedir, row[4])
            fa = open(Rsamtools::FaFile(file))
            idx = fastaIndexes[[row[4]]]
            as.character(Rsamtools::getSeq(fa, idx[GenomicRanges::seqnames(idx) == row[3]]))
        })
        sequences = Biostrings::DNAStringSet(sequences)
        names(sequences) = paste(ret[, 3], ret[, 2])
        alignment = msa::msaClustalW(sequences)
        msaR::msaR(Biostrings::DNAStringSet(as.character(alignment)))
    })
}
