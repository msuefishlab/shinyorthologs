searchUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('searchbox'), 'Search', width = 500),
        checkboxInput(ns('exact'), 'Exact', TRUE),
        fluidRow(
            p('Example'),
            actionButton(ns('example1'), config$sample_search1),
            actionButton(ns('example2'), config$sample_search2)
        ),       
        fluidRow(
            DT::dataTableOutput(ns('table')),
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
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        # aggregate database gene id
        start.time <- Sys.time()
        query = "SELECT DISTINCT o.ortholog_id, o.evidence, od.symbol, od.description, db.database, db.database_gene_id FROM orthologs o JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id LEFT JOIN dbxrefs db on o.gene_id = db.gene_id WHERE (to_tsvector(coalesce(od.description,'') || ' ' || o.ortholog_id ||  ' ' || coalesce(od.symbol,'') || ' ' || coalesce(o.gene_id,'') || ' ' || coalesce(db.database_gene_id,''))) @@ to_tsquery(?search)"
        match = ifelse(input$exact, input$searchbox, paste0(input$searchbox, ':*'))
        q = DBI::sqlInterpolate(conn, query, search = match)
        rs = DBI::dbSendQuery(conn, q)
        res = DBI::dbFetch(rs)
        end.time <- Sys.time()
        cat(file=stderr(),end.time-start.time, "\n")
        res
    })
    
    output$table = DT::renderDataTable({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return()
        }
        dat = searchTable()
        print(dat)
        dat$ortholog_id <- createLink(dat$ortholog_id)
        dat$database_gene_id <- createZfinLink(dat$database_gene_id)
        dat
    }, selection = 'single', escape = F)


    output$res = renderUI({
        if(is.null(input$table_rows_selected)) {
            return()
        }
        s = searchTable()
        row = s[input$table_rows_selected, ]
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        # aggregate database gene id
        query = 'SELECT o.ortholog_id, g.gene_id, db.database_gene_id FROM orthologs o JOIN genes g on o.gene_id = g.gene_id LEFT JOIN dbxrefs db on o.gene_id = db.gene_id WHERE o.ortholog_id = ?ortho'
        q = DBI::sqlInterpolate(conn, query, ortho = as.character(row[1]))
        rs = DBI::dbSendQuery(conn, q)
        ret = DBI::dbFetch(rs)

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
        updateTextInput(session, 'searchbox', value = config$sample_search1)
    })
    observeEvent(input$example2, {
        updateTextInput(session, 'searchbox', value = config$sample_search2)
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
            "<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a>",
            val,
            val
        )
    }
    
    return(searchTable)
}
