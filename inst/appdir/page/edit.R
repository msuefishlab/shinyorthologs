editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            p("Select rows to edit or remove gene->ortholog relationships"),
            DT::dataTableOutput(ns("table"))
        ),
        fluidRow(
            textInput(ns("name"), "Gene ID"),
            textInput(ns("symbol"), "Symbol"),
            textInput(ns("evidence"), "Evidence"),
            actionButton(ns("submit"), "Submit edits"),
            actionButton(ns("deleterow"), "Delete")
        )
    )
}


editServer = function(input, output, session) {

    # not using reactive because reactive depends on button clicks and thus creates circular dependency https://groups.google.com/forum/#!topic/shiny-discuss/sG4Faxufg3Q
    output$table = DT::renderDataTable({
        input$deleterow
        input$submit
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false"
        )
        dbFetch(rs)
    }, selection = 'single')
    
    observeEvent(input$table_rows_selected, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false"
        )
        data = dbFetch(rs)
        ret = data[input$table_rows_selected, ]
        updateTextInput(session, "name", value = as.character(ret[1]))
        updateTextInput(session, "symbol", value = as.character(ret[2]))
        updateTextInput(session, "evidence", value = as.character(ret[4]))
    })
    observeEvent(input$deleterow, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false"
        )
        data = dbFetch(rs)
        ret = data[input$table_rows_selected, ]
        name = as.character(ret[1])
        updateTextInput(session, "name", value = '')
        updateTextInput(session, "symbol", value = '')
        updateTextInput(session, "evidence", value = '')
        query = "UPDATE orthologs SET removed=true WHERE gene_id=?name"
        q = sqlInterpolate(conn, query, name = name)
        rs = dbExecute(conn, q)
        
        updateTextInput(session, "name", value = '')
        updateTextInput(session, "symbol", value = '')
        updateTextInput(session, "evidence", value = '')
    }, priority = 1) #update data first
    observeEvent(input$submit, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false"
        )
        data = dbFetch(rs)
        ret = data[input$table_rows_selected, ]
        
        name = input$name
        symbol = input$symbol
        evidence = input$evidence
        
        query = "UPDATE orthologs SET evidence=?evidence, edited=true WHERE gene_id=?name"
        q = sqlInterpolate(conn, query, evidence = evidence, name = name)
        rs = dbExecute(conn, q)
    }, priority = 1) #update data first
    
    vals = reactiveValues(submit = 0)
    
    return (input)
}
