speciesData = reactive({
    fread('data/species.csv')
})
geneData = reactive({
    fread('data/genes.csv')
})
transcriptData = reactive({
    fread('data/transcripts.csv')
})
