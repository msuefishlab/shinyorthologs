listUI = function(id) {
    ns = NS(id)
    tagList(
        textAreaInput(ns('genes'), 'Enter a list of genes and lookup connected ortholog IDs', height = '200px', width = '600px'),
        actionButton(ns('example'), 'Example'),
        actionButton(ns('clear'), 'Clear'),
        DT::dataTableOutput(ns('table')),
        uiOutput(ns('sendToHeatmap'))
    )
}
listServer = function(input, output, session, parent, heatmap) {
    dataTable = reactive({
        if (is.null(input$genes) | input$genes == '') {
            return()
        }
 
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        gen = strsplit(input$genes, '\n')
        gen = sapply(gen, trimws)
        gen = sapply(gen, function(elt) {
            dbQuoteString(conn, elt)
        })
        mylist = paste0('(', do.call(paste, c(as.list(gen), sep = ',')), ')')
        query = sprintf('SELECT o.gene_id, o.ortholog_id FROM orthologs o WHERE o.gene_id IN %s', mylist)
        rs = DBI::dbSendQuery(conn, query)
        DBI::dbFetch(rs)
    })

    output$table = DT::renderDataTable({
        dataTable()
    }, selection = 'single')

    observeEvent(input$genes, {
        session$doBookmark()
    })

    observeEvent(input$heatmapSend, {
        if(!is.null(dataTable())) {
            updateTextAreaInput(parent, 'heatmap-genes', value=paste0(dataTable()[,2], collapse='\n', sep=''))
            updateTabsetPanel(parent, "inTabset", selected = "heatmap")
        }
    })
    observeEvent(input$example, {
        updateTextAreaInput(session, 'genes', value = config$sample_genelist)
    })

    output$sendToHeatmap = renderUI({
        if(!is.null(dataTable())) {
            actionButton(session$ns('heatmapSend'), 'Send to heatmap')
        }
    })

    observeEvent(input$clear, {
        updateTextAreaInput(session, 'genes', value='')
    })

    setBookmarkExclude(c('clear', 'example', 'genes'))
}
