package Day10::Maze;

use Types::Common -types;
use Day10::MazePipe;
use builtin qw(indexed);
use List::Util qw(any);

use class;

has field 'start' => (
	isa => InstanceOf ['Day10::MazePipe'],
	writer => -hidden,
);

sub finalize ($self, $start, $last)
{
	$self->_set_start($start);

	$start->set_from($last);
	$last->set_weak_to($start);
}

sub add_pipe ($self, $x, $y, $last = undef)
{
	# NOTE: $type and $path are array references, but no cloning - treating
	# them as readonly
	my $item = Day10::MazePipe->new(
		position => [$x, $y],
	);

	if ($last) {
		$last->set_to($item);
		$item->set_from($last);
		$item->set_length($last->length + 1);
	}
	else {
		$item->set_length(0);
	}

	return $item;
}

sub find_borders ($self)
{
	my $start = $self->start;
	my $item = $start;
	my $last = $start->from;
	my @grid;

	while ('traversing') {
		my $next = $item->to;
		my $direction = $next->position->[1] - $last->position->[1];
		$grid[$item->position->[1]][$item->position->[0]] = $direction <=> 0;

		$last = $item;
		$item = $next;
		last if $item == $start
	}

	@grid = grep {
		any { defined } $_->@*
	} @grid;

	return \@grid;
}

