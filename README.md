# shinyorthologs

[![Build Status](https://travis-ci.org/msuefishlab/shinyorthologs.svg?branch=master)](https://travis-ci.org/msuefishlab/shinyorthologs)<Paste>

Shiny interface to an ortholog database

## Prerequisites

- PostgreSQL
- R


## Install

    source("https://bioconductor.org/biocLite.R")
    biocLite("msuefishlab/shinyorthologs")


## Load data

Then configure data locations in [create.sql](https://github.com/msuefishlab/shinyorthologs/tree/master/create.sql)

Load the data into the database with `psql -d shinyorthologs < create.sql` or similar


## Usage

The library is intended to be installed via bioconductor or a similar package manager, so starting the server involves including the library and calling the `shinyorthologs()` function

    library(shinyorthologs)
    shinyorthologs()

The example.R script includes examples of configuring the environment to run this, with database parameters like `db_user, db_pass, db_port, db_name, db_host`

## Notes

In development, you can run `devtools::install('.'); source('example.R')`
