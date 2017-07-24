listUI = function(id) {
    ns = NS(id)
    tagList(
        textAreaInput(ns('genes'), 'Enter a list of genes and lookup connected ortholog IDs', height = '200px', width = '600px'),
        uiOutput(ns('results'))
    )
}
listServer = function(input, output, session) {
    output$results = renderUI({
        if (is.null(input$genes) | input$genes == '') {
            return()
        }


        tagList(
            p('test')
        )
    })
}
