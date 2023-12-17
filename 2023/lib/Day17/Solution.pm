package Day17::Solution;

use List::Util qw(sum);
use builtin qw(indexed);
use Day17::Pathfinding;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $data = Day17::Pathfinding->new;
	foreach my $line ($input->@*) {
		$data->add_line([split //, $line]);
	}

	return $data;
}

sub part_1 ($self)
{
	my $data = $self->_parse_input;

	return $data->find_shortest_path([0, 0], [-1, -1], 1, 3);
}

sub part_2 ($self)
{
	my $data = $self->_parse_input;

	return $data->find_shortest_path([0, 0], [-1, -1], 4, 10);
}

