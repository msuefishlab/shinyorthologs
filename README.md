# shinyorthologs

[![Build Status](https://travis-ci.org/msuefishlab/shinyorthologs.svg?branch=master)](https://travis-ci.org/msuefishlab/shinyorthologs)

Shiny interface to an ortholog database

## Prerequisites

To get system dependencies, for example on Ubuntu 16, use

    sudo apt install r-base-core postgresql libpq-dev postgresql-contrib

Install R dependencies, use install.sh

    ./install.sh


## Load data

Then configure data locations in [create.sql](https://github.com/msuefishlab/shinyorthologs/tree/master/create.sql)

Load the data into the database with `psql -d shinyorthologs < create.sql` or similar


## Usage

The library is intended to be installed via bioconductor or a similar package manager, so starting the server involves including the library and calling the `shinyorthologs()` function

shiny::runApp()

or simply put the app directory in a directory serving other shiny apps for the conventional shiny server installation


