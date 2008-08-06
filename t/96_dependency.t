use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic Class::Accessor::Fast List::Enumerator/],
	style   => 'light';
ok_dependencies();
