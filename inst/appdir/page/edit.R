editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2("Edit gene information"),
            textInput(ns("symbol"), "Symbol: "),
            textInput(ns("evidence"), "Evidence: "),
            actionButton(ns("submit"), "Submit")
        ),
        
        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("searchTable"))
        )
    )
}


editServer = function(input, output, session) {
    
    dataTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))
        
        query = sprintf("SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id")
        
        RPostgreSQL::dbGetQuery(con, query)
    })
    
    output$searchTable = DT::renderDataTable({
        dataTable()
    })
    
    
    observeEvent(input$searchTable_rows_selected, {
        data = dataTable()
        ret = data[input$searchTable_rows_selected, ]
        updateTextInput(session, "name", value = as.character(ret[1]))
        updateTextInput(session, "symbol", value = as.character(ret[2]))
        updateTextInput(session, "ortholog", value = as.character(ret[3]))
        updateTextInput(session, "evidence", value = as.character(ret[4]))
    })
    
    values = reactiveValues(x = "someValue")
    
    observeEvent(input$submit, {
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))
        data = dataTable()
        ret = data[input$searchTable_rows_selected, ]
        name = as.character(ret[1])
        
        query = sprintf("UPDATE genes SET symbol='%s' WHERE gene_id='%s'", input$symbol, name)
        ret = RPostgreSQL::dbGetQuery(con, query)
        query = sprintf("UPDATE orthologs SET evidence='%s' WHERE gene_id='%s'", input$evidence, name)
        ret = RPostgreSQL::dbGetQuery(con, query)
        values$x = paste(name, input$evidence, input$symbol)
    })
}
