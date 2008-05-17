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

  use List::Enumerator qw/E/;

  my $fizzbuzz =
      E(1)->countup->zip(
          E("", "", "Fizz")->cycle,
          E("", "", "", "", "Buzz")->cycle
      )->map(sub {
          my ($n, $fizz, $buzz) = @$_;
          $fizz . $buzz || $n;
      });
  
  $fizzbuzz->take(20)->each(sub {
      print $_, "\n";
  });


=head1 DESCRIPTION

List::Enumerator is list library like Enumerator of Ruby.

=head2 Concept

=over

=item * Lazy evaluation for infinite list (ex. cycle)
=item * Read the Context
=item * Applicable (implemented as Moose::Role).

=back

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

L<List::RubyLike>, L<http://coderepos.org/share/wiki/JSEnumerator>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
