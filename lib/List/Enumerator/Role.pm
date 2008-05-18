package List::Enumerator::Role;
use Moose::Role;
use Exception::Class ( "StopIteration" );

use List::Util;
use List::MoreUtils;

requires "next";

sub select {
	my ($self, $block) = @_;
	List::Enumerator::Sub->new(
		next => sub {
			local $_;
			do {
				$_ = $self->next;
			} while ($block->($_));
			$_;
		},
		rewind => sub {
			$self->rewind;
		}
	)->rewind;
}
*find_all = \&select;

sub reduce {
	my ($self, $result, $block) = @_;
	no strict 'refs';

	if (@_ == 2) {
		$block  = $result;
		$result = undef;
	};

	my $caller = caller;
	local *{$caller."::a"} = \my $a;
	local *{$caller."::b"} = \my $b;

	my @list = $self->to_list;
	unshift @list, $result if defined $result;

	$a = shift @list;
	for (@list) {
		$b = $_;
		$a = $block->($a, $b);
	};

	$a;
}
*inject = \&reduce;

sub find {
	my ($self, $block) = @_;
	my $ret;
	$self->each(sub {
		if ($block->($self)) {
			$ret = $_;
			$self->stop;
		}
	});
	$ret;
}

sub first {
	my ($self) = @_;
	$self->rewind;
	my $ret = $self->next;
	$self->rewind;
	$ret;
}

sub last {
	my ($self) = @_;
	my $ret = $self->to_a;
	$ret->[@$ret - 1];
}

sub max {
	my ($self, $block) = @_;
	List::Util::max $self->to_list;
}

sub max_by {
	my ($self, $block) = @_;
	$self->sort_by($block)->last;
}

sub min {
	my ($self, $block) = @_;
	List::Util::min $self->to_list;
}

sub min_by {
	my ($self, $block) = @_;
	$self->sort_by($block)->first;
}

sub sort_by {
	my ($self, $block) = @_;
	List::Enumerator::E(
		map {
			$_->[0];
		}
		sort {
			$a->[1] <=> $b->[1];
		}
		map {
			[$_, $block->($_)];
		}
		$self->to_list
	);
}

sub chain {
	my ($self, @others) = @_;
	my ($elements, $current);
	my $ret = List::Enumerator::Sub->new(
		next => sub {
			my $ret;
			eval {
				$ret = $current->next;
			}; if (Exception::Class->caught("StopIteration") ) {
				$current = $elements->next;
				$ret = $current->next;
			} else {
				my $e = Exception::Class->caught();
				ref $e ? $e->rethrow : die $e if $e;
			}
			$ret;
		},
		rewind => sub {
			$elements = List::Enumerator::E([
				map {
					List::Enumerator::E($_)->rewind;
				}
				$self, @others
			]);

			$current = $elements->next;
		}
	)->rewind;

	wantarray? $ret->to_list : $ret;
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
		)->rewind;
	} else {
		my $i;
		$ret = List::Enumerator::Sub->new(
			next => sub {
				if ($i++ < $arg) {
					$self->next;
				} else {
					StopIteration->throw;
				}
			},
			rewind => sub {
				$self->rewind;
				$i = 0;
			}
		)->rewind;
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
		)->rewind;
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
		)->rewind;
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
	my $elements;
	my $ret = List::Enumerator::Sub->new(
		next => sub {
			my $ret = [];
			for (@$elements) {
				push @$ret, $_->next;
			}
			$ret;
		},
		rewind => sub {
			$elements = [
				map {
					List::Enumerator::E($_);
				}
				$self, @others
			];
		}
	)->rewind;

	wantarray? $ret->to_list : $ret;
}

sub with_index {
	my ($self, $start) = @_;
	$self->zip(List::Enumerator::E($start)->countup);
}

sub countup {
	my ($self, $lim) = @_;
	my $i;
	List::Enumerator::Sub->new({
		next => sub {
			($lim && $i > $lim) && StopIteration->throw;
			$i++;
		},
		rewind => sub {
			$self->rewind;
			$i = eval { $self->next } || 0;
		}
	})->rewind;
}
*countup_to = \&countup;
*to = \&countup;


sub cycle {
	my ($self) = @_;
	my @cache;
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
	})->rewind;
}

sub map {
	my ($self, $block) = @_;
	my $ret = List::Enumerator::Sub->new({
		next => sub {
			local $_ = $self->next;
			$block->($_);
		},
		rewind => sub {
			$self->rewind;
		}
	});
	wantarray? $ret->to_list : $ret;
}

sub each {
	my ($self, $block) = @_;
	$self->rewind;

	my @ret;
	eval {
		while (1) {
			local $_ = $self->next;
			push @ret, $_;
			$block->($_) if $block;
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



