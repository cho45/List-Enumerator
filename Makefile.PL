use inc::Module::Install;
name 'List-Enumerator';
all_from 'lib/List/Enumerator.pm';

requires $_ for (qw/List::Util List::MoreUtils Exception::Class Sub::Exporter/);

build_requires 'Test::More';
build_requires 'Test::Class';
use_test_base;
auto_include;
WriteAll;
