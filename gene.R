library(sqldf)
library(data.table)
library(Rsamtools)

geneUI <- function(id) {
    ns <- NS(id)
    tagList(
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
    )
}

geneServer <- function(input, output, session, geneData, transcriptData, speciesData) {

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
}
