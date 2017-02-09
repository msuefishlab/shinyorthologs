library(ggplot2)
library(sqldf)
library(data.table)
library(DT)


function(input, output) {
  dataInput = reactive({
    read.csv('genes.csv')
  })

  output$table = renderDataTable(datatable({
    data = dataInput()
    if(is.null(input$species)) {
       return(NULL)
    }
    if (input$species != "All") {
      data = data[data$species == input$species,]
    }
    if (input$gene != "") {
	  query = sprintf("select * from data where id LIKE '%%%s%%'", input$gene)
      data = sqldf(query)
    }
    data
  }), options = list(pageLength = 30))


  output$species = renderUI({
    data = dataInput()
    selectInput("species", "Species:", c("All", unique(data$species)))
  })
}

