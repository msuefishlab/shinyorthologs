library(jsonlite)
library(shinyjs)
library(logging)
library(shiny)
library(pool)
library(DBI)
library(RPostgreSQL)
library(magrittr)


options(shiny.error = function() { 
        logging::logerror(sys.calls() %>% as.character %>% paste(collapse = ", ")) })

config <<- fromJSON('config.json')
dbname = config$dbname
user = config$user
password = config$password
port = config$port
host = config$host

dbargs = c(
    PostgreSQL(),
    list(dbname = dbname)[!is.null(dbname)],
    list(host = host)[!is.null(host)],
    list(user = user)[!is.null(user)],
    list(password = password)[!is.null(password)],
    list(port = port)[!is.null(port)]
)
pool = do.call(dbPool, dbargs)


shinyServer(function(input, output, session) {
    printLogJs <- function(x, ...) {
        logjs(x)
        return(TRUE)
    }

    addHandler(printLogJs)
    source('page/search.R', local = T)
    source('page/heatmap.R', local = T)
    source('page/list.R', local = T)
    source('page/help.R', local = T)
    source('page/genepage.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)
    source('page/recently_updated.R', local = T)
    setBookmarkExclude(
        c(
            'search-example1',
            'search-example2',
            'search-clearList',
            'search-sendToHeatmap',
            'species-table_rows_current',
            'species-table_cell_clicked',
            'species-table_species',
            'species-table_rows_selected',
            'species-table_rows_all',
            'species-table_state',
            'species-table_row_last_clicked',
            'updates-table_rows_current',
            'updates-table_cell_clicked',
            'updates-table_species',
            'updates-table_rows_selected',
            'updates-table_rows_all',
            'updates-table_state',
            'updates-table_row_last_clicked',
            'edits-table_rows_current',
            'edits-table_cell_clicked',
            'edits-table_species',
            'edits-table_rows_all',
            'edits-table_state',
            'edits-table_row_last_clicked',
            'edits-deleterow',
            'edits-evidence',
            'edits-name',
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
            'table_removed_row_last_clicked',
            'genepage-fasta',
            'heatmap-example'
        )
    )


    box = callModule(searchServer, 'search', session)
    heatmap = callModule(heatmapServer, 'heatmap')
    callModule(listServer, 'list', session, heatmap)
    callModule(genepageServer, 'genepage', box)
    callModule(speciesServer, 'species')
    deps = callModule(editServer, 'edits')
    callModule(updatesServer, 'updates', deps)

    observeEvent(input$inTabset, {
        session$doBookmark()
    })
    onBookmarked(function(url) {
        updateQueryString(url)
    })
})

enableBookmarking("url")
