speciesUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Species listing"),
        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        p('Download as CSV'),
        downloadButton(ns('downloadData'), 'Download')
    )
}


speciesServer = function(input, output, session) {
    speciesTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, args)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT * from species")
        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(speciesTable())
    output$downloadData <- downloadHandler(
        filename = 'species.csv',
        content = function(file) {
            write.csv(speciesTable(), file)
        }
    )
}
