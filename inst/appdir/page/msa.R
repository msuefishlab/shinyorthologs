msaUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2('Multiple sequence alignment, ortholog')
        ),

        fluidRow(
            h2('MSA'),
            msaR::msaROutput(ns('msaoutput'))
        )
    )
}
msaServer = function(input, output, session) {



    output$msaoutput = msaR::renderMsaR({
        if (is.null(input$orthoTable_rows_selected)) {
            return()
        }
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))


        orthologs = orthologTable()
        ids = orthologs[input$orthoTable_rows_selected, 2:ncol(orthologs)]
        ids = ids[!is.na(ids)]
        formatted_ids = sapply(ids, function(e) {
            paste0("'", e, "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))

        query = sprintf('SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from genes g join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where g.gene_id in %s', paste0('(', formatted_list, ')'))
        ret = RPostgreSQL::dbGetQuery(con, query)
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
