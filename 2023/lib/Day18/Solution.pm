package Day18::Solution;

use Day18::Trench;

use class;

with 'Solution';

sub _parse_input ($self, $colors = !!0, $input = $self->input)
{
	state %directions = (
		# regular
		R => [1, 0],
		D => [0, 1],
		L => [-1, 0],
		U => [0, -1],
	);

	state %colors_map = (
		0 => 'R',
		1 => 'D',
		2 => 'L',
		3 => 'U',
	);

	state @vertical = qw(U D);

	my $trench = Day18::Trench->new;
	my @pos = (0, 0);

	foreach my $line ($input->@*) {
		my ($direction, $distance, $color) = split / /, $line;

		if ($colors && $color =~ /\(#(.+)(.)\)/) {
			$distance = hex $1;
			$direction = $colors_map{$2};
		}

		my @pos_from = @pos;
		$pos[0] += $directions{$direction}[0] * $distance;
		$pos[1] += $directions{$direction}[1] * $distance;

		if (any { $direction eq $_ } @vertical) {
			# let's call vertical lines sides
			$trench->add_side(@pos, $pos_from[1], $direction)
		}
		else {
			# let's call horizontal lines borders
			$trench->add_border(@pos, $pos_from[0]);
		}
	}
	return $trench;
}

sub part_1 ($self)
{
	my $trench = $self->_parse_input;

	return $trench->get_area;
}

sub part_2 ($self)
{
	my $trench = $self->_parse_input(!!1);

	return $trench->get_area;
}

