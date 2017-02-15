library(reshape2)
library(data.table)

speciesData = reactive({
    fread('data/species.csv')
})
geneData = reactive({
    fread('data/genes.csv')
})
transcriptData = reactive({
    fread('data/transcripts.csv')
})
orthologData = reactive({
    x = fread('data/orthologs.csv')
    y = acast(x, orthos~variable)
})
