package Day21::Pathfinding;

use List::Util qw(sum max);
use builtin qw(weaken indexed);
use Util qw(parallel_map);

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

sub get_reached_plots ($self, $range, $start = $self->start, $swap = !!0)
{
	my ($sx, $sy) = $start->@*;
	my $map = $self->prepare_map;

	my @next = $map->[$sy][$sx];
	foreach my $node (@next) {
		$node->{total} = 0;
		$node->{visited} = !!1;
	}

	my $start_status = ($sx + $sy + $range) % 2;
	$start_status = 1 - $start_status if $swap;
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
	my $size = $self->size_x;
	my $n = ($range - $sx) / $size;
	my $rem = $range - $n * $size;
	my $uneven = $n % 2 == 1;

	die "I'm not a general algorithm!"
		unless $n == int($n) && $size == $self->size_y;

	# implementing https://www.reddit.com/r/adventofcode/comments/18o4y0m
	# with fixes to $sa, $sb, $st
	# (although my own approach was very similar)

	my $st = $size - 1;
	my $sa = $size + $rem - 1;
	my $sb = $rem;
	my %reached = (
		o => [$range, [$sx, $sy], $uneven],
		e => [$range, [$sx, $sy], !$uneven],

		t1 => [$st, [$size - 1, $sy], $uneven],
		t2 => [$st, [$sx, $size - 1], $uneven],
		t3 => [$st, [0, $sy], $uneven],
		t4 => [$st, [$sx, 0], $uneven],

		a1 => [$sa, [$size - 1, $size - 1], $uneven],
		a2 => [$sa, [0, $size - 1], $uneven],
		a3 => [$sa, [0, 0], $uneven],
		a4 => [$sa, [$size - 1, 0], $uneven],

		b1 => [$sb, [$size - 1, $size - 1], !$uneven],
		b2 => [$sb, [0, $size - 1], !$uneven],
		b3 => [$sb, [0, 0], !$uneven],
		b4 => [$sb, [$size - 1, 0], !$uneven],
	);

	%reached = parallel_map { $_ => $self->get_reached_plots($reached{$_}->@*) } keys %reached;

	my $o = $reached{o};
	my $e = $reached{e};

	my $a = sum map { $reached{$_} } qw (a1 a2 a3 a4);
	my $b = sum map { $reached{$_} } qw (b1 b2 b3 b4);
	my $t = sum map { $reached{$_} } qw (t1 t2 t3 t4);

	return
		($n - 1) ** 2 * $o
		+ $n ** 2 * $e
		+ ($n - 1) * $a
		+ $n * $b
		+ $t
		;
}

