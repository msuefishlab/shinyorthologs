       
comparisonsUI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            textAreaInput(ns("genes"), "Enter a list of orthoIDs", rows = 10, width = "600px")
        ),
        actionButton(ns('example'), 'Example'),
        h2('Heatmaps'),
        p('Note: the species where it does not have an ortholog identified are given a value of 0, which may bias the heatmap. Therefore, use complete ortholog groups'),
        plotOutput(ns('heatmap'), height = "900px")
    )
}
comparisonsServer <- function(input, output, session) {
    output$heatmap = renderPlot({
        if (is.null(input$genes)) {
            return()
        }
        if (input$genes == "") {
            return()
        }

        x = strsplit(input$genes, "\n")
        formatted_ids = sapply(x, function(e) {
            paste0("''", e, "''")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))
        mylist = paste0('(', formatted_list, ')')


        con = do.call(RPostgreSQL::dbConnect, args)
        on.exit(RPostgreSQL::dbDisconnect(con))
        query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs WHERE ortholog_id IN %s ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species", mylist)
        ret = RPostgreSQL::dbGetQuery(con, query)
        ret2 = RPostgreSQL::dbGetQuery(con, ret[1, ])
        ids = ret2[, 1]

        ids = ids[!is.na(ids)]
        formatted_ids = sapply(ids, function(e) {
            paste0("'", e, "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))

        query = sprintf("SELECT g.gene_id, g.species_id, s.expression_file, s.species_name, o.ortholog_id from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id where o.ortholog_id in %s", paste0('(', formatted_list, ')'))
        ret = RPostgreSQL::dbGetQuery(con, query)
        dat = data.frame(ID = character(0), variable = character(0), value = numeric(0))

        for (i in 1:nrow(ret)) {
            row = ret[i, ]
            if (!is.na(row[3])) {
                expressionData = expressionFiles[[as.character(row[3])]]
                geneExpressionData = expressionData[expressionData[, 1] == as.character(row[1]), ]
                m = reshape2::melt(geneExpressionData)
                m[, 1] = as.character(row[5])
                m[, 2] = paste(as.character(row[4]), m[, 2])
                names(m) <- c('ID', 'variable', 'value')
                dat = rbind(dat, m)
            }
        }

        h = reshape2::acast(dat, ID~variable)
        h[is.na(h)] = 0
        pheatmap::pheatmap(log(h + 1))
    })

    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = 'ORTHO:00000006\nORTHO:00000008\nORTHO:00000010\nORTHO:00000014\nORTHO:00000015\nORTHO:00000016\nORTHO:00000018\nORTHO:00000019\nORTHO:00000011\nORTHO:00000012\nORTHO:00000013')
    })
}
