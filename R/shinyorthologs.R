library('shiny')

init = function(dbargs, basedir) {
    fastaIndexes = list()
    con = do.call(RPostgreSQL::dbConnect, dbargs)
    query = sprintf('SELECT transcriptome_fasta from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    fastaIndexes <<- lapply(ret$transcriptome_fasta, function(fasta) {
        file = file.path(basedir, fasta)
        print(file)
        fa = open(Rsamtools::FaFile(file))
        Rsamtools::scanFaIndex(fa)
    })
    names(fastaIndexes) <<- ret$transcriptome_fasta

    expressionFiles = list()
    query = sprintf('SELECT expression_file from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        utils::read.csv(file.path(basedir, expr))
    })
    names(expressionFiles) <<- files
    RPostgreSQL::dbDisconnect(con)
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
#' @param dbname Database name
#' @param user Database user
#' @param password Database password
#' @param basedir Root directory for fasta/expression files
#' @param dev Boolean if using dev environment, loads from local directories
shinyorthologs = function(user = NULL, host = NULL, port = NULL, password = NULL, dbname = 'shinyorthologs', basedir = NULL, dev = F) {
    dbargs = c(
        RPostgreSQL::PostgreSQL(),
        list(dbname = dbname)[!is.null(dbname)],
        list(host = host)[!is.null(host)],
        list(user = user)[!is.null(user)],
        list(password = password)[!is.null(password)],
        list(port = port)[!is.null(port)]
    )
    init(dbargs, basedir)
    assign("dbargs", dbargs, envir = .GlobalEnv)
    assign("basedir", basedir, envir = .GlobalEnv)
    on.exit(rm(dbargs, envir = .GlobalEnv))
    on.exit(rm(basedir, envir = .GlobalEnv))
    if (!dev) {
        shiny::runApp(base::system.file("appdir", package = "shinyorthologs"))
    } else {
        shiny::runApp('inst/appdir')
    }
}
