#!/usr/bin/env bash


samtools faidx $1
cat $1.fai | cut -f1 | while read p; do
    samtools faidx $1 $p | 
        awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print $0}'
done;
