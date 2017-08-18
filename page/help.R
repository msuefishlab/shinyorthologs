helpUI = function(id) {
    tagList(fluidRow(
        h2('Help'),
        h3('Introduction'),
        p('ShinyOrthologs is a database that links ortholog groups (genes connected by an ortholog ID) to gene expression data, FASTA sequences, other concepts'),
        h3('Overview'),
        h4('Search page'),
        p('The search page offers a input text and is sort of like "google" for the dataset. It performs full text search of gene descriptions, ortholog IDs, gene IDs, gene symbols, and dbxrefs. The search results link to an "ortholog page" that describes the ortholog in more detail. It also allows you to create a short list of "saved" genes by adding the search results to the a textarea at the bottom of the page. Saving a list of genes in this way is useful because you can then send the list to the heatmap page and see gene expression for your genes of interest.'),
        h4('Heatmap page'),
        p('The heatmap page allows you to view all the gene expression data for a list of inputted ortholog groups. The example button provides a quick example of the input format and an example heatmap. Since generally the ortholog groups will not be known by the user offhand, it is recommended that they use the "Search" tab or the "Lookup genes" tab to build a list of ortholog IDs of interest. Once the list of ortholog IDs is obtained, enter it into the search box separated by newlines. Then you can choose to normalize the data by column and/or row. Note that missing data will be displayed as 0 on the heatmap. This can be problematic, and if your species does not contain the ortholog of interest, you can use the "species" selection input to remove your species from the particular heatmap.'),
        h4('Lookup genes'),
        p('The lookup genes page will take a list of gene IDs (these are specific gene IDs, not free text descriptions of gene symbols) so for example the ENSEMBL gene IDs for danio or the Transcriptome gene IDs are acceptable. Enter them one per line. The example button contains a sample search. The orthologs will be returned as a dataframe which you can send to the heatmap tab for further analysis. Looking up genes in this way is therefore useful if you have a list of genes that are differentially expressed and you want to connect them to their respective orthologs to analyze expression from the closely related orthologous genes.'),m
        h4('Species'),
        p('The species tab simply displays an overview of the species and datasets that are loaded for each. It also has a link to a genome browser')
    ))
}


helpServer = function(input, output, session) {
}
