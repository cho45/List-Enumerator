package List::Enumerator::Role;
use Moose::Role;
use Exception::Class ( "StopIteration" );

requires "next";

sub map {
	my ($self, $block) = @_;
	my $ret = List::Enumerator::Sub->new({
		next => sub {
			local $_ = $self->next;
			$block->($_);
		}
	});
	wantarray? $ret->to_a : $ret;
}

sub each {
	my ($self, $block) = @_;
	my @ret;
	eval {
		while (1) {
			local $_ = $self->next;
			push @ret, $_;
			$block->($_) if $block;
		}
	}; if (Exception::Class->caught("StopIteration") ) { } else
	{
		my $e = Exception::Class->caught();
		ref $e ? $e->rethrow : die $e;
	}

	wantarray? @ret : $self;
}

*to_a = \&each;

sub rewind {
	die "Not implemented.";
}

sub stop {
	my ($self) = @_;
	eval { $self->rewind };
	StopIteration->throw;
}

1;
__END__



