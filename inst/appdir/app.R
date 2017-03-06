ui = function(request) {
    source('page/search.R', local = T)
    source('page/ortholog.R', local = T)
    source('page/comparisons.R', local = T)
    source('page/msa.R', local = T)
    source('page/genepage.R', local = T)
    source('page/help.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)
    fluidPage(
        titlePanel('shinyorthologs3'),
        tabsetPanel(id = 'inTabset',
            tabPanel(id = 'comparisons', 'Multi-ortholog heatmap', comparisonsUI('comparisons')),
            tabPanel(id = 'search', 'Gene search', searchUI('search')),
            tabPanel(id = 'orthologs', 'Ortholog search', orthologUI('orthologs')),
            tabPanel(id = 'species', 'Species table', speciesUI('species')),
            tabPanel(id = 'msa', 'MSA', msaUI('msa')),
            tabPanel(id = 'genepage', 'Gene page', genepageUI('genepage')),
            tabPanel(id = 'edit', 'Edit', editUI('edit')),
            tabPanel(id = 'help', 'Help', helpUI('help'))
        )
    )
}

server = function(input, output, session) {
    source('page/search.R', local = T)
    source('page/ortholog.R', local = T)
    source('page/comparisons.R', local = T)
    source('page/help.R', local = T)
    source('page/msa.R', local = T)
    source('page/genepage.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)

    setBookmarkExclude(c("search-table_rows_current", "search-table_cell_clicked", "search-table_search", "search-table_rows_selected", "search-table_rows_all", "search-table_state", "search-table_row_last_clicked",
                         "orthologs-table_rows_current", "orthologs-table_cell_clicked", "orthologs-table_orthologs", "orthologs-table_rows_selected", "orthologs-table_rows_all", "orthologs-table_state", "orthologs-table_row_last_clicked",
                         "species-table_rows_current", "species-table_cell_clicked", "species-table_species", "species-table_rows_selected", "species-table_rows_all", "species-table_state", "species-table_row_last_clicked"))

    callModule(searchServer, 'search')
    callModule(comparisonsServer, 'comparisons')
    callModule(orthologServer, 'orthologs')
    callModule(genepageServer, 'genepage')
    callModule(msaServer, 'msa')
    callModule(speciesServer, 'species')
    callModule(editServer, 'edit')


    observeEvent(input$inTabset, {
        session$doBookmark()
    })
    onBookmarked(function(url) {
        updateQueryString(url)
    })
}


shinyApp(ui, server, enableBookmarking = "url")
