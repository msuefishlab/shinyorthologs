library('shiny')

#' Launch the shinyorthologs app
#'
#' Executing this function will launch the shinyorthologs application in
#' the user's default web browser.
#' @examples
#' \dontrun{
#' shinyorthologs(basedir='/data/dir', dbname = 'shinyorthologs')
#' }
#' @export
#' @param host Database host
#' @param port Database port
#' @param dbname Database name
#' @param user Database user
#' @param password Database password
#' @param basedir Root directory for fasta/expression files
shinyorthologs <- function(user = NULL, host = NULL, port = NULL, password = NULL, dbname = NULL, basedir = NULL) {
    
    
    args = c(
        RPostgreSQL::PostgreSQL(),
        list(dbname = dbname)[!is.null(dbname)],
        list(host = host)[!is.null(host)],
        list(user = user)[!is.null(user)],
        list(password = password)[!is.null(password)],
        list(port = port)[!is.null(port)]
    )
    assign("args", args, envir = .GlobalEnv)
    
    source('R/page/search.R')
    source('R/page/ortholog.R')
    source('R/page/comparisons.R')
    source('R/page/species.R')
    source('R/page/edit.R')
    source('R/page/help.R')
    
    shinyApp(
        function(request) {
            fluidPage(
                titlePanel('shinyorthologs2'),
                tabsetPanel(id = 'inTabset',
                            tabPanel('Comparisons', comparisonsUI('comparisons')),
                            tabPanel('Genes', searchUI('search')),
                            tabPanel('Species', speciesUI('species')),
                            tabPanel('Edit', editUI('edit')),
                            tabPanel('Help', helpUI('help')
                            )
                )
            )
        }, function(input, output, session) {

            callModule(searchServer, 'search')
            callModule(comparisonsServer, 'comparisons')
            callModule(speciesServer, 'species')
            callModule(editServer, 'edit')
            
        }
    )
}


