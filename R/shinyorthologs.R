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
shinyorthologs <- function(){
    runShinyOrthologs()
    return(invisible())
}


runShinyOrthologs <- function(){
    filename <-  base::system.file("appdir", package = "shinyorthologs")
    shiny::runApp(filename, launch.browser = TRUE)
}
