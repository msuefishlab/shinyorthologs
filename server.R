library(sqldf)
library(data.table)
library(Rsamtools)


function(input, output) {
  geneData = reactive({
    read.csv('data/genes.csv',stringsAsFactors=F)
  })
  transcriptData = reactive({
    fread('data/transcripts.csv')
  })

  speciesData = reactive({
    read.csv('data/species.csv',stringsAsFactors=F)
  })
  geneTable = reactive({
    data = geneData()
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
  })

  output$table = DT::renderDataTable(geneTable(), selection = 'single')


  output$species = renderUI({
    data = speciesData()
    selectInput("species", "Species:", c("All", data$species))
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
      fa = open(FaFile(file))
      idx = scanFaIndex(fa)
      seq = getSeq(fa, idx[seqnames(idx) == ret$transcript_id])
      cbind(ret, as.character(seq))
    }
  })
}

