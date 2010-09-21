package Eval::Clean;
# ABSTRACT: run code in a pristine perl interpreter and inspect the results in another
use strict;
use warnings;
use XSLoader;

our $VERSION;

XSLoader::load 'Eval::Clean', $Eval::Clean::VERSION;

1;
