genepageUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Gene data"),
        p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        textInput(ns("ortholog"), "Ortholog"),
        DT::dataTableOutput(ns("genes"))
    )
}
genepageServer = function(input, output, session, box) {

    output$genes = DT::renderDataTable({
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = "SELECT s.species_id, o.ortholog_id, o.evidence FROM orthologs o join species s on s.species_id = o.species_id where ortholog_id = ?orthoid"
        q = sqlInterpolate(conn, query, orthoid = input$ortholog)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })
    
}
