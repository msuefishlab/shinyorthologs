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
orthologData = reactive({
    con = do.call(RPostgreSQL::dbConnect, .args)
    on.exit(RPostgreSQL::dbDisconnect(con))
    query = sprintf("SELECT $$SELECT * FROM crosstab('SELECT ortholog_id, species_id, gene_id FROM orthologs ORDER  BY 1, 2') AS ct (ortholog_id varchar(255), $$ || string_agg(quote_ident(species_id), ' varchar(255), ' ORDER BY species_id) || ' varchar(255))' FROM species")
    ret = RPostgreSQL::dbGetQuery(con, query)
    RPostgreSQL::dbGetQuery(con, ret[1, ])
})



