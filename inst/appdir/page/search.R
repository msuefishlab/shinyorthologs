searchUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Gene data"),
        p(
            "Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."
        ),
        fluidRow(h2("Data table"),
                 DT::dataTableOutput(ns("table"))),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download')
    )
}
searchServer = function(input, output, session) {
    searchTable = reactive({
        conn = poolCheckout(pool)
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id"
        )
        ret = dbFetch(rs)
        poolReturn(conn)
        ret
    })
    output$table = DT::renderDataTable(searchTable(), selection = 'single')
    output$downloadData = downloadHandler(
        'genes.csv',
        content = function(file) {
            tab = searchTable()
            write.csv(tab[input$table_rows_all, , drop = FALSE], file)
        }
    )
}
