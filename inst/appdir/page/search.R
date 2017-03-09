searchUI = function(id) {
    ns = NS(id)
    tagList(
        textInput(ns('searchbox'), 'Search'),
        DT::dataTableOutput(ns('results'))
    )
}
searchServer = function(input, output, session) {
    searchTable = reactive({
        if(is.null(input$searchbox) || input$searchbox == "") {
            return()
        }
        conn = poolCheckout(pool)
        print(input$searchbox)
        query = "SELECT * FROM orthologs o JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id WHERE to_tsvector(od.description || ' ' || o.ortholog_id || ' ' || od.symbol || ' ' || o.gene_id) @@ to_tsquery(?search)"
        q = sqlInterpolate(conn, query, search = input$searchbox)
        rs = dbSendQuery(conn, q)
        ret = dbFetch(rs)
        poolReturn(conn)
        ret
    })
    
    output$results = DT::renderDataTable({
        searchTable()
    })
    
    return(searchTable)
}
