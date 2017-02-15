library(reshape2)
library(data.table)

speciesData = reactive({
    print(getwd())
    fread('species.csv')
})
geneData = reactive({
    fread('genes.csv')
})
transcriptData = reactive({
    fread('transcripts.csv')
})
orthologData = reactive({
    x = fread('orthologs.csv')
    y = acast(x, orthos~variable)
})
