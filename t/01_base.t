use strict;
use Test::More tests => 1;

use List::Enumerator qw/E/;
use Data::Dumper;

sub p ($) { warn Dumper shift }

my $result = [];

E(1, 2, 3)->each(sub {
	push @$result, $_;
});

is_deeply $result, [1, 2, 3];
