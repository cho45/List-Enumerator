package List::Enumerator::Role;
use Moose::Role;
use Exception::Class ( "StopIteration" );

requires "next";

sub each {
	my ($self, $block) = @_;
	eval {
		while (1) {
			local $_ = $self->next;
			$block->($_);
		}
	}; if (Exception::Class->caught("StopIteration") ) { }
	$self;
}

sub rewind {
	die "Not implemented.";
}

sub stop {
	StopIteration->throw;
}

1;
__END__



