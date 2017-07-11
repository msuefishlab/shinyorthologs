init = function(pool) {
    fastaIndexes = list()
    conn <- pool::poolCheckout(pool)
    query = DBI::dbSendQuery(conn, 'SELECT transcriptome_fasta from species')
    ret = DBI::dbFetch(query)
    fastas = ret$transcriptome_fasta[!is.na(ret$transcriptome_fasta)]
    fastaIndexes <<-
        lapply(fastas, function(file) {
            print(file)
            fa = open(Rsamtools::FaFile(file))
            Rsamtools::scanFaIndex(fa)
        })
    names(fastaIndexes) <<- fastas

    expressionFiles = list()
    query = DBI::dbSendQuery(conn, 'SELECT expression_file from species')
    ret = DBI::dbFetch(query)
    files = ret$expression_file[!is.na(ret$expression_file)]
    expressionFiles <<- lapply(files, function(expr) {
        print(expr)
        data.table::fread(expr)
    })
    names(expressionFiles) <<- files
    pool::poolReturn(conn)
}




config <- jsonlite::fromJSON('config.json')
dbname = config$dbname
user = config$user
password = config$password
port = config$port
host = config$host

dbargs = c(
    RPostgreSQL::PostgreSQL(),
    list(dbname = dbname)[!is.null(dbname)],
    list(host = host)[!is.null(host)],
    list(user = user)[!is.null(user)],
    list(password = password)[!is.null(password)],
    list(port = port)[!is.null(port)]
)
pool = do.call(pool::dbPool, dbargs)
init(pool)


shiny::runApp()
