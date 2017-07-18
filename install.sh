#!/usr/bin/env Rscript

source("https://bioconductor.org/biocLite.R")
biocLite(c(
    'devtools',
    'tools',
    'data.table',
    'jsonlite',
    'DT',
    'shiny',
    'RPostgreSQL',
    'reshape2',
    'DBI',
    'testthat',
    'pheatmap')
)
biocLite('Rsamtools')
biocLite('rstudio/pool')
