#' Launch the shinyorthologs app
#'
#' Executing this function will launch the shinyorthologs application in
#' the user's default web browser.
#' @author Colin Diesh \email{dieshcol@msu.edu}
#' @examples
#' \dontrun{
#' shinyorthologs()
#' }

#' @export
#' @param db_host Database host
#' @param db_port Database port
#' @param db_name Database name
#' @param db_user Database user
#' @param db_pass Database password
#' @param baseDir Root directory for fasta/expression files
shinyorthologs <- function(db_user = NULL, db_host = NULL, db_port = NULL, db_pass = NULL, db_name = NULL, baseDir = NULL){
    use_name = !is.null(db_name)
    use_port = !is.null(db_port)
    use_user = !is.null(db_user)
    use_pass = !is.null(db_pass)
    use_host = !is.null(db_host)
    args = c(
        RPostgreSQL::PostgreSQL(),
        list(dbname = db_name)[use_name],
        list(host = db_host)[use_host],
        list(user = db_user)[use_user],
        list(password = db_pass)[use_pass],
        list(port = db_port)[use_port]
    )
    runShinyOrthologs(args, baseDir)
    return(invisible())
}


runShinyOrthologs <- function(args, baseDir){
    .GlobalEnv$.args <- args
    .GlobalEnv$.baseDir <- baseDir
    on.exit(rm(.args, envir = .GlobalEnv))
    on.exit(rm(.baseDir, envir = .GlobalEnv))
    filename <-  base::system.file("appdir", package = "shinyorthologs")
    shiny::runApp(filename, launch.browser = TRUE)
}
