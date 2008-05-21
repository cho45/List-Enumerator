package List::Enumerator::Array;
use Moose;
use overload
	'@{}' => \&to_a,
	fallback => 1;

with "List::Enumerator::Role";

has "array" => ( is => "ro", isa => "ArrayRef", default => sub { [] } );
has "index" => ( is => "rw", isa => "Int", default => sub { 0 } );

sub next {
	my ($self) = @_;

	my $i = $self->index;

	if ($i < @{$self->array}) {
		$self->index($i + 1);
		$self->array->[$i];
	} else {
		$self->stop;
	}
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

sub to_list {
	my ($self) = @_;
	@{$self->array};
}

sub push {
	my ($self, @args) = @_;
	CORE::push @{$self->array}, @args;
	$self;
}

sub unshift {
	my ($self, @args) = @_;
	CORE::unshift @{$self->array}, @args;
	$self;
}

sub prepend {
	my ($self, $args) = @_;
	CORE::unshift @{$self->array}, @$args;
	$self;
}

sub concat {
	my ($self, $args) = @_;
	CORE::push @{$self->array}, @$args;
	$self;
}
*append = \&concat;

sub shift {
	my ($self) = @_;
	CORE::shift @{$self->array};
}

sub pop {
	my ($self) = @_;
	CORE::pop @{$self->array};
}

__PACKAGE__->meta->make_immutable;

1;
__END__



