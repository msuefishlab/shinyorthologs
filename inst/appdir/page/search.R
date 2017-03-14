searchUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('searchbox'), 'Search'),
        fluidRow(
            p("Example"),
            actionButton(ns('example1'), 'sodium'),
            actionButton(ns('example2'), 'scn4aa')
        ),       
        fluidRow(
            DT::dataTableOutput(ns('results'))
        )
    )
}
searchServer = function(input, output, session) {
    searchTable = reactive({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return()
        }
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))
        query = "SELECT o.ortholog_id, o.evidence, od.symbol, od.description, db.database, db.database_gene_id FROM orthologs o JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id JOIN dbxrefs db on o.gene_id = db.gene_id WHERE to_tsvector(od.description) || to_tsvector(o.ortholog_id) || ' ' || to_tsvector(od.symbol) || ' ' || to_tsvector(o.gene_id) || ' ' || to_tsvector(db.database_gene_id) @@ plainto_tsquery(?search)"
        q = sqlInterpolate(conn, query, search = input$searchbox)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })
    
    output$results = DT::renderDataTable({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return()
        }
        dat = searchTable()
        dat$ortholog_id <- createLink(dat$ortholog_id)
        dat
    }, selection = 'single', escape = F)
    observeEvent(input$example1, {
        updateTextInput(session, 'searchbox', value = 'sodium')
    })
    observeEvent(input$example2, {
        updateTextInput(session, 'searchbox', value = 'scn4aa')
    })
    
    createLink <- function(val) {
        sprintf(
            "<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a> (<a href='?_inputs_&inTabset=\"MSA\"&msa-ortholog=\"%s\"'>MSA</a>)",
            val,
            val,
            val
        )
    }
    
    return(searchTable)
}
