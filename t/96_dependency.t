use strict;
use Test::More;
use Test::Dependencies
	exclude => [qw/ List::Enumerator /],
	style   => 'light';

SKIP: {
	skip "CHECK_DEPENDENCY is off." unless $ENV{CHECK_DEPENDENCY};
	ok_dependencies();
};

