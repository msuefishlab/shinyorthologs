editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("editTable"))
        ),
        fluidRow(
            actionButton(ns("editrow"), "Edit ortholog relation"),
            actionButton(ns("deleterow"), "Delete ortholog relation")
        ),
        fluidRow(
            p("Edit gene information"),
            textInput(ns("symbol"), "Symbol: "),
            textInput(ns("evidence"), "Evidence: "),
            actionButton(ns("submit"), "Submit")
        )
    )
}


editServer = function(input, output, session) {
    
    dataTable = reactive({
        
        conn = poolCheckout(pool)
        rs = dbSendQuery(conn, "SELECT g.gene_id, g.symbol, o.ortholog_id, o.evidence, o.removed, o.edited from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id")
        res = dbFetch(rs)
        poolReturn(conn) 
        
        res
    })
    
    output$editTable = DT::renderDataTable({
        dataTable()
    }, selection = 'single')
    
    
    observeEvent(input$deleterow, {
        data = dataTable()
        ret = data[input$editTable_rows_selected, ]
        name = as.character(ret[1])
        
        conn = poolCheckout(pool)
        query = "UPDATE orthologs SET removed=true WHERE gene_id=?name"
        q = sqlInterpolate(conn, query, name = name)
        print(q)
        rs = dbExecute(conn, q)
        print(rs)
        
        poolReturn(conn) 
    })
    observeEvent(input$editrow, {
        data = dataTable()
        ret = data[input$editTable_rows_selected, ]
        updateTextInput(session, "name", value = as.character(ret[1]))
        updateTextInput(session, "symbol", value = as.character(ret[2]))
        updateTextInput(session, "ortholog", value = as.character(ret[3]))
        updateTextInput(session, "evidence", value = as.character(ret[4]))
    })
    
    values = reactiveValues(x = "someValue")
    
}
