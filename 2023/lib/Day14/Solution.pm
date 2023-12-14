package Day14::Solution;

use builtin qw(indexed);
use Day14::Platform;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $platform = Day14::Platform->new;
	foreach my $line ($input->@*) {
		$line =~ tr/.O#/012/;
		$platform->add_row([split //, $line]);
	}

	return $platform;
}

sub tilt ($self, $platform)
{
	foreach my $pos1 (0 .. $platform->size_primary - 1) {
		my $line = $platform->get_line($pos1);

		my $last_obstacle = -1;
		my $pos2 = 0;
		foreach my $item ($line->@*) {
			if ($item == 1) {
				$item = 0;
				$line->[++$last_obstacle] = 1;
			}
			elsif ($item == 2) {
				$last_obstacle = $pos2;
			}
			++$pos2;
		}

		$platform->set_line($pos1, $line);
	}
}

sub tilt_reversed ($self, $platform)
{
	foreach my $pos1 (0 .. $platform->size_primary - 1) {
		my $line = $platform->get_line($pos1);

		my $last_obstacle = $line->@*;
		my $pos2 = $last_obstacle - 1;
		foreach my $item (reverse $line->@*) {
			if ($item == 1) {
				$item = 0;
				$line->[--$last_obstacle] = 1;
			}
			elsif ($item == 2) {
				$last_obstacle = $pos2;
			}
			--$pos2;
		}

		$platform->set_line($pos1, $line);
	}
}

sub get_load ($self, $platform)
{
	$platform->set_vertical;

	my $load = 0;
	foreach my $pos1 (0 .. $platform->size_primary - 1) {
		my @line = $platform->get_line($pos1)->@*;

		foreach my ($pos2, $item) (indexed @line) {
			$load += @line - $pos2 if $item == 1;
		}
	}

	return $load;
}

sub tilt_cycles ($self, $platform, $total_count)
{
	my %known;
	my %count_states;
	for (my $count = $total_count; $count > 0; --$count) {
		$platform->set_vertical;
		$self->tilt($platform);

		$platform->set_horizontal;
		$self->tilt($platform);

		$platform->set_vertical;
		$self->tilt_reversed($platform);

		$platform->set_horizontal;
		$self->tilt_reversed($platform);

		my $key = $platform->serialize;
		if ($known{$key}) {
			my $grand_cycle = $known{$key} - $count;
			my $wanted_count = $known{$key} - ($count - 1) % $grand_cycle;

			$platform->deserialize($count_states{$wanted_count});
			last;
		}
		else {
			$known{$key} = $count;
			$count_states{$count} = $key;
		}
	}
}

sub part_1 ($self)
{
	my $platform = $self->_parse_input;

	$platform->set_vertical;
	$self->tilt($platform);
	$platform->set_horizontal;

	return $self->get_load($platform);
}

sub part_2 ($self)
{
	my $platform = $self->_parse_input;

	$self->tilt_cycles($platform, 1_000_000_000);
	return $self->get_load($platform);
}

