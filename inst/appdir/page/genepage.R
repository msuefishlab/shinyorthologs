genepageUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Gene data"),
        p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        textInput(ns("ortholog"), "Ortholog"),
        DT::dataTableOutput(ns("species"))
    )
}
genepageServer = function(input, output, session) {

    output$species = DT::renderDataTable({
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT ortholog_id, species_id, gene_id FROM orthologs WHERE ortholog_id='%s'", input$ortholog)
        RPostgreSQL::dbGetQuery(con, query)
    })
}
