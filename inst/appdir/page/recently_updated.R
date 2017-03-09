updatesUI = function(id) {
    ns = NS(id)
    tagList(
        h2("Removed relationships"),
        DT::dataTableOutput(ns("table_edited")),
        downloadButton(ns('downloadEdited'), 'Download'),
        
        h2("Edited relationships"),
        DT::dataTableOutput(ns("table_removed")),
        downloadButton(ns('downloadRemoved'), 'Download')
    )
}
updatesServer = function(input, output, session) {
    
    editedTable = reactive({
        conn = poolCheckout(pool)
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description, o.removed, o.edited, o.lastUpdated from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id where o.edited = true"
        )
        ret = dbFetch(rs)
        poolReturn(conn)
        ret
    })
    removedTable = reactive({
        conn = poolCheckout(pool)
        rs = dbSendQuery(
            conn,
            "SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description, o.removed, o.edited, o.lastUpdated from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id where o.removed = true"
        )
        ret = dbFetch(rs)
        poolReturn(conn)
        ret
    })

    output$table_edited = DT::renderDataTable(removedTable(), selection = 'single')
    output$table_removed = DT::renderDataTable(editedTable(), selection = 'single')

    output$downloadEdited = downloadHandler(
        'updates.csv',
        content = function(file) {
            tab = updatesTable()
            write.csv(tab[input$table_edited_rows_all, , drop = FALSE], file)
        }
    )
    output$downloadRemoved = downloadHandler(
        'deleted.csv',
        content = function(file) {
            tab = removedTable()
            write.csv(tab[input$table_removed_rows_all, , drop = FALSE], file)
        }
    )
}
