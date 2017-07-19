#!/usr/bin/env perl
use Bio::SeqIO;
my $seqio = Bio::SeqIO->new(-file => $ARGV[0], '-format' => 'Fasta');
while(my $seq = $seqio->next_seq) {
    print $seq->id, "\t", $seq->seq, "\n";
}
