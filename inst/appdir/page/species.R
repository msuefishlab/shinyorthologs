speciesUI = function(id) {
    ns = NS(id)
    tagList(
        h1('Species listing'),
        fluidRow(
            h2('Data table'),
            DT::dataTableOutput(ns('table')),
            downloadButton(ns('downloadData'), 'Download')
        )
    )
}


speciesServer = function(input, output, session) {
    speciesTable = reactive({
        conn = pool::poolCheckout(pool)
        on.exit(pool::poolReturn(conn))

        rs = DBI::dbSendQuery(conn, 'SELECT * FROM species')
        ret = DBI::dbFetch(rs)
        ret$jbrowse = createJBrowseLink(ret$jbrowse)
        ret
    })
    output$table = DT::renderDataTable(speciesTable(), escape = F)
    output$downloadData <- downloadHandler(
        filename = 'species.csv',
        content = function(file) {
            write.table(speciesTable(), file, row.names = F, sep = '\t', quote = F)
        }
    )
    createJBrowseLink <- function(val) {
        ifelse(!is.na(val),
            sprintf("<a href='%s'>JBrowse</a>", val),
            val
        )
    }
}
