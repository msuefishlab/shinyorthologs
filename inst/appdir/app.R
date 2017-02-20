library(shiny)

source('gene.R')
source('ortholog.R')
source('comparisons.R')
source('edit.R')
source('pheatmap.R')

fastaIndexes <<- list()
initFastaIndexes <- function() {
    source('dbparams.R', local = TRUE)
    con = do.call(dbConnect, args)
    query = sprintf('SELECT transcriptome_fasta from species')
    ret = dbGetQuery(con, query)
    fastaIndexes <<- lapply(ret$transcriptome_fasta, function(fasta) {
        fa = open(FaFile(paste0(baseDir, '/', fasta)))
        scanFaIndex(fa)
    })
    names(fastaIndexes) <<- ret$transcriptome_fasta
    dbDisconnect(con)
}
initFastaIndexes()

expressionFiles <<- list()
initExpressionFiles <- function() {
    source('dbparams.R', local = TRUE)
    con = do.call(dbConnect, args)
    query = sprintf('SELECT expression_file from species')
    ret = dbGetQuery(con, query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        read.csv(paste0(baseDir, '/', expr))
    })
    names(expressionFiles) <<- files
    dbDisconnect(con)
}
initExpressionFiles()

ui <- function(request) {
    fluidPage(
        titlePanel('webcompare'),

        tabsetPanel(id = 'inTabset',
            tabPanel('Comparisons',
                comparisonsUI('comparisons')
            ),
            tabPanel('Orthologs',
                orthologUI('orthologs')
            ),
            tabPanel('Genes',
                geneUI('gene')
            ),
            tabPanel('Edit',
                editUI('edit')
            )
        )
    )
}

server <- function(input, output, session) {
    callModule(geneServer, 'gene')
    callModule(orthologServer, 'orthologs')
    callModule(comparisonsServer, 'comparisons')
    callModule(editServer, 'edit')

    observe({
        query <- parseQueryString(session$clientData$url_search)
        if (!is.null(query[['tab']])) {
            updateTabsetPanel(session, "inTabset", selected = query[['tab']])
        }
    })
    enableBookmarking("url")
}


shinyApp(ui, server)
