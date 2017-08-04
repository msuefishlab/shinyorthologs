listUI = function(id) {
    ns = NS(id)
    tagList(
        textAreaInput(ns('genes'), 'Enter a list of genes and lookup connected ortholog IDs', height = '200px', width = '600px'),
        DT::dataTableOutput(ns('table'))
    )
}
listServer = function(input, output, session, box) {
    dataTable = reactive({
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


        query = sprintf('SELECT o.gene_id, o.ortholog_id FROM orthologs o WHERE o.gene_id IN %s', mylist)
        rs = DBI::dbSendQuery(conn, query)
        DBI::dbFetch(rs)
    })

    output$table = DT::renderDataTable({
        dataTable()
    }, selection = 'single')

}
