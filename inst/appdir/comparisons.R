library(pheatmap)

comparisonsUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            textAreaInput(ns("genes"), "Enter a list of orthoIDs")
        ),

        fluidRow(
            h2('Heatmaps'),
            plotOutput(ns('heatmap'))
        )
    )
}

comparisonsServer <- function(input, output, session) {
    output$heatmap = renderPlot({
        print(input$genes)
        if(is.null(input$genes)) {
            return()
        }
        if(trim(input$genes) == "") {
            return()
        }

        x = strsplit(input$genes, "\n")
        y = lapply(x, trim)
        formatted_ids = sapply(y, function(e) { paste0("''", e, "''") })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep=","))
        mylist = paste0('(', formatted_list, ')')


        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))
        query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs WHERE ortholog_id IN %s ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species", mylist)
        ret = dbGetQuery(con, query)
        ret2 = dbGetQuery(con, ret[1,])
        print("RET2")
        print(ret2)
        ids = ret2[,1]
        print("IDS")
        print(ids)

        ids = ids[!is.na(ids)]
        formatted_ids = sapply(ids, function(e) { paste0("'", e, "'") })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep=","))
        print("FORMAMMTT")
        print(formatted_list)

        query = sprintf("SELECT g.gene_id, g.species_id, s.expression_file, s.species_name from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id where o.ortholog_id in %s", paste0('(', formatted_list, ')'))
        ret = dbGetQuery(con, query)
        heatmapData = list()
        species = c()
        geneAndTissue = c()
        print("RET333333")
        print(ret)

        for(i in 1:nrow(ret)) {
            row = ret[i, ]
            print(row)
            if(!is.na(row[3])) {
                expressionFile = paste0(baseDir, '/', row[3])
                species = c(species, row[4])
                expressionData = expressionFiles[[expressionFile]]
                geneExpressionData = expressionData[expressionData[,1] == as.character(ids, -1)]
                print(geneExpressionData)
                print(ret)
            }
        }
        


        plot(1:10)

#        orthologs = orthologData()
#        ids = orthologs[input$orthoTable_rows_selected, 2:ncol(orthologs)]
#        ids = ids[!is.na(ids)]
#        formatted_ids = sapply(ids, function(e) { paste0("'", e, "'") })
#        formatted_list = do.call(paste, c(as.list(formatted_ids), sep=","))
#
#        query = sprintf("SELECT g.gene_id, g.species_id, s.expression_file, s.species_name from genes g join species s on g.species_id = s.species_id where g.gene_id in %s", paste0('(', formatted_list, ')'))
#        ret = dbGetQuery(con, query)
#        heatmapData = list()
#        species = c()
#        geneAndTissue = c()
#
#        for(i in 1:nrow(ret)) {
#            row = ret[i, ]
#            if(!is.na(row[3])) {
#                expressionFile = paste0(baseDir, '/', row[3])
#                species = c(species, row[4])
#                expressionData = read.csv(expressionFile, header=T)
#                geneExpressionData = expressionData[expressionData[,1] == as.character(row[1]), -1]
#                geneAndTissue = c(geneAndTissue, paste(row[1], names(geneExpressionData)))
#                heatmapData[[as.character(row[1])]] = geneExpressionData
#            }
#        }
#        ncol = sum(sapply(heatmapData, length))
#        nrow = length(heatmapData)
#        h = matrix(ncol = ncol, nrow = nrow)
#        counter = 1
#        index = 1 
#        for(i in names(heatmapData)) {
#            curr = heatmapData[[i]]
#            end = counter + length(curr) - 1
#            h[index, counter:end] = as.numeric(heatmapData[[i]])
#            counter = end + 1
#            index = index + 1
#        }
#
#
#        rownames(h) <- species
#        colnames(h) <- geneAndTissue
#        pheatmap(log(h + 1), cluster_rows = F, cluster_cols = F)
    })

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
