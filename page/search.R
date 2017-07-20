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
        query = "SELECT * FROM search_index WHERE description @@ to_tsquery('english', ?search)";
        q = DBI::sqlInterpolate(conn, query, search = input$searchbox)
        rs = DBI::dbSendQuery(conn, q)
        res = DBI::dbFetch(rs)
        end.time <- Sys.time()
        loginfo(paste0("time to query ",end.time-start.time))
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
