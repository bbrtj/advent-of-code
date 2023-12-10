package Day10::Solution;

use Day10::Maze;
use builtin qw(indexed);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	state $start_mark = 'S';
	state %marks = (
		'|' => [['y', 'y'], [-1, 1]],
		'-' => [['x', 'x'], [-1, 1]],
		'F' => [['x', 'y'], [1, 1]],
		'7' => [['x', 'y'], [-1, 1]],
		'J' => [['x', 'y'], [-1, -1]],
		'L' => [['x', 'y'], [1, -1]],
	);

	$input->@* = map { [split //, $_] } $input->@*;
	my $maze = Day10::Maze->new;
	my $starting_pos = sub {
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
					return [$x, $y];
				}
			}
		}
	}->();

	my ($x, $y) = $starting_pos->@*;
	my $start = $maze->add_pipe($x, $y, $marks{$input->[$y][$x]}->@*);
	my $item = $start;

	while ('finding loop') {
		($x, $y) = $item->next_position;
		$item = $maze->add_pipe($x, $y, $marks{$input->[$y][$x]}->@*, $item);
		last if $item == $start;
	}

	return ($maze, $starting_pos);
}

sub part_1 ($self)
{
	my ($maze, $starting_pos) = $self->_parse_input;

	return $maze->find_furthest($starting_pos->@*);
}

sub part_2 ($self)
{
	my ($maze, $starting_pos) = $self->_parse_input;

	my $grid = $maze->find_borders($starting_pos->@*);
	my $sum_inside = 0;
	foreach my ($y, $directions) (indexed $grid->@*) {
		my $last_direction;

		foreach my ($x, $direction) (indexed $directions->@*) {
			if (!defined $direction) {
				$sum_inside += 1
					if $last_direction && $last_direction == 1;
			}
			else {
				if ($direction) {
					$last_direction = $direction;
				}
			}
		}
	}

	return $sum_inside;
}

