#!/usr/bin/env Rscript

options(repos = c(CRAN = "http://cran.rstudio.com"))

install.packages(c(
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
    'roxygen2',
    'pheatmap')
)
devtools::install_github('rstudio/pool')
