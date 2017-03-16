ui = function(request) {
    source('page/search.R', local = T)
    source('page/comparisons.R', local = T)
    source('page/msa.R', local = T)
    source('page/genepage.R', local = T)
    source('page/help.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)
    source('page/recently_updated.R', local = T)
    fluidPage(
        includeCSS("styles.css"),
        headerPanel('ShinyOrthologs'),
        wellPanel(style = "background-color: #ffffff;", 
            tabsetPanel(id = 'inTabset',
                tabPanel(style = "margin: 20px;", id = 'search', 'Home', searchUI('search')),
                tabPanel(style = "margin: 20px;", id = 'comparisons', 'Heatmap', comparisonsUI('comparisons')),
                tabPanel(style = "margin: 20px;", id = 'species', 'Species table', speciesUI('species')),
                tabPanel(style = "margin: 20px;", id = 'msa', 'MSA', msaUI('msa')),
                tabPanel(style = "margin: 20px;", id = 'genepage', 'Gene page', genepageUI('genepage')),
                tabPanel(style = "margin: 20px;", id = 'edit', 'Edit', editUI('edits')),
                tabPanel(style = "margin: 20px;", id = 'updated', 'Recent updates', updatesUI('updates')),
                tabPanel(style = "margin: 20px;", id = 'help', 'Help', helpUI('help'))
            )
        )
    )
}

server = function(input, output, session) {
    source('page/search.R', local = T)
    source('page/comparisons.R', local = T)
    source('page/help.R', local = T)
    source('page/msa.R', local = T)
    source('page/genepage.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)
    source('page/recently_updated.R', local = T)
    setBookmarkExclude(
        c(
            "search-table_rows_current",
            "search-table_cell_clicked",
            "search-table_search",
            "search-table_rows_all",
            "search-table_state",
            "species-table_rows_current",
            "species-table_cell_clicked",
            "species-table_species",
            "species-table_rows_selected",
            "species-table_rows_all",
            "species-table_state",
            "species-table_row_last_clicked",
            "updates-table_rows_current",
            "updates-table_cell_clicked",
            "updates-table_species",
            "updates-table_rows_selected",
            "updates-table_rows_all",
            "updates-table_state",
            "updates-table_row_last_clicked",
            "edits-table_rows_current",
            "edits-table_cell_clicked",
            "edits-table_species",
            "edits-table_rows_all",
            "edits-table_state",
            "edits-table_row_last_clicked",
            "table_edited_rows_current",
            "table_edited_cell_clicked",
            "table_edited_search",
            "table_edited_rows_selected",
            "table_edited_rows_all",
            "table_edited_state",
            "table_edited_row_last_clicked",
            "table_removed_rows_current",
            "table_removed_cell_clicked",
            "table_removed_search",
            "table_removed_rows_selected",
            "table_removed_rows_all",
            "table_removed_state",
            "table_removed_row_last_clicked",
            "genepage-fasta"
        )
    )

    
    box = callModule(searchServer, 'search')
    callModule(comparisonsServer, 'comparisons')
    callModule(genepageServer, 'genepage', box)
    callModule(msaServer, 'msa', box)
    callModule(speciesServer, 'species')
    deps = callModule(editServer, 'edits')
    callModule(updatesServer, 'updates', deps)
    
    observeEvent(input$inTabset, {
        session$doBookmark()
    })
    onBookmarked(function(url) {
        updateQueryString(url)
    })
}


shinyApp(ui, server, enableBookmarking = "url")
