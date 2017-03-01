orthologUI = function(id) {

    ns = NS(id)
    tagList(
        fluidRow(
            h2('Ortholog information')
        ),
        fluidRow(
            DT::dataTableOutput(ns('table'))
        )
    )
}
orthologServer = function(input, output, session) {

    orthologTable = reactive({
        con = do.call(RPostgreSQL::dbConnect, dbargs)
        on.exit(RPostgreSQL::dbDisconnect(con))

        query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species")

        # query returns another query
        query2 = RPostgreSQL::dbGetQuery(con, query)
        RPostgreSQL::dbGetQuery(con, query2[1, ])
    })

    output$table = DT::renderDataTable({
        tab = orthologTable()
        tab$ortholog_id <- createLink(tab$ortholog_id)
        tab
    },
    selection = 'single', escape = F)


    output$downloadData <- downloadHandler(
        filename = 'search.csv',
        content = function(file) {
            write.csv(orthologTable(), file)
        }
    )

    createLink <- function(val) {
        sprintf('<a href="?_inputs_&inTabset=Gene%%20page&ortholog=%s">%s</a>', val, val)
    }

}
