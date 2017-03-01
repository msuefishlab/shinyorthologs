msaUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2('Multiple sequence alignment, ortholog')
        ),
        fluidRow(
            DT::dataTableOutput(ns('orthoTable'))
        ),

        fluidRow(
            h2('MSA'),
            msaR::msaROutput(ns('msaoutput'))
        )
    )
}
msaServer = function(input, output, session) {

    orthologTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species")

        # query returns another query
        query2 = RPostgreSQL::dbGetQuery(con, query)
        RPostgreSQL::dbGetQuery(con, query2[1, ])
    })

    output$orthoTable = DT::renderDataTable({
        orthologTable()
    },
    selection = 'single')


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


    output$heatmap = d3heatmap::renderD3heatmap({
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

        query = sprintf("SELECT g.gene_id, g.species_id, s.expression_file, s.species_name from genes g join species s on g.species_id = s.species_id where g.gene_id in %s", paste0('(', formatted_list, ')'))
        ret = RPostgreSQL::dbGetQuery(con, query)
        heatmapData = list()
        species = c()
        geneAndTissue = c()

        for (i in 1:nrow(ret)) {
            row = ret[i, ]
            if (!is.na(row[3])) {
                species = c(species, as.character(row[4]))
                expressionData = expressionFiles[[as.character(row[3])]]
                geneExpressionData = expressionData[expressionData[, 1] == as.character(row[1]), -1]
                geneAndTissue = c(geneAndTissue, paste(row[1], names(geneExpressionData)))
                heatmapData[[as.character(row[1])]] = geneExpressionData
            }
        }

        ncol = sum(sapply(heatmapData, length))
        nrow = length(heatmapData)
        h = matrix(ncol = ncol, nrow = nrow)
        counter = 1
        index = 1
        for (i in names(heatmapData)) {
            curr = heatmapData[[i]]
            end = counter + length(curr) - 1
            h[index, counter:end] = as.numeric(heatmapData[[i]])
            counter = end + 1
            index = index + 1
        }


        rownames(h) = species
        colnames(h) = geneAndTissue
        d3heatmap::d3heatmap(log(h + 1), dendrogram = "none")
    })
}
