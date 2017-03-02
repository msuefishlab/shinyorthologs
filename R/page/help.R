helpUI = function(id) {
    tagList(
        fluidRow(
            h2("Help"),
            p("This app offers several modes of operation"),
            p("1. Search orthologs, get associated genes"),
            p("2. Search ortholog list, get associated expression values as heatmap"),
            p("3. Search keywords")
        )
    )
}


helpServer = function(input, output, session) {

    observeEvent(input$submit, {
        print('help')
    })
}
