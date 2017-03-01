editUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::fluidRow(
            h2("Edit gene information"),
            shiny::textInput(ns("symbol"), "Symbol: "),
            shiny::textInput(ns("evidence"), "Evidence: "),
            shiny::actionButton(ns("submit"), "Submit")
        ),

        shiny::fluidRow(
            shiny::h2("Data table"),
            DT::dataTableOutput(ns("searchTable"))
        )
    )
}
