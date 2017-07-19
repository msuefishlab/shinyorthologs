#!/usr/bin/env bash


Rscript -e "library(reshape2); tab=read.table('$1',header=T); write.table(melt(tab,id.vars='gene_id'), stdout(), quote=F, col.names=F, row.names=F, sep='\t');"
