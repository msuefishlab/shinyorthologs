source('pheatmap.R')

fastaIndexes = list()
initFastaIndexes <- function() {
    con = do.call(RPostgreSQL::dbConnect, .args)
    query = sprintf('SELECT transcriptome_fasta from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    fastaIndexes <<- lapply(ret$transcriptome_fasta, function(fasta) {
        file = file.path(baseDir, fasta)
        print(file)
        fa = open(Rsamtools::FaFile(file))
        Rsamtools::scanFaIndex(fa)
    })
    names(fastaIndexes) <<- ret$transcriptome_fasta
    RPostgreSQL::dbDisconnect(con)
}
initFastaIndexes()

expressionFiles = list()
initExpressionFiles <- function() {
    con = do.call(RPostgreSQL::dbConnect, .args)
    query = sprintf('SELECT expression_file from species')
    ret = RPostgreSQL::dbGetQuery(con, query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        read.csv(file.path(baseDir, expr))
    })
    names(expressionFiles) <<- files
    RPostgreSQL::dbDisconnect(con)
}
initExpressionFiles()
