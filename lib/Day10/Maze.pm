package Day10::Maze;

use Types::Common -types;
use Day10::MazePipe;
use builtin qw(indexed);
use List::Util qw(all);

use class;

has field 'positions' => (
	isa => ArrayRef [ArrayRef [Maybe [InstanceOf ['Day10::MazePipe']]]],
	default => sub { [] },
);

has field 'start_pos' => (
	writer => -hidden,
	predicate => 1,
);

sub add_pipe ($self, $x, $y, $type, $path, $last = undef)
{
	# NOTE: $type and $path are array references, but no cloning - treating
	# them as readonly
	my $item = $self->positions->[$y][$x] //= Day10::MazePipe->new(
		position => [$x, $y],
		type => $type,
		path => $path,
	);

	if ($last) {
		$last->set_to($item);
		$item->set_from($last);
	}

	return $item;
}

sub find_furthest ($self, $start_x, $start_y)
{
	my $start = $self->positions->[$start_y][$start_x];

	my $item_left = $start->to;
	my $item_right = $start->from;

	my $current = 1;

	while ($item_left != $item_right) {
		$item_left = $item_left->to;
		$item_right = $item_right->from;

		$current += 1;
	}

	return $current;
}

sub find_borders ($self, $start_x, $start_y)
{
	my $start = $self->positions->[$start_y][$start_x];

	my $item = $start;
	my @grid;

	while ('looping') {
		my $direction = $item->to->position->[1] - $item->from->position->[1];
		$grid[$item->position->[1]][$item->position->[0]] = $direction <=> 0;

		$item = $item->to;
		last if $item == $start
	}

	return \@grid;
}

