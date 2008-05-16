package List::Enumerator;
use Moose;
use Sub::Exporter -setup => { exports => [ "E" ] };

our $VERSION = 0.01;

with "List::Enumerator::Role";

has "next" => (is => 'ro', isa => 'CodeRef');

sub E {
	__PACKAGE__->array(@_);
}

sub array {
	my ($self, @args) = @_;
	my $i = 0;
	$self->new(next => sub {
		die "StopIteration" if $i >= @args;
		$args[$i++];
	});
}



1;
__END__

=head1 NAME

List::Enumerator -

=head1 SYNOPSIS

  use List::Enumerator;

=head1 DESCRIPTION

List::Enumerator is

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
