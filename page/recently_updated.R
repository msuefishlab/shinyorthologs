updatesUI = function(id) {
    ns = NS(id)
    tagList(
        h2('Removed relationships'),
        DT::dataTableOutput(ns('table_edited')),
        downloadButton(ns('downloadEdited'), 'Download'),
        
        h2('Edited relationships'),
        DT::dataTableOutput(ns('table_removed')),
        downloadButton(ns('downloadRemoved'), 'Download')
    )
}
updatesServer = function(input, output, session, args) {
    setBookmarkExclude(
      c(
        'table_edited_rows_current',
        'table_edited_cell_clicked',
        'table_edited_search',
        'table_edited_rows_selected',
        'table_edited_rows_all',
        'table_edited_state',
        'table_edited_row_last_clicked',
        'table_removed_rows_current',
        'table_removed_cell_clicked',
        'table_removed_search',
        'table_removed_rows_selected',
        'table_removed_rows_all',
        'table_removed_state',
        'table_removed_row_last_clicked'
      )
    )
    editedTable = reactive({
        args$submit
        
        
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))
        rs = DBI::dbSendQuery(
            conn,
            'SELECT g.gene_id, s.species_name, o.ortholog_id, d.symbol, d.description, o.removed, o.edited, o.lastUpdated from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id where o.edited = true'
        )
        DBI::dbFetch(rs)
    })
    removedTable = reactive({
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))
        rs = DBI::dbSendQuery(
            conn,
            'SELECT g.gene_id, s.species_name, o.ortholog_id, d.symbol, d.description, o.removed, o.edited, o.lastUpdated from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id where o.removed = true'
        )
        DBI::dbFetch(rs)
    })

    output$table_edited = DT::renderDataTable({
        removedTable()
    }, selection = 'single')
    output$table_removed = DT::renderDataTable({
        editedTable()
    }, selection = 'single')

    output$downloadEdited = downloadHandler(
        'updates.csv',
        content = function(file) {
            tab = updatesTable()
            write.csv(tab[input$table_edited_rows_all, , drop = FALSE], file, row.names = F, quote = F)
        }
    )
    output$downloadRemoved = downloadHandler(
        'deleted.csv',
        content = function(file) {
            tab = removedTable()
            write.csv(tab[input$table_removed_rows_all, , drop = FALSE], file, row.names = F, quote = F)
        }
    )
}
