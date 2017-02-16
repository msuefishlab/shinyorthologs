library(shinyorthologs)

db_name <- 'shinyorthologs'
db_host <- NULL #'localhost'
db_port <- '5432'
db_user <- 'postgres'
db_pass <- NULL #pass

baseDir <- '~/testdata'
genesCsv <- 'genes.csv'
orthologsCsv <- 'orthologs.csv'
speciesCsv <- 'species.csv'
transcriptsCsv <- 'transcripts.csv'

shinyorthologs()
