source('gene.R')
source('ortholog.R')
source('comparisons.R')
source('edit.R')
source('pheatmap.R')

fastaIndexes <<- list()
initFastaIndexes <- function() {
    source('dbparams.R', local = TRUE)
    con = do.call(RPostgreSQL::dbConnect, args)
    query = sprintf('SELECT transcriptome_fasta from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    fastaIndexes <<- lapply(ret$transcriptome_fasta, function(fasta) {
        fa = open(Rsamtools::FaFile(paste0(baseDir, '/', fasta)))
        Rsamtools::scanFaIndex(fa)
    })
    names(fastaIndexes) <<- ret$transcriptome_fasta
    RPostgreSQL::dbDisconnect(con)
}
initFastaIndexes()

expressionFiles <<- list()
initExpressionFiles <- function() {
    source('dbparams.R', local = TRUE)
    con = do.call(RPostgreSQL::dbConnect, args)
    query = sprintf('SELECT expression_file from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        read.csv(paste0(baseDir, '/', expr))
    })
    names(expressionFiles) <<- files
    RPostgreSQL::dbDisconnect(con)
}
initExpressionFiles()

ui <- function(request) {
    shiny::fluidPage(
        shiny::titlePanel('webcompare'),

        shiny::tabsetPanel(id = 'inTabset',
            shiny::tabPanel('Comparisons',
                comparisonsUI('comparisons')
            ),
            shiny::tabPanel('Orthologs',
                orthologUI('orthologs')
            ),
            shiny::tabPanel('Genes',
                geneUI('gene')
            ),
            shiny::tabPanel('Edit',
                editUI('edit')
            )
        )
    )
}

server <- function(input, output, session) {
    shiny::callModule(geneServer, 'gene')
    shiny::callModule(orthologServer, 'orthologs')
    shiny::callModule(comparisonsServer, 'comparisons')
    shiny::callModule(editServer, 'edit')

    shiny::observe({
        query <- shiny::parseQueryString(session$clientData$url_search)
        if (!is.null(query[['tab']])) {
            shiny::updateTabsetPanel(session, "inTabset", selected = query[['tab']])
        }
    })
    shiny::enableBookmarking("url")
}


shiny::shinyApp(ui, server)
