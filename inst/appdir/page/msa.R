library(msa)
library(msaR)
library(Biostrings)
library(GenomicRanges)
library(Rsamtools)

msaUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2('Multiple sequence alignment, ortholog')
        ),

        fluidRow(
            h2('MSA'),
            textInput(ns('ortholog'), 'Ortholog'),
            msaROutput(ns('msaoutput'))
        )
    )
}
msaServer = function(input, output, session, box) {
    output$msaoutput = renderMsaR({
        if(is.null(input$ortholog) || input$ortholog == '') {
            return()
        }
        
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))

        progress <- Progress$new()
        on.exit(progress$close(), add=T)

        progress$set(message = 'MSA', value = 0)
        progress$inc(1/4, detail = paste('Searching database'))
        query = 'SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from orthologs o join genes g on o.gene_id = g.gene_id join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where o.ortholog_id = ?orthoid'
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)
        print(ret)
        
        
        progress$inc(1/4, detail = paste('Loading FASTA'))

        sequences = apply(ret, 1, function(row) {
            file = row[4]
            fa = open(FaFile(file))
            idx = fastaIndexes[[row[4]]]
            as.character(getSeq(fa, idx[seqnames(idx) == row[3]]))
        })
        sequences = DNAStringSet(sequences)
        names(sequences) = paste(ret[, 3], ret[, 2])
        progress$inc(1/4, detail = paste('Aligning sequences'))
        alignment = msaClustalW(sequences)
        progress$inc(1/4, detail = paste('Creating plot'))
        msaR(DNAStringSet(as.character(alignment)))
    })
}
