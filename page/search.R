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
        br(),
        uiOutput(ns('res')),
        br(),
        textAreaInput(ns('ortholist'), 'Saved orthoIDs', height = '100px', width = '600px'),
        actionButton(ns('sendToHeatmap'), 'Send to heatmap'),
        actionButton(ns('clearList'), 'Clear')
    )
}
searchServer = function(input, output, session, parent) {

    searchTable = reactive({
        if(is.null(input$searchbox) || input$searchbox == '') {
            return(NULL)
        }
        session$doBookmark()
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        # aggregate database gene id
        start.time <- Sys.time()
        query = "SELECT o.ortholog_id, g.gene_id, g.species_id, g.description, g.symbol FROM search_index s JOIN orthologs o on o.ortholog_id = s.ortholog_id JOIN genes g on o.gene_id = g.gene_id WHERE s.document @@ to_tsquery('english', ?search) ORDER BY ts_rank(p_search.document, to_tsquery('english', ?search) DESC, o.ortholog_id LIMIT 150";
        q = DBI::sqlInterpolate(conn, query, search = paste0(input$searchbox, ifelse(input$exact, '', ':*')))
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
        tagList(
            div(class='num_results', paste('Search returned', length(orthologs), 'results')),
            div(class='search_results',
                lapply(orthologs, function(curr_ortho) {
                    ret = s[s$ortholog_id==curr_ortho,]
                    fluidRow(
                        h2(a(href=sprintf('?_inputs_&inTabset=\"Ortholog%%20lookup\"&genepage-ortholog=\"%s\"', curr_ortho), curr_ortho), ret[1,5], ret[1,4]),
                        a(class='listitem', href='#', id=curr_ortho, 'Add to saved list'),
                        div(class='ortho-container', fluidRow(
                            apply(ret, 1, function(row) {
                                div(class = 'section',
                                    div('Gene ID', class='label'),
                                    div(paste(row[2], row[3]), class='orthovalue')
                                )
                            })
                        ))
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


    createLink <- function(val) {
        sprintf(
            "<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a>",
            val,
            val
        )
    }

    observeEvent(input$sendToHeatmap, {
        updateTextAreaInput(parent, 'heatmap-genes', value=input$ortholist)
        updateTabsetPanel(parent, "inTabset", selected = "heatmap")
    })

    observeEvent(input$clearList, {
        updateTextAreaInput(session, 'ortholist', value='')
    })
    return(searchTable)
}
