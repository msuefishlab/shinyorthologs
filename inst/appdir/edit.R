library(Rsamtools)

editUI = function(id) {
    ns = NS(id)
    tagList(
        fluidRow(
            column(4, textInput(ns("gene"), "Gene: "))
        ),
        fluidRow(
            h2("Gene information"),
            DT::dataTableOutput(ns("row"))
        ),
        actionButton("submit", "Submit")
    )
}

editServer = function(input, output, session) {

    observeEvent(input$submit, {
        if (input$id != "0") {
            UpdateData(formData())
        } else {
            CreateData(formData())
            UpdateInputs(CreateDefaultRecord(), session)
        }
    }, priority = 1)

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
