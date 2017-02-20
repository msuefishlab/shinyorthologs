speciesUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::h1("Species listing"),
        shiny::fluidRow(
            shiny::h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        shiny::p('Download as CSV'),
        shiny::downloadButton(ns('downloadData'), 'Download')
    )
}

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
    source('dbparams.R', local = TRUE)
}
