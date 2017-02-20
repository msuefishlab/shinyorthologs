searchUI = function(id) {
    ns = shiny::NS(id)
    shiny::tagList(
        shiny::h1("Gene/Ortholog listing"),
        shiny::p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        shiny::fluidRow(
            shiny::column(4, shiny::textInput(ns("gene"), "Gene: "))
        ),

        shiny::fluidRow(
            shiny::h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        shiny::p('Download as CSV'),
        shiny::downloadButton(ns('downloadData'), 'Download'),
        shiny::p('Get heatmap'),
        shiny::actionButton(ns('getHeatmap'), 'Submit')
    )
}

searchServer = function(input, output, session) {


    searchTable = shiny::reactive({
        con = do.call(RPostgreSQL::dbConnect, args)
        on.exit(RPostgreSQL::dbDisconnect(con))

        s1 = ''

        # match ortholog or gene
        if (trim(input$gene) != "") {
            s1 = sprintf("where g.symbol LIKE '%s%%' or o.ortholog_id LIKE '%s%%' or d.description LIKE '%s%%'", input$gene, input$gene, input$gene)
        }
        query = sprintf("SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id %s", s1)

        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(searchTable(), options = list(bFilter = 0))
    output$downloadData <- shiny::downloadHandler(
        filename = 'search.csv',
        content = function(file) {
            write.csv(searchTable(), file)
        }
    )
    shiny::observeEvent(input$getHeatmap, {
        print('wtf')
        shiny::updateTabsetPanel(session, "inTabset", selected = "Comparisons")
    })

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
