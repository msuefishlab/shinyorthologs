#!/usr/bin/env bash

# convert fasta to tab
rm -f fasta.csv;
for i in fasta/*.fa fasta/*.fasta; do
    echo $i;
    ./load_fasta.pl $i >> fasta.csv;
done;

rm -f expression.csv;
for i in expression/*.csv; do
    echo $i;
    ./load_expression.sh $i >> expression.csv;
done;


# load tables
psql -d $1 < create.sql;
