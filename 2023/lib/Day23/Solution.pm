package Day23::Solution;

use Day23::Pathfinding;
use builtin qw(indexed);
use List::Util qw(max);
use Util qw(parallel_map);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $map = Day23::Pathfinding->new;

	foreach my $line ($input->@*) {
		$map->add_line([split //, $line]);
	}

	return $map;
}

sub _find_start_end ($self, $map)
{
	my $start = [undef, 0];
	foreach my ($x, $item) (indexed $map->map->[$start->[1]]->@*) {
		if ($item eq $map->PATH) {
			$start->[0] = $x;
			last;
		}
	}

	my $end = [undef, $map->size_y - 1];
	foreach my ($x, $item) (indexed $map->map->[$end->[1]]->@*) {
		if ($item eq $map->PATH) {
			$end->[0] = $x;
			last;
		}
	}

	return ($start, $end);
}

sub part_1 ($self)
{
	my $map = $self->_parse_input;

	return $map->find_longest_path($self->_find_start_end($map));
}

sub part_2 ($self)
{
	my $map = $self->_parse_input;
	# return unless $self->is_test;

	return $map->find_longest_path_no_slopes($self->_find_start_end($map));
}

