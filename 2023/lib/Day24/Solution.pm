package Day24::Solution;

use Day24::Trajectories;
use builtin qw(trim);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $trajectories = Day24::Trajectories->new;

	foreach my $line ($input->@*) {
		my ($pos, $velocity) = split /@/, $line;
		$trajectories->add([map { trim $_ } split /,/, $pos], [map { trim $_ } split /,/, $velocity]);
	}

	return $trajectories;
}

sub part_1 ($self)
{
	my $trajectories = $self->_parse_input;
	my $range = $self->is_test ? [7, 27] : [200_000_000_000_000, 400_000_000_000_000];

	return $trajectories->count_collisions($range);
}

sub part_2 ($self)
{
	...
}

