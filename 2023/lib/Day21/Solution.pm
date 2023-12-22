package Day21::Solution;

use Day21::Pathfinding;
use builtin qw(indexed);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $path = Day21::Pathfinding->new;

	foreach my ($y, $line) (indexed $input->@*) {
		foreach my ($x, $c) (indexed split //, $line) {
			if ($c eq '#') {
				$path->add_obstacle($x, $y);
			}
			elsif ($c eq 'S') {
				$path->set_start([$x, $y]);
			}
		}

		$path->set_size_x(length $line);
	}

	$path->set_size_y(scalar $input->@*);
	return $path;
}

sub part_1 ($self)
{
	my $path = $self->_parse_input;
	my $steps = $self->is_test ? 6 : 64;

	return $path->get_reached_plots($steps);
}

sub part_2 ($self)
{
	my $path = $self->_parse_input;

	return 'not testing' if $self->is_test;

	return $path->get_reached_infinite_plots(26501365);
}

