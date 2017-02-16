library(reshape2)
library(data.table)

mstop = function() {
    stop(paste("'config' variables are missing. This Shiny App is intended to be run",
       "as part of larger workflow. See example.R for configuration and running instructions"))
}
speciesData = reactive({
    if (!exists("speciesCsv")) {
        mstop()
    }
    fread(paste0(baseDir, '/', speciesCsv))
})
geneData = reactive({
    if (!exists("genesCsv")) {
        mstop()
    }
    fread(paste0(baseDir, '/', genesCsv))
})
transcriptData = reactive({
    if (!exists("transcriptsCsv")) {
        mstop()
    }
    fread(paste0(baseDir, '/', transcriptsCsv))
})
orthologData = reactive({
    if (!exists("orthologsCsv")) {
        mstop()
    }
    x = fread(paste0(baseDir, '/', orthologsCsv))
    y = acast(x, orthos~variable)
})
