#!perl

use Test::More tests => 13;

use strict;
use warnings;

use JSPL;

# Create a new runtime
my $rt1 = JSPL::Runtime->new();
my $cx1 = $rt1->create_context();

# Compile a script
my $script = $cx1->compile(q!
  var myvar1 = Math.random(10);
  myvar1 + 1;
!);

isa_ok($script, "JSPL::Script", "Compile returns Script object");

#Developer's sanity tests
SKIP: {
    skip "Perl > 5.9 needed for SM::ByteCode", 2, unless $] > 5.009; 
    skip "Incomplete porting", 2, unless defined &JSPL::Script::jss_prolog;
    require JSPL::SM::ByteCode;
    my $prolog = JSPL::SM::ByteCode->prolog($script);
    while(my @opd = $prolog->decode) {
	my $op = $opd[0]->id;
	next if $op eq 'JSOP_TRACE';
	is($op, 'JSOP_DEFVAR', "Prolog ok");
	is($opd[1], 'myvar1', "Declares myvar1");
    }
}

# Run the script
for(1 .. 10) {
    ok($script->exec > 0, "Ok pass $_");
}
