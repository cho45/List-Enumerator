package List::Enumerator;
use Moose;
use Sub::Exporter -setup => { exports => [ "E" ] };

use List::Enumerator::Array;
use List::Enumerator::Sub;

our $VERSION = 0.01;

sub E {
	my (@args) = @_;
	if (ref($args[0]) eq "HASH") {
		List::Enumerator::Sub->new($args[0]);
	} elsif (ref($args[0]) eq "ARRAY") {
		List::Enumerator::Array->new(array => $args[0]);
	} elsif (ref($args[0]) =~ /^List::Enumerator/) {
		$args[0];
	} else {
		List::Enumerator::Array->new(array => \@args);
	}
}


1;
__END__

=head1 NAME

List::Enumerator -

=head1 SYNOPSIS

  use List::Enumerator;
  List::Enumerator::Array;
  List::Enumerator::Sub;

=head1 DESCRIPTION

List::Enumerator is list library like Enumerator of Ruby.

=head2 Concept

=over
=item * Lazy evaluation for inifinate list (ex. cycle)
=item * Read the Context
=item * Applicatable (implemented as Moose::Role).
=back

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
