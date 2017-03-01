source('view/search.R')
source('view/ortholog.R')
source('view/comparisons.R')
source('view/edit.R')
source('view/species.R')
source('view/help.R')
source('pheatmap.R')

fastaIndexes <<- list()
initFastaIndexes <- function() {
    con = do.call(RPostgreSQL::dbConnect, .args)
    query = sprintf('SELECT transcriptome_fasta from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    fastaIndexes <<- lapply(ret$transcriptome_fasta, function(fasta) {
        file = file.path(.baseDir, fasta)
        print(file)
        fa = open(Rsamtools::FaFile(file))
        Rsamtools::scanFaIndex(fa)
    })
    names(fastaIndexes) <<- ret$transcriptome_fasta
    RPostgreSQL::dbDisconnect(con)
}
initFastaIndexes()

expressionFiles <<- list()
initExpressionFiles <- function() {
    con = do.call(RPostgreSQL::dbConnect, .args)
    query = sprintf('SELECT expression_file from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        read.csv(file.path(.baseDir, expr))
    })
    names(expressionFiles) <<- files
    RPostgreSQL::dbDisconnect(con)
}
initExpressionFiles()

ui <- function(request) {
    shiny::fluidPage(
        shiny::titlePanel('shinyorthologs2'),

        shiny::tabsetPanel(id = 'inTabset',
            shiny::tabPanel('Orthologs', orthologUI('orthologs')),
            shiny::tabPanel('Comparisons', comparisonsUI('comparisons')),
            shiny::tabPanel('Genes', searchUI('search')),
            shiny::tabPanel('Species', speciesUI('species')),
            shiny::tabPanel('Edit', editUI('edit')),
            shiny::tabPanel('Help', helpUI('help'))
        )
    )
}

server <- function(input, output, session) {
    shiny::callModule(searchServer, 'search')
    shiny::callModule(orthologServer, 'orthologs')
    shiny::callModule(comparisonsServer, 'comparisons')
    shiny::callModule(speciesServer, 'species')
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
