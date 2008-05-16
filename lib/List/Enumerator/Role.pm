package List::Enumerator::Role;
use Moose::Role;

sub each {
	my ($self, $block) = @_;
	eval {
		while (1) {
			local $_ = $self->next->();
			$block->($_);
		}
	}; if ($@) {
		die $@ unless $@ ne "StopIteration";
	}
	$self;
}

1;
__END__



