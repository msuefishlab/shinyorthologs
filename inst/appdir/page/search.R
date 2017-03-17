searchUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('searchbox'), 'Search'),
        checkboxInput(ns('exact'), 'Exact', TRUE),
        fluidRow(
            p('Example'),
            actionButton(ns('example1'), 'sodium'),
            actionButton(ns('example2'), 'scn4aa')
        ),       
        fluidRow(
            DT::dataTableOutput(ns('results')),
            style = 'margin: 20px'
        ),
        fluidRow(
            uiOutput(ns('res'))
        )
    )
}
searchServer = function(input, output, session) {
    searchTable = reactive({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return()
        }
        session$doBookmark()
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        # aggregate database gene id
        query = 'SELECT o.ortholog_id, o.evidence, od.symbol, od.description, db.database, db.database_gene_id FROM orthologs o JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id JOIN dbxrefs db on o.gene_id = db.gene_id WHERE (to_tsvector(od.description) || to_tsvector(o.ortholog_id) || to_tsvector(od.symbol) || to_tsvector(o.gene_id) || to_tsvector(db.database_gene_id)) @@ to_tsquery(?search)'
        match = ifelse(input$exact, input$searchbox, paste0(input$searchbox, ':*'))
        q = sqlInterpolate(conn, query, search = match)
        rs = dbSendQuery(conn, q)
        dbFetch(rs)
    })
    
    output$results = DT::renderDataTable({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return()
        }
        dat = searchTable()
        dat$ortholog_id <- createLink(dat$ortholog_id)
        dat$database_gene_id <- createZfinLink(dat$database_gene_id)
        dat
    }, selection = 'single', escape = F)


    output$res = renderUI({
        if(is.null(input$results_rows_selected)) {
            return()
        }
        s = searchTable()
        row = s[input$results_rows_selected, ]
        conn = poolCheckout(pool)
        on.exit(poolReturn(conn))

        # aggregate database gene id
        query = 'SELECT o.ortholog_id, g.gene_id, db.database_gene_id FROM orthologs o JOIN genes g on o.gene_id = g.gene_id LEFT JOIN dbxrefs db on o.gene_id = db.gene_id WHERE o.ortholog_id = ?ortho'
        q = sqlInterpolate(conn, query, ortho = as.character(row[1]))
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)
        print(ret)

        fluidRow(
            div(class = 'ortho-container',
                apply(ret, 1, function(r) {
                    div(
                        h3(r[2]),
                        div(class = 'section',
                            div('DBXref', class='label'),
                            div(r[3], class='orthovalue')
                        )
                    )
                })
            )
        )
    })

    observeEvent(input$example1, {
        updateTextInput(session, 'searchbox', value = 'sodium')
    })
    observeEvent(input$example2, {
        updateTextInput(session, 'searchbox', value = 'scn4aa')
    })
    observeEvent(input$searchbox, {
        session$doBookmark()
    })

    createZfinLink = function(val) {
        ifelse(!is.na(stringr::str_match(val, 'ZDB')),
            sprintf("<a href='http://zfin.org/%s'>%s</a>", val, val),
            val
        )
    }
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
