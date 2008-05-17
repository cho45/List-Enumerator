use strict;
use Test::More qw/no_plan/;

use lib "lib";
use List::Enumerator qw/E/;
use List::Enumerator::Array;
use List::Enumerator::Sub;

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

my $list = List::Enumerator::Sub->new(
	next => sub {
		156
	},
	rewind => sub {
	}
);

is $list->next, 156;

my $list = E({
	next => sub {
		156
	}
});
is $list->next, 156;


$list = E(1, 2, 3)->map(sub { $_ * $_ });
is_deeply $list->to_a, [1, 4, 9];
is_deeply $list->to_a, [1, 4, 9];

$list = E(1, 2, 3);
is_deeply [ $list->map(sub { $_ * $_ }) ], [1, 4, 9];
is_deeply [ $list->map(sub { $_ * $_ }) ], [1, 4, 9];

$list = E(1, 2, 3);

is $list->dup->next, 1;
is $list->next, 1;


is_deeply E(1, 2, 3)->to_a, [1, 2, 3];
is_deeply [ E(1, 2, 3)->to_a ], [ [1, 2, 3] ];


## --- TODO : 分割


# cycle
$list = E(1, 2, 3)->cycle;
is $list->next, 1;
is $list->next, 2;
is $list->next, 3;
is $list->next, 1;
is $list->next, 2;
is $list->next, 3;
is $list->next, 1;
is $list->next, 2;
is $list->next, 3;


# countup / countup / to
$list = E()->countup;
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

# take
is_deeply E(1, 2, 3, 4, 5)->take(3)->to_a, [1, 2, 3];

is_deeply [ E(1, 2, 3)->cycle->take(5) ], [1, 2, 3, 1, 2];
is_deeply [ E(1)->countup->take(5) ], [1, 2, 3, 4, 5];

is_deeply [ E(1)->countup->take(sub { $_ <= 5 }) ], [1, 2, 3, 4, 5];
is_deeply [ E(1)->countup->take_while(sub { $_ * $_ <= 9 }) ], [1, 2, 3];

# drop
is_deeply [ E(1, 2, 3)->drop(1) ], [2, 3];
is_deeply [ E()->countup->drop(3)->take(5) ], [3, 4, 5, 6, 7];
is_deeply [ E()->countup->drop(sub { $_ * $_ <= 9 })->take(5) ], [4, 5, 6, 7, 8];
is_deeply [ E()->countup->drop(sub { $_ * $_ <= 9 })->take(5)->drop(3) ], [7, 8];


# zip
is_deeply [ E(1, 2, 3, 4, 5)->zip(E()->countup, [qw/a b c/]) ], [ [1, 0, "a"], [2, 1, "b"], [3, 2, "c"] ];

# with_index


$result = [];
E("a", "b", "c")->with_index->each(sub {
	my ($item, $index) = @_;
	push @$result, $item, $index;
});
is_deeply $result, [qw/a 0 b 1 c 2/];

1;
