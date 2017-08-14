heatmapUI = function(id) {
    ns = NS(id)
    tagList(
        textAreaInput(ns('genes'), 'Enter a list of orthoIDs', height = '200px', width = '600px'),
        actionButton(ns('example'), 'Example'),
        actionButton(ns('clear'), 'Clear'),
        p('Plot log10-scaled gene expressions values across species'),
        p('Optionally normalize columns (individual samples)'),
        
        checkboxInput(ns('normalizeCols'), 'Normalize columns?'),
        checkboxInput(ns('normalizeRows'), 'Normalize rows?'),
        checkboxInput(ns('redGreen'), 'Red-black-green colors?'),
        selectInput(ns('species'), 'Species', multiple = T, choices = c(), width = '600px'),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download'),
        h2('Heatmaps'),
        plotOutput(ns('heatmap'), height = '700px', width = '1000px')
    )
}
heatmapServer = function(input, output, session) {

    heatmapData = reactive({
        if (is.null(input$genes) | input$genes == '') {
            return()
        }
        x = strsplit(input$genes, '\n')
        formatted_ids = sapply(x, function(e) {
            paste0("'", trimws(e), "'")
        })
        formatted_list = do.call(paste, c(as.list(formatted_ids), sep = ','))
        mylist = paste0('(', formatted_list, ')')
        
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))


        query = sprintf('SELECT o.ortholog_id, o.species_id, od.symbol, o.gene_id, e.value, e.tissue FROM orthologs o JOIN species s on o.species_id=s.species_id JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id JOIN expression e on e.gene_id = o.gene_id WHERE o.ortholog_id IN %s', mylist)
        rs = DBI::dbSendQuery(conn, query)
        ret = DBI::dbFetch(rs)
        
        v = unique(ret$species_id)
        updateSelectInput(session, "species", choices=v, selected=v)
        ret
    })

    matrixData = reactive({
        ret = heatmapData()
        if (is.null(input$genes) | input$genes == '') {
            return()
        }
        if (is.null(input$species)) {
            return()
        }
        ret = subset(ret, species_id %in% input$species)

        h = reshape2::acast(ret, ortholog_id + symbol ~ species_id + tissue)
        h[is.na(h)] = 0

        h
    })


    output$heatmap = renderPlot({
        h = matrixData()
        if(is.null(h)) {
            return()
        }
        d = log(h + 1)
        if(input$normalizeCols) {
            d = scale(d)[1:nrow(d),1:ncol(d)]
        }
        if(input$normalizeRows) {
            e = t(d)
            d = t(scale(e)[1:nrow(e),1:ncol(e)])
        }
        pal = colorRampPalette(rev(RColorBrewer::brewer.pal(n = 7, name = "RdYlBu")))(200)
        if(input$redGreen) {
            pal = colorRampPalette(c("green", "black", "red"))(200)
        }
        pheatmap::pheatmap(d, color=pal)
    })


    output$downloadData <- downloadHandler(
        filename = 'heatmap.csv',
        content = function(file) {
            write.table(matrixData(), file, quote = F, sep = '\t')
        }
    )
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = config$sample_heatmap)
    })
    observeEvent(input$normalizeRows, {
        session$doBookmark()
    })
    observeEvent(input$normalizeCols, {
        session$doBookmark()
    })

    observeEvent(input$clear, {
        updateTextAreaInput(session, 'genes', value='')
    })
}
