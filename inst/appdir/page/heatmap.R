library(pheatmap)
library(reshape2)
library(RColorBrewer)

heatmapUI = function(id) {
    ns = NS(id)
    tagList(
        textAreaInput(ns('genes'), 'Enter a list of orthoIDs', height = '200px', width = '600px'),
        p('Plot log10-scaled gene expressions values across species'),
        p('Optionally normalize columns (individual samples)'),
        
        checkboxInput(ns('normalizeCols'), 'Normalize columns?'),
        checkboxInput(ns('redGreen'), 'Red-black-green colors?'),
        actionButton(ns('example'), 'Example'),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download'),
        h2('Heatmaps'),
        plotOutput(ns('heatmap'), height = '700px', width = '1000px')
    )
}
heatmapServer = function(input, output, session) {

    heatmapData = reactive({
        if (is.null(input$genes)) {
            return()
        }
        if (input$genes == '') {
            return()
        }
        x = strsplit(input$genes, '\n')
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
        dat = data.frame(ID = character(0), variable = character(0), value = numeric(0))
        for (i in 1:nrow(ret)) {
            row = ret[i, ]
            if (!is.null(row$expression_file)&!is.na(row$expression_file)) {
                expressionData = expressionFiles[[row$expression_file]]
                colnames(expressionData)[1] <- "gene_id"
                geneExpressionData = subset(expressionData, gene_id == row$gene_id)
                m = melt(geneExpressionData, id.vars = "gene_id")
                m[, 1] = paste(row$ortholog_id, ifelse(is.na(row$symbol),'',row$symbol))
                m[, 2] = paste(row$species_id, m$variable)
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
        d = log(h + 1)
        if(input$normalizeCols) {
            d = scale(d)[1:nrow(d),1:ncol(d)]
        }
        pal = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(200)
        if(input$redGreen) {
            pal = colorRampPalette(c("green", "black", "red"))(200)
        }
        pheatmap(d, color=pal)
    })


    output$downloadData <- downloadHandler(
        filename = 'heatmap.csv',
        content = function(file) {
            write.table(heatmapData(), file, quote = F, sep = '\t')
        }
    )
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = config$sample_heatmap)
    })
}
