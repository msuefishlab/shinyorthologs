orthologUI = function(id) {
    ns = NS(id)
    tagList(fluidRow(
        h2('Ortholog information'),
        textInput(ns('search'), 'Search'),
        uiOutput(ns('search_results'))
    ))
}
orthologServer = function(input, output, session) {
    orthologTable = reactive({
        conn <- poolCheckout(pool)
        rs <- dbSendQuery(conn, "SELECT * FROM species")
        ret = dbFetch(rs)
        poolReturn(conn)
        ret
    })
    
    observe({
        
    })
    
    output$downloadData = downloadHandler(
        'orthologs.csv',
        content = function(file) {
            tab = orthologTable()
            write.csv(tab[input$table_rows_all, , drop = FALSE], file)
        }
    )
    
    createLink <- function(val) {
        sprintf(
            "<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a>",
            val,
            val
        )
    }
}
