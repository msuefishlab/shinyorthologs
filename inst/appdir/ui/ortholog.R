orthologUI = function(id) {

    ns = shiny::NS(id)
    shiny::tagList(
        shiny::fluidRow(
            shiny::h2('Ortholog information'),
            DT::dataTableOutput(ns('row'))
        ),
        shiny::fluidRow(
            DT::dataTableOutput(ns('orthoTable'))
        ),
        shiny::fluidRow(
            shiny::p('Download as CSV'),
            shiny::downloadButton(ns('downloadData'), 'Download'),
        ),

        shiny::fluidRow(
            shiny::h2('Ortholog information'),
            DT::dataTableOutput(ns('row'))
        ),

        shiny::fluidRow(
            shiny::h2('Heatmaps'),
            shiny::plotOutput(ns('heatmap'))
        ),

        shiny::fluidRow(
            shiny::h2('MSA'),
            msaR::msaROutput(ns('msaoutput'))
        )
    )
}
