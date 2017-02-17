library(reshape2)
library(data.table)

mstop = function() {
    stop(paste("'config' variables are missing. This Shiny App is intended to be run",
       "as part of larger workflow. See example.R for configuration and running instructions"))
}
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

    query <- sprintf("SELECT * from orthologs")
    x = dbGetQuery(con, query)
    y = acast(x, ortholog_id~species_id)
})

# returns string w/o leading whitespace
trim.leading <- function (x)  sub("^\\s+", "", x)

# returns string w/o trailing whitespace
trim.trailing <- function (x) sub("\\s+$", "", x)

# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
