library(sqldf)
library(data.table)
library(Rsamtools)


shinyApp(
    ui = fluidPage(
        titlePanel("shinyorthologs"),
        tabsetPanel(id = "inTabset",
            tabPanel("Genes",
                fluidRow(
                    column(4, uiOutput("species")),
                    column(4, textInput("gene", "Gene: "))
                ),

                fluidRow(
                    DT::dataTableOutput("table")
                ),

                fluidRow(
                    h2("Gene information"),
                    column(4, uiOutput("row"))
                )
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
        geneData = reactive({
            fread('data/genes.csv')
        })
        transcriptData = reactive({
            fread('data/transcripts.csv')
        })
        speciesData = reactive({
            fread('data/species.csv')
        })

        myFile <- reactive({
            species = speciesData()
            data = geneTable()
            row = data[input$table_rows_selected, ]
            ss = row$species
            species[species$shortName == ss, ]$file
        })

        myIdx <- reactive({
            scanFaIndex(open(FaFile(myFile())))
        })
        

        orthologData = reactive({
            x = fread('data/orthologs.csv')
            y = acast(x, orthos~variable)
        })

        geneTable = reactive({
            data = geneData()
            species = speciesData()
            if (is.null(input$species)) {
                return(NULL)
            }
            if (input$species != "All") {
                ss = species[species$name == input$species, ]$shortName
                data = data[data$species == ss, ]
            }
            if (input$gene != "") {
                query = sprintf("select * from data where id LIKE '%%%s%%'", input$gene)
                data = sqldf(query)
            }
            data
        })
        orthologTable = reactive({
            data = orthologData()
            data
        })
        output$table = DT::renderDataTable(geneTable(), selection = 'single')


        output$species = renderUI({
            data = speciesData()
            selectInput("species", "Species:", c("All", data$name))
        })


        output$row = renderTable({
            if (!is.null(input$table_rows_selected)) {
                data = geneTable()
                species = speciesData()
                transcripts = transcriptData()

                row = data[input$table_rows_selected, ]
                ret = transcripts[transcripts$gene_id == row$id, ]
                ss = row$species
                file = species[species$shortName == ss, ]$file
                fa = open(FaFile(file))
                idx = myIdx()
                seq = sapply(ret$transcript_id, function(n) {
                    as.character(getSeq(fa, idx[seqnames(idx) == n]))
                })
                cbind(ret, seq)
            }
        })

        output$orthoTable = DT::renderDataTable(orthologTable(), selection = 'single')

        output$ortho = renderTable({
            if (!is.null(input$orthoTable_rows_selected)) {
                data = orthologTable()
                row = data[input$orthoTable_rows_selected, ]
                print(row)
                t(row)
            }
        })

        observe({
            query <- parseQueryString(session$clientData$url_search)
            print(query)
            if (!is.null(query[['tab']])) {
                updateTabsetPanel(session, "inTabset", selected = query[['tab']])
            }
        })
    }
)
