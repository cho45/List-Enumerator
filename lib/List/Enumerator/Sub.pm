package List::Enumerator::Sub;
use Moose;
use overload
	'@{}' => \&getarray;

with "List::Enumerator::Role";

has "next_sub"   => ( is => "rw", isa => "CodeRef" );
has "rewind_sub" => ( is => "rw", isa => "CodeRef", default => sub { sub {} });

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
		$self->rewind_sub($new);
		$self;
	} else {
		local $_ = $self;
		$self->rewind_sub->();
		$self;
	}
}

sub getarray {
	my ($self) = @_;
	my @temp;
	tie @temp, __PACKAGE__, $self;
	\@temp;
}

sub TIEARRAY {
	my ($class, $arg) = @_;
	bless $arg, $class;
}

sub FETCHSIZE {
	0;
}

sub FETCH { #TODO orz orz orz
	my ($self, $index) = @_;
	$self->rewind;
	$self->next while ($index--);
	$self->next;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
