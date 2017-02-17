library(shinyorthologs)

db_name <- 'shinyorthologs'

#optional params, can leave commented if you just use localhost trusted logins anyways:
#db_port <- '5432'
#db_user <- 'postgres'
#db_host <- 'localhost'
#db_pass <- 'password'

baseDir <- '~/testdata'
genesCsv <- 'genes.csv'
orthologsCsv <- 'orthologs.csv'
speciesCsv <- 'species.csv'
transcriptsCsv <- 'transcripts.csv'

shinyorthologs()
