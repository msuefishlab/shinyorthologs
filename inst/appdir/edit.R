editUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::fluidRow(
            shiny::column(4, shiny::textInput(ns("gene"), "Gene: "))
        ),
        shiny::fluidRow(
            shiny::h2("Gene information"),
            DT::dataTableOutput(ns("row"))
        ),
        shiny::actionButton("submit", "Submit")
    )
}

editServer = function(input, output, session) {

    shiny::observeEvent(input$submit, {
        print('edit')
    }, priority = 1)

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
