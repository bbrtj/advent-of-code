package Day21::Pathfinding;

use List::Util qw(max);
use builtin qw(weaken indexed);

use class;

has field 'size_x' => (
	writer => 1,
	default => 0,
);

has field 'size_y' => (
	writer => 1,
	default => 0,
);

has field 'start' => (
	writer => 1,
);

has field 'obstacles' => (
	default => sub { [] },
);

sub _adjust_coord ($self, $coord)
{
	if ($coord->[0] < 0) {
		$coord->[0] += $self->size_x;
	}

	if ($coord->[1] < 0) {
		$coord->[1] += $self->size_y;
	}
}

sub add_obstacle ($self, $x, $y)
{
	my $obstacles = $self->obstacles;
	$obstacles->[$y][$x] = 1;
}

sub prepare_map ($self)
{
	my @map;
	my $obstacles = $self->obstacles;

	# prepare nodes for pathfinding
	foreach my $y (0 .. $self->size_y - 1) {
		$map[$y] = [];

		foreach my $x (0 .. $self->size_x - 1) {
			next if $obstacles->[$y][$x];

			my $node = {
				pos_x => $x,
				pos_y => $y,
				weight => 1,
				connections => [],

				total => 'inf',
				visited => !!0,
			};
			$map[$y][$x] = $node;

			if ($x > 0 && $map[$y][$x - 1]) {
				push $map[$y][$x - 1]->{connections}->@*, $node;
				weaken $map[$y][$x - 1]->{connections}->[-1];

				push $node->{connections}->@*, $map[$y][$x - 1];
				weaken $node->{connections}->[-1];
			}

			if ($y > 0 && $map[$y - 1][$x]) {
				push $map[$y - 1][$x]->{connections}->@*, $node;
				weaken $map[$y - 1][$x]->{connections}->[-1];

				push $node->{connections}->@*, $map[$y - 1][$x];
				weaken $node->{connections}->[-1];
			}
		}
	}

	return \@map;
}

sub get_reached_plots ($self, $range, $start = $self->start)
{
	my ($sx, $sy) = $start->@*;
	my $map = $self->prepare_map;

	my @next = $map->[$sy][$sx];
	foreach my $node (@next) {
		$node->{total} = 0;
		$node->{visited} = !!1;
	}

	my $start_status = ($sx + $sy + $range) % 2;
	my $total = 0;

	# do the pathfinding
	while (my $current = shift @next) {
		last if $current->{total} == $range + 1;
		$total += 1 if ($current->{pos_x} + $current->{pos_y}) % 2 == $start_status;

		foreach my $node ($current->{connections}->@*) {
			my $new_total = $current->{total} + $node->{weight};
			$node->{total} = $new_total;

			if (!$node->{visited}) {
				push @next, $node;
				$node->{visited} = !!1;
			}
		}
	}

	return $total;
}

sub get_reached_infinite_plots ($self, $range)
{
	my ($sx, $sy) = $self->start->@*;
	my ($mx, $my) = ($self->size_x, $self->size_y);
	my $total = $self->get_reached_plots($range);
	my $total_odd = $self->get_reached_plots($range + 1);
	my $divided = int($range / $mx);
	my $remainder = $range - $mx * $divided;

	my %reached = (
		N => $self->get_reached_plots($remainder, [$sx, $my - 1]),
		NE => $self->get_reached_plots($remainder, [$mx - 1, $my - 1]),
		E => $self->get_reached_plots($remainder, [$mx - 1, $sy]),
		SE => $self->get_reached_plots($remainder, [$mx - 1, 0]),
		S => $self->get_reached_plots($remainder, [$sx, 0]),
		SW => $self->get_reached_plots($remainder, [0, 0]),
		W => $self->get_reached_plots($remainder, [0, $sy]),
		NW => $self->get_reached_plots($remainder, [0, $my - 1]),
	);

	my $sum = ($total + $total_odd) * $divided ** 2;
	$sum += $reached{N}
		+ $reached{E}
		+ $reached{S}
		+ $reached{W}
	;

	$sum += ($divided - 1) * 2 * (
		$reached{NE}
		+ $reached{SE}
		+ $reached{SW}
		+ $reached{NW}
	);

	return $sum;
}

