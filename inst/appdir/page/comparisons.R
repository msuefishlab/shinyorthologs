library(pheatmap)
library(reshape2)


comparisonsUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            textAreaInput(
                ns("genes"),
                "Enter a list of orthoIDs",
                rows = 10,
                width = "600px"
            )
        ),
        actionButton(ns('example'), 'Example'),
        h2('Heatmaps'),
        plotOutput(ns('heatmap'), height = '700px', width = '900px')
    )
}
comparisonsServer = function(input, output, session) {
    output$heatmap = renderPlot({
        if (is.null(input$genes)) {
            return()
        }
        if (input$genes == "") {
            return()
        }
        x = strsplit(input$genes, "\n")
        print(x)
        formatted_ids = sapply(x, function(e) {
            paste0("'", trimws(e), "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ","))
        mylist = paste0('(', formatted_list, ')')
        
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))


        query = sprintf("SELECT * FROM orthologs o JOIN species s on o.species_id=s.species_id WHERE ortholog_id IN %s", mylist)
        rs = dbSendQuery(conn, query)
        ret = dbFetch(rs)
        dat = data.frame(ID = character(0),variable = character(0),value = numeric(0))
        for (i in 1:nrow(ret)) {
            row = ret[i, ]
            if (!is.na(row[11])) {
                expressionData = expressionFiles[[as.character(row[11])]]
                geneExpressionData = expressionData[expressionData[, 1] == as.character(row[3]), ]
                m = melt(geneExpressionData)
                m[, 1] = as.character(row[1])
                m[, 2] = paste(as.character(row[2]), m[, 2])
                names(m) = c('ID', 'variable', 'value')
                dat = rbind(dat, m)
            }
        }
        h = acast(dat, ID ~ variable)
        h[is.na(h)] = 0
        pheatmap(log(h + 1))
    })
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = 'ORTHO:00000006\nORTHO:00000008\nORTHO:00000010\nORTHO:00000014\nORTHO:00000015\nORTHO:00000016\nORTHO:00000018\nORTHO:00000019\nORTHO:00000011\nORTHO:00000012\nORTHO:00000013')
    })
}
