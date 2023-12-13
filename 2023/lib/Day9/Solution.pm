package Day9::Solution;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @data;
	foreach my $line ($input->@*) {
		push @data, [split / /, $line];
	}

	return \@data;
}

sub _get_triangle ($self, $array)
{
	my @triangle = ($array);
	my $last_row = $array;
	my $new_row;
	my $all_zeros = 0;

	while (!$all_zeros) {
		my $last = $last_row->[0];
		$new_row = [];
		$all_zeros = 1;

		foreach my $item ($last_row->@[1 .. $last_row->$#*]) {
			my $value = $item - $last;
			push $new_row->@*, $value;

			$all_zeros &&= $value == 0;
			$last = $item;
		}

		push @triangle, $new_row;
		$last_row = $new_row;
	}

	return \@triangle;
}

sub _get_extrapolated ($self, $array, $backwards = !!0)
{
	my $triangle = $self->_get_triangle($array);
	my $previous_value;

	my $item_no = $backwards ? 0 : -1;
	my $mul = $backwards ? -1 : 1;

	foreach my $row (reverse $triangle->@*) {
		if (defined $previous_value) {
			$row->[$item_no] = ($row->[$item_no] // 0) + $mul * $previous_value;
		}

		$previous_value = $row->[$item_no];
	}

	return $triangle->[0][$item_no];
}

sub part_1 ($self)
{
	my $input = $self->_parse_input;
	my $sum = 0;

	foreach my $item ($input->@*) {
		$sum += $self->_get_extrapolated($item);
	}

	return $sum;
}

sub part_2 ($self)
{
	my $input = $self->_parse_input;
	my $sum = 0;

	foreach my $item ($input->@*) {
		$sum += $self->_get_extrapolated($item, !!1);
	}

	return $sum;
}

