library(ggplot2)
library(sqldf)
library(data.table)
library(DT)


function(input, output) {
  dataInput = reactive({
    read.csv('data/genes.csv')
  })

  output$table = renderDataTable({
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
  }, selection = 'single')


  output$species = renderUI({
    data = dataInput()
    selectInput("species", "Species:", c("All", unique(data$species)))
  })
}

