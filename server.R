library(ggplot2)
library(data.table)

mydata = read.csv('genes.csv')

function(input, output) {

  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- mydata
    if (input$species != "All") {
      data <- data[data$species == input$species,]
    }
    if (input$gene != "") {
      data <- data[data$gene == input$gene,]
    }
    data
  }), pageLength = 30)


  output$species <- renderUI({
    selectInput("species", "Species:", c("All", unique(mydata$species)))
  })
}

