# Version 1.1.0

## Features

- Add better display of data on the "ortholog lookup" page
- Improve the searching functionality with postgres full text search
- Add fasta and expression data into database tables
- Add ability to lookup multiple genes to ortholog IDs at once
- Add ability to save genes to a list from the search page
- Add ranking to searches

Fixes

- Rename "gene page" to "ortholog lookup"
- Remove the "shiny app as an R package" setup, as it overcomplicates things
- Remove multiple sequence alignment
- Fix URL bookmarking on heatmap

# Version 1.0.0


- Created postgres data loaders
- Allows searching on ortholog ID, description, gene symbol, dbxref
- Multiple sequence alignment with msaR
- Added FASTA download of all transcripts in ortholog group
- Loaded genes with gene symbols, descriptions and dbxrefs
- Gene expression and heatmap viewer
- Allow editing ortholog relationships
- Use config file in JSON format
