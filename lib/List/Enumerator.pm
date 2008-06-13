package List::Enumerator;
use Moose;
use Sub::Exporter -setup => { exports => [ "E" ] };

use List::Enumerator::Array;
use List::Enumerator::Sub;

our $VERSION = "0.02";

sub E {
	my (@args) = @_;
	if (ref($args[0]) eq "ARRAY") {
		List::Enumerator::Array->new(array => $args[0]);
	} elsif (ref($args[0]) eq "HASH") {
		List::Enumerator::Sub->new($args[0]);
	} elsif (ref($args[0]) =~ /^List::Enumerator/) {
		$args[0];
	} else {
		List::Enumerator::Array->new(array => \@args);
	}
}


1;
__END__

=head1 NAME

List::Enumerator - list construct library

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

List::Enumerator::E is interface wrapper for generating List::Enumerator::Array or List::Enumerator::Sub.

Most methods (except what returns always infinite list) consider caller context. ex:

  E(1, 2, 3, 4, 5)->take(3);     #=> new List::Enumerator::Sub
  [ E(1, 2, 3, 4, 5)->take(3) ]; #=> [1, 2, 3]

=over

=item E(list), E([arrayref])

Returns List::Enumerator::Array.

=item E({ next => sub {}, rewind => sub {} })

Returns List::Enumerator::Sub. ex:

  use List::Enumerator qw/E/;

  sub fibonacci {
      my ($p, $i);
      E(0, 1)->chain(E({
          next => sub {
              my $ret = $p + $i;
              $p = $i;
              $i = $ret;
              $ret;
          },
          rewind => sub {
              ($p, $i) = (0, 1);
          }
      }))->rewind;
  }

  [ fibonacci->take(10) ];           #=> [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34 ];
  [ fibonacci->drop(10)->take(10) ]; #=> [ 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181 ];


=back


=head2 Concept

=over

=item * Lazy evaluation for infinite list (ex. cycle)

=item * Method chain

=item * Read the context

=item * Applicable (implemented as Moose::Role)

=back


=head1 DEVELOPMENT

This module is developing on github L<http://github.com/cho45/list-enumerator/tree/master>.


=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

L<List::RubyLike>, L<http://coderepos.org/share/wiki/JSEnumerator>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
