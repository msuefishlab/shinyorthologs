library(shiny)

source('gene.R')
source('ortholog.R')

ui <- fluidPage(
    titlePanel('webcompare'),

    tabsetPanel(id = 'inTabset',
        
        tabPanel('Orthologs',
            orthologUI('orthologs')
        ),
        tabPanel('Genes',
            geneUI('gene')
        )
    )
)

server <- function(input, output, session) {
    callModule(geneServer, 'gene')
    callModule(orthologServer, 'orthologs')

    observe({
        query <- parseQueryString(session$clientData$url_search)
        if (!is.null(query[['tab']])) {
            updateTabsetPanel(session, "inTabset", selected = query[['tab']])
        }
    })
}


shinyApp(ui, server)
