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