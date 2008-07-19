use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic Moose::Role List::Enumerator/],
	style   => 'light';
ok_dependencies();
