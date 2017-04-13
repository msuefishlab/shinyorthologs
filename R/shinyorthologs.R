init = function(pool) {
    fastaIndexes = list()
    conn <- pool::poolCheckout(pool)
    query = DBI::dbSendQuery(conn, 'SELECT transcriptome_fasta from species')
    ret = DBI::dbFetch(query)
    fastas = ret$transcriptome_fasta[!is.na(ret$transcriptome_fasta)]
    fastaIndexes <<-
        lapply(fastas, function(file) {
            print(file)
            fa = open(Rsamtools::FaFile(file))
            Rsamtools::scanFaIndex(fa)
        })
    names(fastaIndexes) <<- fastas

    expressionFiles = list()
    query = DBI::dbSendQuery(conn, 'SELECT expression_file from species')
    ret = DBI::dbFetch(query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        print(expr)
        data.table::fread(expr)
    })
    names(expressionFiles) <<- files
    pool::poolReturn(conn)
}
#' Launch the shinyorthologs app
#'
#' Executing this function will launch the shinyorthologs application in
#' the user's default web browser.
#' @examples
#' \dontrun{
#' shinyorthologs(dbname = 'shinyorthologs')
#' }
#' @export
#' @param host Database host
#' @param port Database port
#' @param dbname Database name. Default: shinyorthologs
#' @param user Database user
#' @param password Database password
#' @param dev Boolean if using dev environment, loads from local directories
#' @param config Path to a json file containing some basic config items
shinyorthologs = function(user = NULL,
                          host = NULL,
                          port = NULL,
                          password = NULL,
                          dbname = 'shinyorthologs',
                          dev = F,
                          config = 'config.json') {
    dbargs = c(
        RPostgreSQL::PostgreSQL(),
        list(dbname = dbname)[!is.null(dbname)],
        list(host = host)[!is.null(host)],
        list(user = user)[!is.null(user)],
        list(password = password)[!is.null(password)],
        list(port = port)[!is.null(port)]
    )
    pool = do.call(pool::dbPool, dbargs)


    init(pool)
    config <- jsonlite::fromJSON(file = config)

    assign("pool", pool, envir = .GlobalEnv)
    assign("config", config, envir = .GlobalEnv)
    on.exit(rm(pool, envir = .GlobalEnv))
    on.exit(rm(config, envir = .GlobalEnv))

    if (!dev) {
        shiny::runApp(base::system.file("appdir", package = "shinyorthologs"))
    } else {
        shiny::runApp('inst/appdir')
    }
}
