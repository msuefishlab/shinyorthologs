speciesUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::h1("Species listing"),
        shiny::p("Search for species"),
        shiny::fluidRow(
            shiny::column(4, shiny::textInput(ns("species"), "Species: "))
        ),

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

        s1 = ''
        if (trim(input$species) != "") {
            s1 = sprintf("where common_name LIKE '%s%%' or species_name LIKE '%s%%' or taxonomy_id LIKE '%s%%'", input$species, input$species, input$species)
        }
        query = sprintf("SELECT * from species %s", s1)

        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(speciesTable(), options = list(bFilter = 0))
    output$downloadData <- shiny::downloadHandler(
        filename = 'species.csv',
        content = function(file) {
            write.csv(speciesTable(), file)
        }
    )

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
