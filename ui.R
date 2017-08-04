library(shiny)
library(shinyjs)
library(jsonlite)

config <<- fromJSON('config.json')
shinyUI(function(request) {
    source('page/search.R', local = T)
    source('page/heatmap.R', local = T)
    source('page/list.R', local = T)
    source('page/genepage.R', local = T)
    source('page/help.R', local = T)
    source('page/edit.R', local = T)
    source('page/species.R', local = T)
    source('page/recently_updated.R', local = T)
    fluidPage(
        useShinyjs(),
        tags$head(includeScript('js/ga.js')),
        includeCSS('css/styles.css'),
        headerPanel('ShinyOrthologs'),
        wellPanel(style = 'background-color: #ffffff;',
            tabsetPanel(id = 'inTabset',
                tabPanel(style = 'margin: 20px;', id = 'search', 'Home', searchUI('search')),
                tabPanel(style = 'margin: 20px;', id = 'heatmap', 'Heatmap', heatmapUI('heatmap'), value = 'heatmap'),
                tabPanel(style = 'margin: 20px;', id = 'list', 'Lookup genes', listUI('list')),
                tabPanel(style = 'margin: 20px;', id = 'species', 'Species table', speciesUI('species')),
                tabPanel(style = 'margin: 20px;', id = 'genepage', 'Gene page', genepageUI('genepage')),
                tabPanel(style = 'margin: 20px;', id = 'edit', 'Edit', editUI('edits')),
                tabPanel(style = 'margin: 20px;', id = 'updated', 'Recent updates', updatesUI('updates')),
                tabPanel(style = 'margin: 20px;', id = 'help', 'Help', helpUI('help'))
            )
        )
    )
})
