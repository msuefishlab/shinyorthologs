library(pheatmap)
library(reshape2)


comparisonsUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            textAreaInput(
                ns('genes'),
                'Enter a list of orthoIDs',
                rows = 10,
                width = '600px'
            )
        ),
        actionButton(ns('example'), 'Example'),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download'),
        h2('Heatmaps'),
        plotOutput(ns('heatmap'), height = '700px', width = '1000px')
    )
}
comparisonsServer = function(input, output, session) {

    heatmapData = reactive({
        if (is.null(input$genes)) {
            return()
        }
        if (input$genes == '') {
            return()
        }
        x = strsplit(input$genes, '\n')
        print(x)
        formatted_ids = sapply(x, function(e) {
            paste0("'", trimws(e), "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ','))
        mylist = paste0('(', formatted_list, ')')
        
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))


        query = sprintf('SELECT o.ortholog_id, o.species_id, od.symbol, o.gene_id, s.expression_file FROM orthologs o JOIN species s on o.species_id=s.species_id JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id WHERE o.ortholog_id IN %s', mylist)
        rs = dbSendQuery(conn, query)
        ret = dbFetch(rs)
        print(head(ret))
        dat = data.frame(ID = character(0),variable = character(0),value = numeric(0))
        for (i in 1:nrow(ret)) {
            row = ret[i, ]
            if (!is.na(row$expression_file)) {
                expressionData = expressionFiles[[as.character(row$expression_file)]]
                geneExpressionData = expressionData[expressionData[, 1] == as.character(row$gene_id), ]
                m = melt(geneExpressionData)
                m[, 1] = paste(as.character(row$ortholog_id), as.character(row$symbol))
                m[, 2] = paste(as.character(row$species_id), m[, 2])
                names(m) = c('ID', 'variable', 'value')
                dat = rbind(dat, m)
            }
        }
        h = acast(dat, ID ~ variable)
        h[is.na(h)] = 0
        h
    })


    output$heatmap = renderPlot({
        if (is.null(input$genes)) {
            return()
        }
        if (input$genes == '') {
            return()
        }
        h = heatmapData()
        pheatmap(log(h + 1))
    })


    output$downloadData <- downloadHandler(
        filename = 'heatmap.csv',
        content = function(file) {
            write.table(heatmapData(), file, quote = F, sep = '\t')
        }
    )
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = 'ORTHO:00000006\nORTHO:00000008\nORTHO:00000010\nORTHO:00000014\nORTHO:00000015\nORTHO:00000016\nORTHO:00000018\nORTHO:00000019\nORTHO:00000011\nORTHO:00000012\nORTHO:00000013')
    })
}
