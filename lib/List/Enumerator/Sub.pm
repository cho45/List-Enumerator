package List::Enumerator::Sub;
use Moose;

with "List::Enumerator::Role";

has "next_sub"   => ( is => "rw", isa => "CodeRef" );
has "rewind_sub" => ( is => "rw", isa => "CodeRef" );

sub BUILD {
	my ($self, $params) = @_;

	$self->next_sub($params->{next});
	$self->rewind_sub($params->{rewind}) if $params->{rewind};
}

sub next {
	my ($self, $new) = @_;

	if ($new) {
		$self->next_sub($new);
		$self;
	} else {
		local $_ = $self;
		$self->next_sub->($self);
	}
}

sub rewind {
	my ($self, $new) = @_;

	if ($new) {
		$self->rewind_subb($new);
		$self;
	} else {
		if ($self->rewind_sub) {
			$self->rewind_sub->();
			$self;
		} else {
			die "Not Implemented";
		}
	}
}


__PACKAGE__->meta->make_immutable;

1;
__END__
