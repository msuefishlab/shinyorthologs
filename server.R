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
