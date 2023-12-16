package Day16::Solution;

use List::Util qw(sum max);
use builtin qw(indexed);
use Util qw(parallel_map);
use Day16::Layout;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $layout = Day16::Layout->new;
	$layout->set_size_y(scalar $input->@*);

	foreach my ($pos_y, $line) (indexed $input->@*) {
		$layout->set_size_x(length $line)
			if length $line > ($layout->size_x // 0);

		foreach my ($pos_x, $char) (indexed split //, $line) {
			$layout->add_reflector($pos_x, $pos_y, $char);
		}
	}

	return $layout;
}

sub part_1 ($self)
{
	my $layout = $self->_parse_input;
	my $energized = $layout->run([[-1, 0], [1, 0]]);

	return sum values $energized->%*;
}

sub part_2 ($self)
{
	my $layout = $self->_parse_input;
	my @actions;

	my $check_x = sub ($conf_x, $conf_y) {
		my $direction = $conf_x == 0 ? 1 : -1;
		my $energized = $layout->run([[$conf_x - $direction, $conf_y], [$direction, 0]]);
		return sum values $energized->%*;
	};

	my $check_y = sub ($conf_x, $conf_y) {
		my $direction = $conf_y == 0 ? 1 : -1;
		my $energized = $layout->run([[$conf_x, $conf_y - $direction], [0, $direction]]);
		return sum values $energized->%*;
	};

	foreach my $conf_x (0, $layout->size_x - 1) {
		foreach my $conf_y (0 .. $layout->size_y - 1) {
			push @actions, [$check_x, $conf_x, $conf_y];
		}
	}

	foreach my $conf_y (0, $layout->size_y - 1) {
		foreach my $conf_x (0 .. $layout->size_x - 1) {
			push @actions, [$check_y, $conf_x, $conf_y];
		}
	}

	return max parallel_map { $_->[0]->($_->@[1, 2]) } @actions;
}

