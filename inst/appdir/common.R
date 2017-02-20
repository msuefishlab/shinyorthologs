library(data.table)
library(RPostgreSQL)
library(jsonlite)

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
})
orthologData = reactive({
    con = do.call(dbConnect, args)
    on.exit(dbDisconnect(con))
    query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species")
    print(query)
    ret = dbGetQuery(con, query)
    print(ret)
    dbGetQuery(con, ret[1,])
})

