       
comparisonsUI <- function(id) {
    ns <- shiny::NS(id)
    shiny::tagList(
        shiny::fluidRow(
            shiny::textAreaInput(ns("genes"), "Enter a list of orthoIDs", rows = 10, width = "600px")
        ),
        shiny::actionButton(ns('example'), 'Example'),
        shiny::h2('Heatmaps'),
        shiny::p('Note: the species where it does not have an ortholog identified are given a value of 0, which may bias the heatmap. Therefore, use complete ortholog groups'),
        shiny::plotOutput(ns('heatmap'), height = "900px")
    )
}
