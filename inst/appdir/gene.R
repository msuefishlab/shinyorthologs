library(Rsamtools)

geneUI = function(id) {
    ns = NS(id)
    tagList(
        h1("Gene/Ortholog listing"),
        p("Search for genes or orthologs in this table, and select them by clicking each row. The selected genes will be added to a 'workplace' that you can do further analysis with."),
        fluidRow(
            column(4, textInput(ns("gene"), "Gene: "))
        ),

        fluidRow(
            h2("Data table"),
            DT::dataTableOutput(ns("table"))
        ),
        actionButton(ns("submit"), "Submit")
    )
}

geneServer = function(input, output, session) {


    geneTable = reactive({
        con = do.call(dbConnect, args)
        on.exit(dbDisconnect(con))

        s1 = ''

        # match ortholog or gene
        if(trim(input$gene) != "") {
            s1 = sprintf("where g.symbol LIKE '%s%%' or o.ortholog_id LIKE '%s%%'", input$gene, input$gene)
        }
        query = sprintf("SELECT g.gene_id, s.species_name, o.ortholog_id, g.symbol, d.description from genes g join species s on g.species_id = s.species_id join orthologs o on g.gene_id = o.gene_id join orthodescriptions d on o.ortholog_id = d.ortholog_id %s", s1)

        dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable(geneTable(), options = list(bFilter = 0))

    observeEvent(input$submit, {
        if (!is.null(input$table_rows_selected)) {
            print(input$table_rows_selected)
            print(geneTable()[input$table_rows_selected, ])
        }
    }, priority = 1)

    source('common.R', local = TRUE)
    source('dbparams.R', local = TRUE)
}
