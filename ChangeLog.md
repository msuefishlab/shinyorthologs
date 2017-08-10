# Version 1.2.0

- Add bookmarking on heatmap
- Rename "gene page" to "ortholog lookup"
- Add better display of data on the "ortholog lookup" page
- Convert fasta and expression into database tables
- Remove multiple sequence alignment
- Remove the "shiny app as an R package" setup, as it overcomplicates things
- Change dependency installation to install.sh
- Improve the searching functionality
- Add ability to lookup multiple genes to ortholog IDs at once

# Version 1.0.0


- Created postgres data loaders
- Allows searching on ortholog ID, description, gene symbol, dbxref
- Multiple sequence alignment with msaR
- Added FASTA download of all transcripts in ortholog group
- Loaded genes with gene symbols, descriptions and dbxrefs
- Gene expression and heatmap viewer
- Allow editing ortholog relationships
- Use config file in JSON format
