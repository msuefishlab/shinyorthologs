library(msa)
library(msaR)
library(Biostrings)
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
        if(is.null(input$ortholog) || input$ortholog == "") {
            return()
        }
        
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))

        progress <- shiny::Progress$new()
        on.exit(progress$close())

        progress$set(message = "Making plot", value = 0)
        
        progress$inc(1/4, detail = paste("Searching database"))
        query = "SELECT g.gene_id, g.species_id, t.transcript_id, s.transcriptome_fasta from orthologs o join genes g on o.gene_id = g.gene_id join transcripts t on g.gene_id = t.gene_id join species s on g.species_id = s.species_id where o.ortholog_id = ?orthoid"
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)
        print(ret)
        
        
        progress$inc(1/4, detail = paste("Loading FASTA"))

        sequences = apply(ret, 1, function(row) {
            file = file.path(basedir, row[4])
            fa = open(Rsamtools::FaFile(file))
            idx = fastaIndexes[[row[4]]]
            as.character(Rsamtools::getSeq(fa, idx[GenomicRanges::seqnames(idx) == row[3]]))
        })
        sequences = Biostrings::DNAStringSet(sequences)
        names(sequences) = paste(ret[, 3], ret[, 2])
        progress$inc(1/4, detail = paste("Aligning sequences"))
        alignment = msa::msaClustalW(sequences)
        progress$inc(1/4, detail = paste("Creating plot"))
        msaR::msaR(Biostrings::DNAStringSet(as.character(alignment)))
    })
}
