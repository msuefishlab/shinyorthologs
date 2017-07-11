CREATE OR REPLACE FUNCTION update_changetimestamp_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.lastUpdated = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';


CREATE EXTENSION pg_trgm;

CREATE TABLE dbxrefs (
    GENE_ID varchar(255) PRIMARY KEY,
    DATABASE varchar(255),
    DATABASE_GENE_ID varchar(255)
);
CREATE TABLE species (
    SPECIES_ID varchar(255) PRIMARY KEY,
    TRANSCRIPTOME_FASTA varchar(255),
    SPECIES_NAME varchar(255),
    EXPRESSION_FILE varchar(255),
    TAXONOMY_ID int,
    COMMON_NAME varchar(255),
    JBROWSE varchar(255)
);
CREATE TABLE genes (
    GENE_ID varchar(255) PRIMARY KEY,
    SPECIES_ID varchar(255) REFERENCES species,
    SYMBOL varchar(255),
    DESCRIPTION varchar(255)
);
CREATE TABLE orthodescriptions (
    ORTHOLOG_ID varchar(255) PRIMARY KEY,
    SYMBOL varchar(255),
    DESCRIPTION varchar(2024)
);
CREATE TABLE orthologs (
    ORTHOLOG_ID varchar(255) REFERENCES orthodescriptions,
    SPECIES_ID varchar(255) REFERENCES species,
    GENE_ID varchar(255) REFERENCES genes,
    EVIDENCE varchar(255),
    REMOVED BOOLEAN NOT NULL DEFAULT FALSE,
    EDITED BOOLEAN NOT NULL DEFAULT FALSE,
    lastUpdated TIMESTAMP NOT NULL DEFAULT (now() at time zone 'utc')
);
CREATE TABLE transcripts (
    TRANSCRIPT_ID varchar(255),
    GENE_ID varchar(255)
);

COPY species FROM '/Users/cdiesh/data/shinyorthologs/species.csv' CSV HEADER;
COPY genes FROM '/Users/cdiesh/data/shinyorthologs/genes.csv' CSV HEADER DELIMITER E'\t';
COPY orthodescriptions FROM '/Users/cdiesh/data/shinyorthologs/ortho_descriptions.csv' CSV HEADER DELIMITER E'\t';
COPY orthologs (ortholog_ID,species_ID,gene_ID,evidence) FROM '/Users/cdiesh/data/shinyorthologs/orthologs.csv' CSV HEADER;
COPY transcripts FROM '/Users/cdiesh/data/shinyorthologs/transcripts.csv' CSV HEADER;
COPY dbxrefs FROM '/Users/cdiesh/data/shinyorthologs/dbxrefs.csv' CSV HEADER DELIMITER E'\t';




CREATE INDEX description_index ON orthodescriptions USING GIN (to_tsvector('english',description));

CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON orthologs FOR EACH ROW EXECUTE PROCEDURE update_changetimestamp_column();

