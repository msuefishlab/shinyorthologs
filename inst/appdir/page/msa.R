msaUI = function(id) {
    ns = NS(id)
    tagList(fluidRow(h2(
        'Multiple sequence alignment, ortholog'
    )),

    fluidRow(h2('MSA'),
             msaR::msaROutput(ns('msaoutput'))))
}
msaServer = function(input, output, session) {
    output$msaoutput = msaR::renderMsaR({
        conn <- poolCheckout(pool)
        rs <- dbSendQuery(conn, "SELECT * FROM species")
        ret = dbFetch(rs)
        orthologs = orthologTable()
        ids = orthologs[input$orthoTable_rows_selected, 2:ncol(orthologs)]
        ids = ids[!is.na(ids)]
        formatted_ids = sapply(ids, function(e) {
            paste0("'", e, "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))

        query = dbSendQuery(
            'SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from genes g join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where g.gene_id in ?'
        )
        res = dbBind(query, paste0('(', formatted_list, ')'))
        ret = dbFetch(res)

        poolReturn(conn)
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
