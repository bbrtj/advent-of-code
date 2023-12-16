package Day16::Layout;

use Types::Common -types;

use class;

has field 'size_x' => (
	writer => 1,
);

has field 'size_y' => (
	writer => 1,
);

has field 'reflectors' => (
	isa => HashRef [Str],
	default => sub { {} },
);

sub reflector_horizontal ($self, $beam, $memory)
{
	return () if $memory->{used}++;

	if ($beam->[1][1]) {
		$beam->[1][1] = 0;
		my $new_beam = [[$beam->[0]->@*], [$beam->[1]->@*]];
		$beam->[1][0] = 1;
		$new_beam->[1][0] = -1;

		return ($beam, $new_beam);
	}

	return ($beam);
}

sub reflector_vertical ($self, $beam, $memory)
{
	return () if $memory->{used}++;

	if ($beam->[1][0]) {
		$beam->[1][0] = 0;
		my $new_beam = [[$beam->[0]->@*], [$beam->[1]->@*]];
		$beam->[1][1] = 1;
		$new_beam->[1][1] = -1;

		return ($beam, $new_beam);
	}

	return ($beam);
}

sub reflector_90deg ($self, $beam, $mul, $memory)
{
	return () if $memory->{join ';', $beam->[1]->@*}++;

	if ($beam->[1][0]) {
		$beam->[1][1] = $mul * $beam->[1][0];
		$beam->[1][0] = 0;
	}
	else {
		$beam->[1][0] = $mul * $beam->[1][1];
		$beam->[1][1] = 0;
	}

	return ($beam);
}

sub reflector_WE ($self, $beam, $memory)
{
	return $self->reflector_90deg($beam, 1, $memory);
}

sub reflector_EW ($self, $beam, $memory)
{
	return $self->reflector_90deg($beam, -1, $memory);
}

sub add_reflector ($self, $x, $y, $type)
{
	state %types = (
		'-' => 'reflector_horizontal',
		'|' => 'reflector_vertical',
		'\\' => 'reflector_WE',
		'/' => 'reflector_EW',
	);

	return unless $types{$type};
	$self->reflectors->{"$x;$y"} = $self->can($types{$type});
}

sub run ($self, $starting_beam)
{
	my $reflectors = $self->reflectors;
	my $size_x = $self->size_x;
	my $size_y = $self->size_y;

	my @beams = ($starting_beam);
	my %memory;
	my %energized;

	$memory{$_} = {} for keys $reflectors->%*;

	while (@beams > 0) {
		my @new_beams;
		foreach my $beam (@beams) {
			$beam->[0][0] += $beam->[1][0];
			$beam->[0][1] += $beam->[1][1];
			my $pos_str = join ';', $beam->[0]->@*;

			if ($reflectors->{$pos_str}) {
				$energized{$pos_str} = 1;
				push @new_beams, $reflectors->{$pos_str}->($self, $beam, $memory{$pos_str});
			}
			elsif (0 <= $beam->[0][0] < $size_x && 0 <= $beam->[0][1] < $size_y) {
				$energized{$pos_str} = 1;
				push @new_beams, $beam;
			}
		}

		@beams = @new_beams;
	}

	return \%energized;
}

