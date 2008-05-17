package List::Enumerator::Test;
use strict;
use warnings;
use base qw/Test::Class/;
use Test::More;

use lib "lib";
use List::Enumerator qw/E/;
use List::Enumerator::Array;
use List::Enumerator::Sub;


sub test_each : Test(4) {
	my $result = [];

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
}


sub test_sub_basic : Test(2) {
	my $list;

	$list = List::Enumerator::Sub->new(
		next => sub {
			156
		},
		rewind => sub {
		}
	);

	is $list->next, 156;

	$list = E({
		next => sub {
			156
		}
	});
	is $list->next, 156;
}


sub test_to_a : Test(2) {
	is_deeply E(1, 2, 3)->to_a, [1, 2, 3];
	is_deeply [ E(1, 2, 3)->to_a ], [ [1, 2, 3] ];
}


sub test_map : Test(4) {
	my $list;

	$list = E(1, 2, 3)->map(sub { $_ * $_ });
	is_deeply $list->to_a, [1, 4, 9];
	is_deeply $list->to_a, [1, 4, 9];

	$list = E(1, 2, 3);
	is_deeply [ $list->map(sub { $_ * $_ }) ], [1, 4, 9];
	is_deeply [ $list->map(sub { $_ * $_ }) ], [1, 4, 9];
}

sub test_dup : Test(2) {
	my $list = E(1, 2, 3);

	is $list->dup->next, 1;
	is $list->next, 1;
}



sub test_cycle : Test(9) {
	my $list = E(1, 2, 3)->cycle;
	is $list->next, 1;
	is $list->next, 2;
	is $list->next, 3;
	is $list->next, 1;
	is $list->next, 2;
	is $list->next, 3;
	is $list->next, 1;
	is $list->next, 2;
	is $list->next, 3;
}


sub test_countup : Test(10) {
	my $list = E()->countup;
	is $list->next, 0;
	is $list->next, 1;
	is $list->next, 2;
	is $list->next, 3;
	is $list->rewind->next, 0;
	is $list->next, 1;
	is $list->next, 2;
	is $list->next, 3;

	is_deeply E(1)->to(5)->to_a, [1, 2, 3, 4, 5];
	is_deeply E(5)->to(5)->to_a, [5];
}

sub test_take : Test(5) {
	is_deeply E(1, 2, 3, 4, 5)->take(3)->to_a, [1, 2, 3];

	is_deeply [ E(1, 2, 3)->cycle->take(5) ], [1, 2, 3, 1, 2];
	is_deeply [ E(1)->countup->take(5) ], [1, 2, 3, 4, 5];

	is_deeply [ E(1)->countup->take(sub { $_ <= 5 }) ], [1, 2, 3, 4, 5];
	is_deeply [ E(1)->countup->take_while(sub { $_ * $_ <= 9 }) ], [1, 2, 3];
}

sub test_drop : Test(4) {
	is_deeply [ E(1, 2, 3)->drop(1) ], [2, 3];
	is_deeply [ E()->countup->drop(3)->take(5) ], [3, 4, 5, 6, 7];
	is_deeply [ E()->countup->drop(sub { $_ * $_ <= 9 })->take(5) ], [4, 5, 6, 7, 8];
	is_deeply [ E()->countup->drop(sub { $_ * $_ <= 9 })->take(5)->drop(3) ], [7, 8];
}


sub test_zip : Test(1) {
	is_deeply [ E(1, 2, 3, 4, 5)->zip(E()->countup, [qw/a b c/]) ], [ [1, 0, "a"], [2, 1, "b"], [3, 2, "c"] ];
}


sub test_with_index : Test(1) {
	my $result = [];
	E("a", "b", "c")->with_index->each(sub {
		my ($item, $index) = @_;
		push @$result, $item, $index;
	});
	is_deeply $result, [qw/a 0 b 1 c 2/];
}

sub test_select : Test(1) {
}

#sub test_reduce : Test(1) {
#	is E(1, 2, 3)->reduce(sub { $a + $b }), 6;
#	is_deeply E(1, 2, 3)->zip(qw/a b c/)->reduce(sub {
#		my ($r, $n, $c) = @_;
#		$r->{$c} = $n;
#	}, {}), {
#		a => 1,
#		b => 2,
#		c => 3,
#	};
#}

sub test_find : Test {
}

sub test_max : Test {
}

sub test_min : Test {
}

sub test_chain : Test {
}

sub test_act_as_arrayref : Test(2) {
	my $list;

	$list = E(1, 2, 3);
	is $list->[0], 1;

	$list = E(1, 2, 3)->cycle;
	is $list->[3], 1;
}


__PACKAGE__->runtests;

