package Day10::Solution;

use Day10::Maze;
use builtin qw(indexed);
use List::Util qw(first);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	state $start_mark = 'S';
	state %marks = (
		'|' => [[0, -1], [0, 1]],
		'-' => [[-1, 0], [1, 0]],
		'F' => [[0, 1], [1, 0]],
		'7' => [[0, 1], [-1, 0]],
		'J' => [[0, -1], [-1, 0]],
		'L' => [[0, -1], [1, 0]],
	);

	$input->@* = map { [split //, $_] } $input->@*;
	my ($start_x, $start_y) = sub {
		foreach my ($y, $line) (indexed $input->@*) {
			foreach my ($x, $mark) (indexed $line->@*) {
				if ($mark eq $start_mark) {

					my $previous = $y > 0 ? $input->[$y - 1][$x] : '.';
					my $previous_x = $x > 0 ? $line->[$x - 1] : '.';
					for ($previous_x . $previous . ($line->[$x + 1] // '.')) {
						if    (/[-FL].[-J7]/) { $mark = '-' }
						elsif (/[-FL][|F7]./) { $mark = 'J' }
						elsif (/.[|F7][-J7]/) { $mark = 'L' }
						elsif (/[-FL]../)     { $mark = '7' }
						elsif (/.[|F7]./)     { $mark = '|' }
						elsif (/..[-J7]/)     { $mark = 'F' }
					}

					$line->[$x] = $mark;
					return ($x, $y);
				}
			}
		}
	}->();

	my $maze = Day10::Maze->new;
	my $start = $maze->add_pipe($start_x, $start_y);
	my $item = $start;

	my ($x, $y) = ($start_x, $start_y);
	while ('finding loop') {
		($x, $y) = $item->next_position($marks{$input->[$y][$x]}->@*);
		last if $x == $start_x && $y == $start_y;
		$item = $maze->add_pipe($x, $y, $item);
	}

	$maze->finalize($start, $item);
	return $maze;
}

sub part_1 ($self)
{
	my $maze = $self->_parse_input;

	return ($maze->start->from->length + 1) / 2
}

sub part_2 ($self)
{
	my $maze = $self->_parse_input;

	my $grid = $maze->find_borders;
	my $sum_inside = 0;

	# find up - to know when we're inside
	my $up = first { defined } $grid->[0]->@*;

	foreach my $directions ($grid->@*) {
		my $last_direction = 0;

		foreach my $direction ($directions->@*) {
			if (!defined $direction) {
				$sum_inside += 1
					if $last_direction == $up;
			}
			else {
				$last_direction = $direction;
			}
		}
	}

	return $sum_inside;
}

