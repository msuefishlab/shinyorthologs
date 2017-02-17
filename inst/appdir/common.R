library(reshape2)
library(data.table)
library(RPostgreSQL)

mstop = function() {
    stop(paste("'config' variables are missing. This Shiny App is intended to be run",
       "as part of larger workflow. See example.R for configuration and running instructions"))
}



use_name = exists('db_name')
use_port = exists('db_port')
use_user = exists('db_user')
use_pass = exists('db_pass')
use_host = exists('db_host')
if(!exists('db_port')) db_port=NULL
if(!exists('db_host')) db_host=NULL
if(!exists('db_name')) db_name=NULL
if(!exists('db_pass')) db_pass=NULL
if(!exists('db_user')) db_user=NULL
args = c(
    PostgreSQL(),
    list(dbname = db_name)[use_name],
    list(host = db_host)[use_host],
    list(user = db_user)[use_user],
    list(password = db_pass)[use_pass],
    list(port = db_port)[use_port]
)
speciesData = reactive({
    con = do.call(dbConnect, args)
    on.exit(dbDisconnect(con))

    query <- sprintf("SELECT * from species")
    dbGetQuery(con, query)
})
geneData = reactive({
    con = do.call(dbConnect, args)
    on.exit(dbDisconnect(con))

    query <- sprintf("SELECT * from genes")
    dbGetQuery(con, query)
})
transcriptData = reactive({
    con = do.call(dbConnect, args)
    on.exit(dbDisconnect(con))

    query <- sprintf("SELECT * from transcripts")
    dbGetQuery(con, query)
    fread(paste0(baseDir, '/', transcriptsCsv))
})
orthologData = reactive({
    con = do.call(dbConnect, args)
    on.exit(dbDisconnect(con))

    query <- sprintf("select gene_id, species_id, ortholog_id from orthologs group by gene_id, ortholog_id, species_id order by ortholog_id \\crosstabview ortholog_id species_id gene_id")
    x = dbGetQuery(con, query)
})

# returns string w/o leading whitespace
trim.leading <- function (x)  sub("^\\s+", "", x)

# returns string w/o trailing whitespace
trim.trailing <- function (x) sub("\\s+$", "", x)

# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
