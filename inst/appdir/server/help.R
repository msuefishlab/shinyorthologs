

helpServer = function(input, output, session) {

    shiny::observeEvent(input$submit, {
        print('help')
    })

    source('common.R', local = TRUE)
}
