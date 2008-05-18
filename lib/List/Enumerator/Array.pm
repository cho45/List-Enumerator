package List::Enumerator::Array;
use Moose;
use overload
	'@{}' => \&to_a;

with "List::Enumerator::Role";

has "array" => ( is => "ro", isa => "ArrayRef", default => sub { [] } );
has "index" => ( is => "rw", isa => "Int", default => sub { 0 } );

sub next {
	my ($self) = @_;

	$self->stop if $self->index >= @{$self->array};

	$self->index($self->index + 1);
	$self->array->[$self->index - 1];
}

sub rewind {
	my ($self) = @_;

	$self->index(0);
	$self;
}

sub to_a {
	my ($self) = @_;
	$self->array;
}


__PACKAGE__->meta->make_immutable;

1;
__END__



