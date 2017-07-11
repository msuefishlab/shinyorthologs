# shinyorthologs

[![Build Status](https://travis-ci.org/msuefishlab/shinyorthologs.svg?branch=master)](https://travis-ci.org/msuefishlab/shinyorthologs)<Paste>

Shiny interface to an ortholog database

## Prerequisites

- PostgreSQL
- R

Example installing for Ubuntu 16

    sudo apt install r-base-core postgresql libpq-dev

R dependencies, see install.sh

    ./install.sh

## Install

Use devtools and bioconductor to install shinyorthologs

    install.packages('packrat')
    packrat::init()

## Load data

Then configure data locations in [create.sql](https://github.com/msuefishlab/shinyorthologs/tree/master/create.sql)

Load the data into the database with `psql -d shinyorthologs < create.sql` or similar


## Usage

The library is intended to be installed via bioconductor or a similar package manager, so starting the server involves including the library and calling the `shinyorthologs()` function

    library(shinyorthologs)
    shinyorthologs(dbname="shinyorthologs")

## Notes

In development, you can run

    devtools::load_all()
    shinyorthologs(dbname="shinyorthologs", dev=T)
