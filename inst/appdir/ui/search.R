searchUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::h1("Gene data"),
        shiny::p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        shiny::fluidRow(
            shiny::column(4, shiny::textInput(ns("gene"), "Search: "))
        ),

        shiny::fluidRow(
            shiny::h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        shiny::p('Download as CSV'),
        shiny::downloadButton(ns('downloadData'), 'Download')
    )
}
