#!/usr/bin/env perl
$|++;
use XML::Twig;
use strict;
use warnings;

my $cspecies = '';
my $ctaxon = '';

my $twig=XML::Twig->new(   
  start_tag_handlers => {
     species    => sub { $cspecies = $_->{att}->{name}; $ctaxon = $_->{att}->{NCBITaxId};  }
  },
  twig_handlers => {
     gene => sub {
         my $protId = $_->{att}->{protId}||'';
         my $transcriptId = $_->{att}->{transcriptId}||'';
         print "$_->{att}->{id}\t$protId\t$transcriptId\t$cspecies\n";
         $_[0]->purge;
     }
  }
);

$twig->parsefile( $ARGV[0]);
