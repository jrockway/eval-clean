use inc::Module::Install;
use strict;

all_from 'lib/Eval/Clean.pm';
libs '-lperl';
WriteAll;
