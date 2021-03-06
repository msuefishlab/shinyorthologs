CREATE OR REPLACE FUNCTION update_changetimestamp_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.lastUpdated = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TABLE evidence (
    EVIDENCE_ID varchar(255) PRIMARY KEY,
    LINK varchar(1024),
    TITLE varchar(1024)
);

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
    EVIDENCE varchar(255) REFERENCES evidence,
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
\copy evidence FROM 'evidence.csv' CSV HEADER DELIMITER E'\t';
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
    setweight(to_tsvector(o.ortholog_id), 'C') ||
    setweight(to_tsvector(coalesce(od.symbol,'')), 'A') ||
    setweight(to_tsvector(coalesce(od.description,'')), 'A') ||
    setweight(to_tsvector(coalesce(db.database_gene_id,'')), 'A') ||
    setweight(to_tsvector(coalesce(string_agg(g.gene_id, ' '))), 'C') as document
FROM orthologs o
JOIN orthodescriptions od on o.ortholog_id = od.ortholog_id
JOIN genes g on o.gene_id = g.gene_id 
LEFT JOIN dbxrefs db on o.gene_id = db.gene_id
GROUP BY o.ortholog_id, o.gene_id, od.symbol, od.description, db.database_gene_id;

CREATE INDEX idx_fts_search ON search_index USING gin(document);

CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON orthologs FOR EACH ROW EXECUTE PROCEDURE update_changetimestamp_column();

