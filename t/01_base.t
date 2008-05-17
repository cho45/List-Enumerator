use strict;
use Test::More tests => 6;

use List::Enumerator qw/E/;
use List::Enumerator::Array;
use List::Enumerator::Sub;
use Data::Dumper;

sub p ($) { warn Dumper shift }

my $result;

$result = [];
E(1, 2, 3)->each(sub {
	push @$result, $_;
});
is_deeply $result, [1, 2, 3];


$result = [];
my $array_enum = E(1, 2, 3);
$array_enum->each(sub {
	push @$result, $_;
});
is_deeply $result, [1, 2, 3];

$result = [];
$array_enum->each(sub {
	push @$result, $_;
});
is_deeply $result, [1, 2, 3];


is_deeply [ E(1, 2, 3)->each ], [1, 2, 3];
is_deeply [ E(1, 2, 3)->to_a ], [1, 2, 3];


my $list = List::Enumerator::Sub->new(
	next => sub {
		rand;
	},
	rewind => sub {
	}
);

ok $list->next;
