library(sqldf)
library(data.table)
library(Rsamtools)

source('gene.R')

shinyApp(
    ui = fluidPage(
        titlePanel("shinyorthologs"),
        tabsetPanel(id = "inTabset",
            tabPanel("Genes",
                geneUI("genes")
            ),
            tabPanel("Orthologs",

                fluidRow(
                    DT::dataTableOutput("orthoTable")
                ),
                fluidRow(
                    h2("Ortholog information"),
                    column(4, uiOutput("ortho"))
                )
            )
        )
    ),

    server = function(input, output, session) {

        callModule(geneServer, "myModule1", reactive(input$checkbox1))

        
    }
)
