CREATE OR REPLACE FUNCTION update_changetimestamp_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.lastUpdated = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';



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
\copy transcripts (gene_id,transcript_id) FROM 'transcripts.csv' CSV HEADER DELIMITER E'\t';
\copy dbxrefs FROM 'dbxrefs.csv' CSV HEADER DELIMITER E'\t';
\copy fasta FROM 'fasta.csv' CSV HEADER DELIMITER E'\t';
\copy expression FROM 'expression.csv' CSV HEADER DELIMITER E'\t' NULL 'NA';

CREATE MATERIALIZED VIEW search_index AS 
SELECT
    o.ortholog_id,
    o.evidence,
    to_tsvector(od.symbol) as symbol,
    to_tsvector(od.description) as description,
    to_tsvector(coalesce(string_agg(g.gene_id, ' '))) as geneids
FROM orthologs o
JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id
JOIN genes g on o.gene_id = g.gene_id 
LEFT JOIN dbxrefs db on o.gene_id = db.gene_id
GROUP BY o.ortholog_id,o.evidence,od.symbol,od.description;

CREATE INDEX idx_fts_search ON search_index USING gin(geneids);
CREATE INDEX idx_fts_description ON search_index USING gin(description);


CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON orthologs FOR EACH ROW EXECUTE PROCEDURE update_changetimestamp_column();

