library(DBI)
library(pool)
library(shiny)

init = function(pool, basedir) {
    fastaIndexes = list()
    conn <- poolCheckout(pool)
    query = dbSendQuery(conn, 'SELECT transcriptome_fasta from species')
    ret = dbFetch(query)
    fastaIndexes <<-
        lapply(ret$transcriptome_fasta, function(fasta) {
            file = file.path(basedir, fasta)
            print(file)
            fa = open(Rsamtools::FaFile(file))
            Rsamtools::scanFaIndex(fa)
        })
    names(fastaIndexes) <<- ret$transcriptome_fasta

    expressionFiles = list()
    query = dbSendQuery(conn, 'SELECT expression_file from species')
    ret = dbFetch(query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        utils::read.csv(file.path(basedir, expr))
    })
    names(expressionFiles) <<- files
    poolReturn(conn)
}
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
#' @param dbname Database name. Default: shinyorthologs
#' @param user Database user
#' @param password Database password
#' @param basedir Root directory for fasta/expression files
#' @param dev Boolean if using dev environment, loads from local directories
shinyorthologs = function(user = NULL,
                          host = NULL,
                          port = NULL,
                          password = NULL,
                          dbname = 'shinyorthologs',
                          basedir = NULL,
                          dev = F) {
    dbargs = c(
        RPostgreSQL::PostgreSQL(),
        list(dbname = dbname)[!is.null(dbname)],
        list(host = host)[!is.null(host)],
        list(user = user)[!is.null(user)],
        list(password = password)[!is.null(password)],
        list(port = port)[!is.null(port)]
    )
    pool = do.call(dbPool, dbargs)

    init(pool, basedir)
    assign("pool", pool, envir = .GlobalEnv)
    assign("basedir", basedir, envir = .GlobalEnv)
    on.exit(rm(pool, envir = .GlobalEnv))
    on.exit(rm(basedir, envir = .GlobalEnv))
    if (!dev) {
        runApp(base::system.file("appdir", package = "shinyorthologs"))
    } else {
        runApp('inst/appdir')
    }
}
