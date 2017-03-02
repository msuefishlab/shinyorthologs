searchUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Gene data"),
        p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        fluidRow(
            column(4, textInput(ns("gene"), "Search: "))
        ),

        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download')
    )
}
searchServer = function(input, output, session) {
    searchTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, args)
        on.exit(RPostgreSQL::dbDisconnect(con))

        s1 = ''

        # match ortholog or gene
        if (input$gene != "") {
            s1 = sprintf("where g.gene_id LIKE '%s%%' or g.symbol LIKE '%s%%' or o.ortholog_id LIKE '%s%%' or d.description LIKE '%s%%'", input$gene, input$gene, input$gene, input$gene)
        }
        query = sprintf("SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id %s", s1)

        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(searchTable(), options = list(bFilter = 0), selection = 'single')
    output$downloadData <- downloadHandler(
        filename = 'search.csv',
        content = function(file) {
            write.csv(searchTable(), file)
        }
    )
}
