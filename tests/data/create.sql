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
    TRANSCRIPT_ID varchar(255) PRIMARY KEY,
    GENE_ID varchar(255)
);

CREATE TABLE fasta (
    TRANSCRIPT_ID varchar(255) REFERENCES transcripts,
    SEQUENCE varchar(200000)
);

CREATE TABLE expression (
    GENE_ID varchar(255) REFERENCES genes,
    TISSUE varchar(255),
    VALUE double precision
);


\copy species FROM 'species.csv' CSV HEADER DELIMITER E'\t';
\copy genes FROM 'genes.csv' CSV HEADER DELIMITER E'\t';
\copy orthodescriptions FROM 'ortho_descriptions.csv' CSV HEADER DELIMITER E'\t';
\copy orthologs (ortholog_ID,species_ID,gene_ID,evidence) FROM 'orthologs.csv' CSV HEADER DELIMITER E'\t';
\copy transcripts FROM 'transcripts.csv' CSV HEADER DELIMITER E'\t';
\copy dbxrefs FROM 'dbxrefs.csv' CSV HEADER DELIMITER E'\t';
\copy fasta FROM 'fasta.csv' CSV HEADER DELIMITER E'\t';
\copy expression FROM 'expression.csv' CSV HEADER DELIMITER E'\t';



CREATE INDEX description_index ON orthodescriptions USING GIN (to_tsvector('english',description));

CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON orthologs FOR EACH ROW EXECUTE PROCEDURE update_changetimestamp_column();

