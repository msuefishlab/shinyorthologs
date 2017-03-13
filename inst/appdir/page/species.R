speciesUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Species listing"),
        fluidRow(h2("Data table"),
                 DT::dataTableOutput(ns("table"))),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download')
    )
}


speciesServer = function(input, output, session) {
    speciesTable = reactive({
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        rs = dbSendQuery(conn, "SELECT * FROM species")
        dbFetch(rs)
    })
    output$table = DT::renderDataTable(speciesTable())
    output$downloadData <- downloadHandler(
        filename = 'species.csv',
        content = function(file) {
            write.csv(speciesTable(), file)
        }
    )
}
