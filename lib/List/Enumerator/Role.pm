package List::Enumerator::Role;
use Moose::Role;
use Exception::Class ( "StopIteration" );

requires "next";

sub select {
}
*find_all = \&select;

sub reduce {
}
*inject = \&reduce;

sub find {
}

sub max {
}

sub min {
}

sub chain {
}

sub take {
	my ($self, $arg) = @_;
	my $ret;
	if (ref $arg eq "CODE") {
		$ret = List::Enumerator::Sub->new(
			next => sub {
				local $_ = $self->next;
				if ($arg->($_)) {
					$_;
				} else {
					StopIteration->throw;
				}
			},
			rewind => sub {
				$self->rewind;
			}
		);
	} else {
		my $i = 0;
		$ret = List::Enumerator::Sub->new(
			next => sub {
				if ($i++ < $arg) {
					$self->next;
				} else {
					StopIteration->throw;
				}
			},
			rewind => sub {
				$i = 0;
				$self->rewind;
			}
		);
	}
	wantarray? $ret->to_list : $ret;
}
*take_while = \&take;

sub drop {
	my ($self, $arg) = @_;
	my $ret;
	if (ref $arg eq "CODE") {
		my $first;
		$ret = List::Enumerator::Sub->new(
			next => sub {
				my $ret = $first || $self->next;
				$first = undef if $first;
				$ret;
			},
			rewind => sub {
				$self->rewind;
				do {
					$first = $self->next;
				} while ($arg->(local $_ = $first));
			}
		);
		$ret->rewind;
	} else {
		$ret = List::Enumerator::Sub->new(
			next => sub {
				$self->next;
			},
			rewind => sub {
				my $i = $arg;
				$self->rewind;
				$self->next while ($i--);
			}
		);
		$ret->rewind;
	}
	wantarray? $ret->to_list : $ret;
}
*drop_while = \&drop_while;

sub every {
}
*all = \&every;

sub some {
}
*any = \&some;

sub zip {
	my ($self, @others) = @_;
	my $elements = [
		map {
			List::Enumerator::E($_);
		}
		$self, @others
	];

	my $ret = List::Enumerator::Sub->new(
		next => sub {
			my @ret = ();
			for (@$elements) {
				push @ret, $_->next;
			}
			@ret;
		},
		rewind => sub {
			$elements = [
				map {
					List::Enumerator::E($_);
				}
				$self, @others
			];
		}
	);

	wantarray? $ret->map(sub { [ @_ ] })->to_list : $ret;
}

sub with_index {
	my ($self, $start) = @_;
	$self->zip(List::Enumerator::E($start)->countup);
}

sub countup {
	my ($self, $lim) = @_;
	my $start = eval { $self->next } || 0;
	my $i = $start;
	List::Enumerator::Sub->new({
		next => sub {
			($lim && $i > $lim) && StopIteration->throw;
			$i++;
		},
		rewind => sub {
			$self->rewind;
			$i = eval { $self->next } || 0;
		}
	});
}
*countup_to = \&countup;
*to = \&countup;


sub cycle {
	my ($self) = @_;
	my @cache = ();
	List::Enumerator::Sub->new({
		next => sub {
			my ($this) = @_;

			my $ret;
			eval {
				$ret = $self->next;
				push @cache, $ret;
			}; if (Exception::Class->caught("StopIteration") ) {
				my $i = -1;
				$this->next(sub {
					$cache[++$i % @cache];
				});
				$ret = $this->next;
			} else {
				my $e = Exception::Class->caught();
				ref $e ? $e->rethrow : die $e if $e;
			}
			$ret;
		},
		rewind => sub {
			$self->rewind;
			@cache = ();
		}
	});
}

sub map {
	my ($self, $block) = @_;
	my $ret = List::Enumerator::Sub->new({
		next => sub {
			my @item = $self->next;
			local $_ = $item[0];
			$block->(@item);
		},
		rewind => sub {
			$self->rewind;
		}
	});
	wantarray? $ret->to_list : $ret;
}

sub each {
	my ($self, $block) = @_;
	my @ret;
	eval {
		while (1) {
			my @item = $self->next;
			local $_ = $item[0];
			push @ret, $_;
			$block->(@item) if $block;
		}
	}; if (Exception::Class->caught("StopIteration") ) { } else {
		my $e = Exception::Class->caught();
		ref $e ? $e->rethrow : die $e if $e;
	}

	wantarray? @ret : $self;
}

*to_list = \&each;

sub to_a {
	my ($self) = @_;
	[ $self->each ];
}

sub dup {
	my ($self) = @_;
	List::Enumerator::Array->new(array => $self->to_a);
}

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



