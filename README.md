# shinyorthologs

[![Build Status](https://travis-ci.org/msuefishlab/shinyorthologs.svg?branch=master)](https://travis-ci.org/msuefishlab/shinyorthologs)

Shiny interface to an ortholog database

## Prerequisites

To get system dependencies, for example on Ubuntu 16, use

    sudo apt install r-base-core postgresql libpq-dev postgresql-contrib

Install R dependencies, use devtools

    devtools::install_deps()

## Load data

The tests/data directory contains an example dataset that can be loaded

If you data is in this format then you can use the create.sql, load_fasta.sh, load_expression.sh, and load.sh scripts, copy these into your own data directory, then run

    ./load.sh yourdbname
    
Then copy sample_config.json to config.json and enter the parameters appropriately



## Usage

After loading the data, run

    shiny::runApp()

or simply put the shinyorthologs application directory in the shiny-server webapps directory.


