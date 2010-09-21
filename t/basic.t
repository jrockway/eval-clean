use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Eval::Clean' };
use JSON;

my $perl = Eval::Clean::new_perl();
ok $perl, 'got a new perl';

my $result = Eval::Clean::eval($perl, '{ foo => 42, bar => "baz"  }',
                                      'use JSON; sub { encode_json($_[0]) }');
is $result, '{"bar":"baz","foo":42}', 'it worked';

{
my $libs = Eval::Clean::eval($perl, "use strict; \\%INC", 'use JSON; \\&encode_json');
my $libs_hash = decode_json($libs);
is_deeply [keys %$libs_hash], ['strict.pm'], 'only strict is loaded in first perl';
}

{
Eval::Clean::eval($perl, "package main; our \$GLOBAL = 123;", 'sub {}');
my $global = Eval::Clean::eval($perl, "\$GLOBAL", 'sub { $_[0] }');
is $global, 123, 'state is preserved between perls';
}

Eval::Clean::free_perl($perl);

done_testing;
