CREATE EXTENSION tablefunc;
CREATE TABLE genes (GENE_ID varchar(255), SPECIES_ID varchar(255));
CREATE TABLE orthologs (ORTHOLOG_ID varchar(255), SPECIES_ID varchar(255), GENE_ID varchar(255));
CREATE TABLE transcripts (GENE_ID varchar(255), TRANSCRIPT_ID varchar(255));
CREATE TABLE species (SPECIES_ID varchar(255), TRANSCRIPTOME_FASTA varchar(255), SPECIES_NAME varchar(255));
COPY genes FROM '/Users/cdiesh/testdata/genes.csv' CSV HEADER;
COPY transcripts FROM '/Users/cdiesh/testdata/transcripts.csv' CSV HEADER;
COPY species FROM '/Users/cdiesh/testdata/species.csv' CSV HEADER;
COPY orthologs FROM '/Users/cdiesh/testdata/orthologs.csv' CSV HEADER;
