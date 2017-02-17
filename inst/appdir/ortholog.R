library(Rsamtools)
library(pheatmap)
library(msa)

source('pheatmap.R')

orthologUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            DT::dataTableOutput(ns("orthoTable"))
        ),

        fluidRow(
            h2("Ortholog information"),
            DT::dataTableOutput(ns("row"))
        ),

        fluidRow(
            h2("Heatmaps"),
            plotOutput(ns("heatmap"))
        ),

        fluidRow(
            h2("MSA"),
            verbatimTextOutput(ns("msa"))
        )
    )
}

orthologServer <- function(input, output, session) {

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


    output$msa = renderPrint({
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
        sequences = apply(ret, 1, function(row) {
            file = paste0(baseDir, '/', row[4])
            fa = open(FaFile(file))
            idx = scanFaIndex(fa)
            as.character(getSeq(fa, idx[seqnames(idx) == row[3]]))
        })
        sequences = DNAStringSet(sequences)
        names(sequences) = paste(ret[,3], ret[,2])
        alignment = msa(sequences, type = "dna")
        options(width = 160)
        print(alignment, show = "complete")

    })


    output$heatmap = renderPlot({
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

        query = sprintf("SELECT g.gene_id, g.species_id, s.expression_file, s.species_name from genes g join species s on g.species_id = s.species_id where g.gene_id in %s", paste0('(', formatted_list, ')'))
        ret = dbGetQuery(con, query)
        heatmapData = list()
        species = c()
        geneAndTissue = c()

        for(i in 1:nrow(ret)) {
            row = ret[i, ]
            if(!is.na(row[3])) {
                expressionFile = paste0(baseDir, '/', row[3])
                species = c(species, row[4])
                expressionData = read.csv(expressionFile, header=T)
                geneExpressionData = expressionData[expressionData[,1] == as.character(row[1]), -1]
                geneAndTissue = c(geneAndTissue, paste(row[1], names(geneExpressionData)))
                heatmapData[[as.character(row[1])]] = geneExpressionData
            }
        }
        ncol = sum(sapply(heatmapData, length))
        nrow = length(heatmapData)
        h = matrix(ncol = ncol, nrow = nrow)
        counter = 1
        index =1 
        for(i in names(heatmapData)) {
            curr = heatmapData[[i]]
            end = counter + length(curr) - 1
            h[index, counter:end] = as.numeric(heatmapData[[i]])
            counter = end + 1
            index = index + 1
        }


        rownames(h) <- species
        colnames(h) <- geneAndTissue
        pheatmap(log(h + 1),cluster_rows=F,cluster_cols=F)
    })

    source('common.R', local = TRUE)
}
