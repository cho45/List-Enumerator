#!/usr/bin/perl

use strict;
use warnings;


use lib 'lib';
use List::Enumerator qw/E/;

use List::Util;
use List::MoreUtils;

use autobox;
use autobox::Core;

use List::oo qw/L/;

use Perl6::Say;
use Benchmark qw/:all/;


say "Simple Loop:";
cmpthese(10000, {
	'List::Enumerator' => sub {
		my $list = [1..100];
		E($list)->each(sub {
		});
	},
	'List::oo' => sub {
		my $list = [1..100];
		L(@$list)->map(sub {
		});
	},
	'autobox::Core' => sub {
		my $list = [1..100];
		$list->each(sub {
		});
	},
	'for' => sub {
		my $list = [1..100];
		for (@$list) {
		}
	}
});

say;

say "Simple Loop (exclude object construction):";
my $list_enumerator = E(1..100);
my $list_oo         = L(1..100);
my $list            = [1..100];
cmpthese(10000, {
	'List::Enumerator' => sub {
		$list_enumerator->each(sub {
		});
	},
	'List::oo' => sub {
		$list_oo->map(sub {
		});
	},
	'autobox::Core' => sub {
		$list->each(sub {
		});
	},
	'for' => sub {
		for (@$list) {
		}
	}
});

say;

say "Map:";
cmpthese(10000, {
	'List::Enumerator' => sub {
		my $list = [1..100];
		[ E($list)->map(sub {
			$_ * $_;
		}) ];
	},
	'List::oo' => sub {
		my $list = [1..100];
		L(@$list)->map(sub {
			$_ * $_;
		});
	},
	'autobox::Core' => sub {
		my $list = [1..100];
		$list->map(sub {
			$_ * $_;
		});
	},
	'for' => sub {
		my $list = [1..100];
		my $ret = [];
		for (@$list) {
			push @$ret, $_ * $_;
		}
	},
});
