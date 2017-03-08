orthologUI = function(id) {

    ns = NS(id)
    tagList(
        fluidRow(
            h2('Ortholog information')
        ),
        fluidRow(
            DT::dataTableOutput(ns('table')),
            downloadButton(ns('downloadData'), 'Download CSV')
        )
    )
}
orthologServer = function(input, output, session) {
    orthologTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT * FROM orthodescriptions od join orthologs o on od.ortholog_id = o.ortholog_id;")

        RPostgreSQL::dbGetQuery(con, query)
    })

    output$table = DT::renderDataTable({
        tab = orthologTable()
        tab$ortholog_id <- createLink(tab$ortholog_id)
        tab
    },
    selection = 'single', escape = F)


    output$downloadData = downloadHandler('orthologs.csv',
        content = function(file) {
            tab = orthologTable()
            write.csv(tab[input$table_rows_all, , drop = FALSE], file)
        }
    )

    createLink <- function(val) {
        sprintf("<a href='?_inputs_&inTabset=\"Gene%%20page\"&genepage-ortholog=\"%s\"'>%s</a>", val, val)
    }
}
