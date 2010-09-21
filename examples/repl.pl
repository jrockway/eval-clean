#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Eval::Clean;

use Term::ReadLine;
use Data::Dump::Streamer;

my $term = Term::ReadLine->new(*STDIN);
my $perl = Eval::Clean::new_perl();

while(my $line = $term->readline('PERL> ')){
    eval {
        my $code = "my \$code = sub { $line }; [eval { +{ result => scalar \$code->()} } || { error => \$@ }, \$code]";
        my $show = 'use Data::Dump::Streamer; sub { Dump($_[0])->Out }';
        my $output = Eval::Clean::eval($perl, $code, $show);

        my $results = eval $output or die;
        say Dump($results);
    };
    if($@){
        say "error: $@";
    }
}

Eval::Clean::free_perl($perl);
