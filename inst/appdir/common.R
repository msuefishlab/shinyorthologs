speciesData = reactive({
    con = do.call(RPostgreSQL::dbConnect, .args)
    on.exit(RPostgreSQL::dbDisconnect(con))

    query <- sprintf("SELECT * from species")
    RPostgreSQL::dbGetQuery(con, query)
})
geneData = reactive({
    con = do.call(RPostgreSQL::dbConnect, .args)
    on.exit(RPostgreSQL::dbDisconnect(con))

    query <- sprintf("SELECT * from genes")
    RPostgreSQL::dbGetQuery(con, query)
})
transcriptData = reactive({
    con = do.call(RPostgreSQL::dbConnect, .args)
    on.exit(RPostgreSQL::dbDisconnect(con))

    query <- sprintf("SELECT * from transcripts")
    RPostgreSQL::dbGetQuery(con, query)
})
