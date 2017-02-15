library(sqldf)
library(data.table)
library(Rsamtools)

source('gene.R')
source('ortholog.R')




ui <- fluidPage(
    titlePanel('shinyOrthologs'),

    tabsetPanel(id = 'inTabset',
        tabPanel('Genes',
            geneUI('gene')
        ),
        tabPanel('Orthologs',
            orthologUI('orthologs')
        )
    ),

    div('Gallant lab - Michigan State University 2017', style="text-align: center; position: absolute; bottom: 0; width: 100%; height: 50px; background-color: black; color: white; z-index: 10000; padding: 10px;")
)

server <- function(input, output) {
    callModule(geneServer, 'gene')
    callModule(orthologServer, 'orthologs')
}


shinyApp(ui, server)
