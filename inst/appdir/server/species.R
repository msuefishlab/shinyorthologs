

speciesServer = function(input, output, session) {
    speciesTable = shiny::reactive({
        con = do.call(RPostgreSQL::dbConnect, args)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT * from species")
        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(speciesTable())
    output$downloadData <- shiny::downloadHandler(
        filename = 'species.csv',
        content = function(file) {
            write.csv(speciesTable(), file)
        }
    )

    source('common.R', local = TRUE)
}
