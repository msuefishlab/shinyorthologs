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
            uiOutput(ns('res'))
        )
    )
}
searchServer = function(input, output, session) {
    printLogJs <- function(x, ...) {
        logjs(x)
        return(TRUE)
    }

    addHandler(printLogJs)
    searchTable = reactive({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return(NULL)
        }
        session$doBookmark()
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        # aggregate database gene id
        start.time <- Sys.time()
        query = "SELECT DISTINCT o.ortholog_id, o.evidence, od.symbol, od.description, g.gene_id FROM orthologs o JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id JOIN genes g on o.gene_id = g.gene_id LEFT JOIN dbxrefs db on o.gene_id = db.gene_id  WHERE to_tsvector(coalesce(od.description,'') || ' ' || o.ortholog_id ||  ' ' || coalesce(od.symbol,'') || ' ' || coalesce(o.gene_id,'')) @@ to_tsquery(?search)"
        match = ifelse(input$exact, input$searchbox, paste0(input$searchbox, ':*'))
        q = DBI::sqlInterpolate(conn, query, search = match)
        rs = DBI::dbSendQuery(conn, q)
        res = DBI::dbFetch(rs)
        end.time <- Sys.time()
        cat(file=stderr(),end.time-start.time, "\n")
        res
    })


    output$res = renderUI({
        s = searchTable()
        if(is.null(s)) {
            return(NULL)
        }
        orthologs = unique(s$ortholog_id)
        div(class='search_results',
            lapply(orthologs, function(curr_ortho) {
                ret = s[s$ortholog_id==curr_ortho,]
                fluidRow(
                    h2(curr_ortho),
                    div(class='ortho-container', fluidRow(
                        apply(ret, 1, function(row) {
                            div(class = 'section',
                                div('Gene ID', class='label'),
                                div(row[5], class='orthovalue')
                            )
                        })
                    ))
                )
            })
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

    
    createLink <- function(val) {
        sprintf(
            "<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a>",
            val,
            val
        )
    }
    
    return(searchTable)
}
