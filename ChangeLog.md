# Version 1.1.0

- Rename "gene page" to "ortholog lookup"
- Add better display of data on the "ortholog lookup" page
- Change dependency installation to install.sh
- Improve the searching functionality with postgres full text search
- Add bookmarking on heatmap
- Add fasta and expression data into database tables
- Add ability to lookup multiple genes to ortholog IDs at once
- Add ability to save genes to a list from the search page

Removed

- Remove the "shiny app as an R package" setup, as it overcomplicates things
- Remove multiple sequence alignment

# Version 1.0.0


- Created postgres data loaders
- Allows searching on ortholog ID, description, gene symbol, dbxref
- Multiple sequence alignment with msaR
- Added FASTA download of all transcripts in ortholog group
- Loaded genes with gene symbols, descriptions and dbxrefs
- Gene expression and heatmap viewer
- Allow editing ortholog relationships
- Use config file in JSON format
