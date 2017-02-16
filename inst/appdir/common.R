library(reshape2)
library(data.table)

source('config.R')


speciesData = reactive({
    print(getwd())
    fread(species)
})
geneData = reactive({
    fread(genes)
})
transcriptData = reactive({
    fread(transcripts)
})
orthologData = reactive({
    x = fread(orthologs)
    y = acast(x, orthos~variable)
})
