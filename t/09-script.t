#!perl

use Test::More tests => 13;

use strict;
use warnings;

use JSPL;
require JSPL::SM::ByteCode;

# Create a new runtime
my $rt1 = JSPL::Runtime->new();
my $cx1 = $rt1->create_context();

# Compile a script
my $script = $cx1->compile(q!
  var v = Math.random(10);
  v + 1;
!);

isa_ok($script, "JSPL::Script", "Compile returns object");

#Developer's sanity tests
my $prolog = JSPL::SM::ByteCode->prolog($script);
while(my @opd = $prolog->decode) {
    my $op = $opd[0]->id;
    next if $op eq 'JSOP_TRACE';
    is($op, 'JSOP_DEFVAR', "Prolog ok");
    is($opd[1], 'v', "Declares v");
}

# Run the script
for(1 .. 10) {
    ok($script->exec > 0, "Ok pass $_");
}
