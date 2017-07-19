#!/usr/bin/env bash

# convert fasta to tab
rm -f fasta.csv;
for i in fasta/*.fa; do
    ./load_fasta.sh $i >> fasta.csv;
done;

rm -f expression.csv;
for i in expression/*.csv; do
    ./load_expression.sh $i >> expression.csv;
done;


# load tables
psql -d $1 < create.sql;
