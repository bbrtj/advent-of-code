package Day22::Solution;

use Day22::Snapshot;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $snapshot = Day22::Snapshot->new;

	foreach my $line ($input->@*) {
		my @parts = split /~/, $line;
		$snapshot->add_brick(split(/,/, $parts[0]), split(/,/, $parts[1]));
	}

	return $snapshot;
}

sub part_1 ($self)
{
	my $snapshot = $self->_parse_input;

	$snapshot->rearrange;

	return $snapshot->optional_support;
}

sub part_2 ($self)
{
	my $snapshot = $self->_parse_input;

	$snapshot->rearrange;

	return $snapshot->chain_reaction;
}

