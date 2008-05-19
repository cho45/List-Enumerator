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

sub push {
	my ($self, @args) = @_;
	push @{$self->array}, @args;
	$self;
}

sub unshift {
	my ($self, @args) = @_;
	unshift @{$self->array}, @args;
	$self;
}

sub shift {
	my ($self) = @_;
	shift @{$self->array};
}

sub pop {
	my ($self) = @_;
	pop @{$self->array};
}

sub join {
	my ($self, $sep) = @_;
	join $sep || "", @{$self->array};
}

__PACKAGE__->meta->make_immutable;

1;
__END__



