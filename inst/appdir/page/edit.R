editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2("Data table"),
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
    dataTable = reactive({
        input$deleterow
        input$submit
        
        conn = poolCheckout(pool)
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false"
        )
        res = dbFetch(rs)
        poolReturn(conn)
        res
    })
    output$table = DT::renderDataTable({
        dataTable()
    }, selection = 'single')
    
    observeEvent(input$table_rows_selected, {
        data = dataTable()
        ret = data[input$table_rows_selected, ]
        updateTextInput(session, "name", value = as.character(ret[1]))
        updateTextInput(session, "symbol", value = as.character(ret[2]))
        updateTextInput(session, "evidence", value = as.character(ret[4]))
    })
    observeEvent(input$deleterow, {
        data = dataTable()
        ret = data[input$table_rows_selected, ]
        name = as.character(ret[1])
        updateTextInput(session, "name", value = '')
        updateTextInput(session, "symbol", value = '')
        updateTextInput(session, "evidence", value = '')
        conn = poolCheckout(pool)
        query = "UPDATE orthologs SET removed=true WHERE gene_id=?name"
        q = sqlInterpolate(conn, query, name = name)
        rs = dbExecute(conn, q)
        poolReturn(conn)
    })
    observeEvent(input$submit, {
        data = dataTable()
        ret = data[input$table_rows_selected, ]
        
        name = input$name
        symbol = input$symbol
        evidence = input$evidence
        
        conn = poolCheckout(pool)
        query = "UPDATE orthologs SET evidence=?evidence, edited=true WHERE gene_id=?name"
        q = sqlInterpolate(conn, query, evidence = evidence, name = name)
        rs = dbExecute(conn, q)
        poolReturn(conn)
    })
    
    vals = reactiveValues(submit = 0)
}
