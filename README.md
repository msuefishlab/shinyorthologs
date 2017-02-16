# shinyorthologs

[![Build Status](https://travis-ci.org/msuefishlab/shinyorthologs.svg?branch=master)](https://travis-ci.org/msuefishlab/shinyorthologs)<Paste>

Shiny interface to an ortholog database

## Prerequisites

    source("https://bioconductor.org/biocLite.R")
    biocLite("msuefishlab/shinyorthologs")


## Configure

After the library is installed, it is intended to be configured and run in an R script, see [example.R](https://github.com/msuefishlab/shinyorthologs/tree/master/example.R)


## Load data

Run the create.sql

Configure database parameters in example.R

Usable parameters include the following. Parameters that are not defined in example.R use defaults, such as localhost, username default to postgres, password default to no password, etc.

    db_user
    db_pass
    db_port
    db_name
    db_host

## Run

Copy the example file and configure it as needed

    source('example.R')

## Notes

See extdata folder for data files needed to configure your example config

In development, you can run `devtools::install('.'); source('example.R')`
