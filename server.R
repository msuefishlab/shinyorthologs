library(sqldf)
library(data.table)
library(Rsamtools)


function(input, output, session) {
  geneData = reactive({
    read.csv('data/genes.csv',stringsAsFactors=F)
  })
  transcriptData = reactive({
    fread('data/transcripts.csv')
  })
  speciesData = reactive({
    read.csv('data/species.csv',stringsAsFactors=F)
  })

  observe({
    query <- parseQueryString(session$clientData$url_search)
    for (i in 1:(length(reactiveValuesToList(input)))) {
      nameval = names(reactiveValuesToList(input)[i])
      valuetoupdate = query[[nameval]]

      if (!is.null(query[[nameval]])) {
        if (is.na(as.numeric(valuetoupdate))) {
          updateTextInput(session, nameval, value = valuetoupdate)
        }
        else {
          updateTextInput(session, nameval, value = as.numeric(valuetoupdate))
        }
      }
    }
  })
  geneTable = reactive({
    data = geneData()
    species = speciesData()
    if(is.null(input$species)) {
       return(NULL)
    }
    if (input$species != "All") {
      ss = species[species$name==input$species,]$shortName
      data = data[data$species == ss,]
    }
    if (input$gene != "") {
	  query = sprintf("select * from data where id LIKE '%%%s%%'", input$gene)
      data = sqldf(query)
    }
    data
  })

  output$table = DT::renderDataTable(geneTable(), selection = 'single')


  output$species = renderUI({
    data = speciesData()
    selectInput("species", "Species:", c("All", data$name))
  })


  output$row = renderTable({
    if(!is.null(input$table_rows_selected)) {
      data = geneTable()
      species = speciesData()
      transcripts <- transcriptData()

      row = data[input$table_rows_selected,]
      ret = transcripts[transcripts$gene_id==row$id,]
      ss = row$species
      file = species[species$shortName==ss,]$file
      print(file)
      fa = open(FaFile(file))
      print(fa)
      idx = scanFaIndex(fa)
      seq = sapply(ret$transcript_id, function(n) {
        as.character(getSeq(fa, idx[seqnames(idx) == n]))
      })
      cbind(ret, seq)
    }
  })
}

