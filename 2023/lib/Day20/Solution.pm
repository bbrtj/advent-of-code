package Day20::Solution;

use Day20::Modules;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $modules = Day20::Modules->new;
	foreach my $line ($self->input->@*) {
		if ($line =~ m{ \A (\W)? (\w+) \s* -> \s* (.+) \z}x) {
			my $type = $1;
			my $label = $2;
			my @connections = split /,\s?/, $3;

			$modules->add($type, $label, \@connections);
		}
		else {
			die "invalid module: $line";
		}
	}

	$modules->finalize;
	return $modules;
}

sub part_1 ($self)
{
	my $modules = $self->_parse_input;

	$modules->run for 1 .. 1000;
	return $modules->sent_low * $modules->sent_high;
}

sub part_2 ($self)
{
	my $modules = $self->_parse_input;
	$modules->add_rx;

	while (!$modules->finished_at) {
		$modules->run;
	}

	return $modules->finished_at;
}

