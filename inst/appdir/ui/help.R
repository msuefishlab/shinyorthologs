helpUI = function(id) {
    shiny::tagList(
        shiny::fluidRow(
            shiny::h2("Help"),
            shiny::p("This app offers several modes of operation"),
            shiny::p("1. Search orthologs, get associated genes"),
            shiny::p("2. Search ortholog list, get associated expression values as heatmap"),
            shiny::p("3. Search keywords")
        )
    )
}
