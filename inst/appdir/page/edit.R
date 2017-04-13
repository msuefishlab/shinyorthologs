inline = function (x) {
    tags$div(style="display:inline-block;", x)
}

editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            p('Select rows to edit or remove gene->ortholog relationships'),
            DT::dataTableOutput(ns('table'))
        ),
        inline(textInput(ns('name'), 'Gene ID')),
        inline(textInput(ns('ortho'), 'Ortholog ID')),
        inline(textInput(ns('symbol'), 'Symbol')),
        inline(textInput(ns('evidence'), 'Evidence')),
        actionButton(ns('submit'), 'Submit edits'),
        actionButton(ns('deleterow'), 'Delete')
    )
}


editServer = function(input, output, session) {

    # not using reactive because reactive depends on button clicks and thus creates circular dependency https://groups.google.com/forum/#!topic/shiny-discuss/sG4Faxufg3Q
    output$table = DT::renderDataTable({
        input$deleterow
        input$submit
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        rs = dbSendQuery(conn, 'SELECT g.gene_id, d.symbol, o.ortholog_id, o.evidence, s.species_id from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false')
        dbFetch(rs)
    }, selection = 'single')
    
    observeEvent(input$table_rows_selected, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))
        rs = dbSendQuery(conn, 'SELECT g.gene_id, d.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false')
        data = dbFetch(rs)
        ret = data[input$table_rows_selected, ]
        updateTextInput(session, 'name', value = ret$gene_id)
        updateTextInput(session, 'ortho', value = ret$ortholog_id)
        updateTextInput(session, 'symbol', value = ret$symbol)
        updateTextInput(session, 'evidence', value = ret$evidence)
    })
    observeEvent(input$deleterow, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))
        rs = dbSendQuery(conn, 'SELECT g.gene_id, d.symbol, o.ortholog_id, o.evidence from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id and o.removed = false')
        data = dbFetch(rs)
        ret = data[input$table_rows_selected, ]
        updateTextInput(session, 'name', value = '')
        updateTextInput(session, 'ortho', value = '')
        updateTextInput(session, 'symbol', value = '')
        updateTextInput(session, 'evidence', value = '')
        query = 'UPDATE orthologs SET removed=true WHERE gene_id=?name and ortholog_id=?ortho'
        q = sqlInterpolate(conn, query, name = ret$gene_id, ortho = ret$ortholog_id)
        rs = dbExecute(conn, q)
    }, priority = 1)


    observeEvent(input$submit, {
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        query = 'UPDATE orthologs SET evidence=?evidence, edited=true WHERE gene_id=?name and ortholog_id=?ortho'
        q = sqlInterpolate(conn, query, evidence = input$evidence, name = input$name, ortho = input$ortho)
        rs = dbExecute(conn, q)
        query2 = 'UPDATE orthodescriptions SET symbol=?symbol WHERE ortholog_id=?ortho'
        q2 = sqlInterpolate(conn, query2, symbol = input$symbol, ortho = input$ortho)
        rs = dbExecute(conn, q2)
    }, priority = 1)
    
    vals = reactiveValues(submit = 0)
    
    return (input)
}
