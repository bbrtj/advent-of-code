package Day25::Solution;

use Day25::Groups;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $result = Day25::Groups->new;

	foreach my $line ($input->@*) {
		my ($from, $to_list) = split /: /, $line;
		foreach my $to (split / /, $to_list) {
			$result->add($from, $to);
		}
	}

	return $result;
}

sub part_1 ($self)
{
	my $groups = $self->_parse_input;

	return $groups->separate_groups(3);
}

sub part_2 ($self)
{
	return 'N/A';
}

