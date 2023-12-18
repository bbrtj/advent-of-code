package Day18::Trench;

use class;

has field 'borders' => (
	default => sub { {} },
);

has field 'sides' => (
	default => sub { [] },
);

has field '_sides_chunked' => (
	lazy => 1,
);

sub _spawn_chunk ($self, $y1, $y2, @sides)
{
	return {
		y1 => $y1,
		y2 => $y2,
		sides => \@sides,
	};
}

sub _subdivide_chunk ($self, $chunk, $side)
{
	my @out;

	if ($side->{y1} > $chunk->{y1}) {
		push @out, $self->_spawn_chunk($chunk->{y1}, $side->{y1} - 1, $chunk->{sides}->@*);
		$chunk->{y1} = $side->{y1};
	}

	if ($side->{y2} < $chunk->{y2}) {
		push @out, $self->_spawn_chunk($side->{y2} + 1, $chunk->{y2}, $chunk->{sides}->@*);
		$chunk->{y2} = $side->{y2};
	}

	push $chunk->{sides}->@*, $side;
	return @out;
}

sub _build_sides_chunked ($self)
{
	my @sorted = sort {
		$a->{x} <=> $b->{x};
	} $self->sides->@*;

	my @chunked;

	foreach my ($y, $sides_x) ($self->borders->%*) {
		my $chunk = $self->_spawn_chunk($y, $y);
		$chunk->{borders} = $sides_x;
		push @chunked, $chunk;
	}

	while (@sorted) {
		my %c = shift(@sorted)->%*;

		my @new_chunked;
		foreach my $chunk (@chunked) {
			if ($c{y1} == $chunk->{y1} && $c{y2} == $chunk->{y2}) {
				# exact match
				push $chunk->{sides}->@*, {%c};

				$c{y1} = "inf";
				$c{y2} = "-inf";
			}
			elsif ($c{y1} <= $chunk->{y2} && $c{y2} >= $chunk->{y1}) {
				# partial match

				# has before?
				if ($c{y1} < $chunk->{y1}) {
					unshift @sorted, { %c, y2 => $chunk->{y1} - 1 };
				}

				# has after?
				if ($c{y2} > $chunk->{y2}) {
					unshift @sorted, { %c, y1 => $chunk->{y2} + 1 };
				}

				# split the chunk if necessary
				push @new_chunked, $self->_subdivide_chunk($chunk, \%c);

				# this side was swallowed
				$c{y1} = "inf";
				$c{y2} = "-inf";
			}
			else {
				# no match
			}

			push @new_chunked, $chunk;
		}

		if ($c{y1} <= $c{y2}) {
			push @new_chunked, $self->_spawn_chunk(@c{qw(y1 y2)}, {%c});
		}

		@chunked = @new_chunked;
	}

	@chunked = sort {
		$a->{y1} <=> $b->{y1}
	} @chunked;
	return \@chunked;
}

sub add_border ($self, $from_x, $y, $to_x)
{
	($from_x, $to_x) = ($to_x, $from_x)
		if $from_x > $to_x;

	push $self->borders->{$y}->@*, [$from_x, $to_x];
}

sub add_side ($self, $x, $from_y, $to_y, $direction)
{
	($from_y, $to_y) = ($to_y, $from_y)
		if $from_y > $to_y;

	push $self->sides->@*, {
		x => $x,
		y1 => $from_y,
		y2 => $to_y,
		dir => $direction,
	};
}

sub get_area ($self)
{
	my $area = 0;
	foreach my $chunk ($self->_sides_chunked->@*) {
		my $height = $chunk->{y2} - $chunk->{y1} + 1;
		my $up = $chunk->{sides}[0]{dir};
		my $last;

		foreach my $side ($chunk->{sides}->@*) {
			if ($last) {
				if ($last->{dir} eq $up && $side->{dir} ne $up) {
					# got an area
					$area += ($side->{x} - $last->{x} + 1) * $height;
				}
				elsif ($last->{dir} eq $side->{dir}) {
					# got an edge (the height must be 1)
					# don't include this square itself (don't add 1)
					$area += $side->{x} - $last->{x};
				}
				elsif ($chunk->{borders}) {
					# got an edge and this is a border, so check if we should include it
					$area += $side->{x} - $last->{x} - 1
						if any { $_->[0] == $last->{x} && $_->[1] == $side->{x} } $chunk->{borders}->@*;
				}
			}

			$last = $side;
		}
	}

	return $area;
}

