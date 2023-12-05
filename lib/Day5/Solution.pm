package Day5::Solution;

use Day5::AlmanacMap;
use List::Util qw(min);

use class;

with 'Solution';

sub _parse_input ($self)
{
	my @starting_values;
	my @mappings;
	my $last_mapping;
	my $last_mapping_name;

	foreach my $line ($self->input->@*) {
		if ($line =~ /^(\w+)s:/) {
			@starting_values = split / /, (split /: /, $line)[1];
			$last_mapping_name = $1;
		}
		elsif ($line =~ /^(\w+)-to-(\w+) map/) {
			$last_mapping = Day5::AlmanacMap->new(
				from_name => $1,
				to_name => $2,
			);

			push @mappings, $last_mapping;

			die 'incorrect mapping (no link)'
				if $last_mapping->from_name ne $last_mapping_name;
			$last_mapping_name = $last_mapping->to_name;
		}
		else {
			$last_mapping->add_mapping(split / /, $line);
		}
	}

	die 'incorrect mapping (destination)'
		if $last_mapping_name ne 'location';

	return (\@starting_values, \@mappings);
}

sub part_1 ($self)
{
	my ($values_aref, $mappings) = $self->_parse_input;

	my @values = $values_aref->@*;
	foreach my $mapping ($mappings->@*) {
		@values = map { $mapping->find_mapping($_) } @values;
	}

	return min @values;
}

sub part_2 ($self)
{
	my ($values_aref, $mappings) = $self->_parse_input;

	my @ranges;
	foreach my ($val1, $val2) ($values_aref->@*) {
		push @ranges, [$val1, $val1 + $val2 - 1];
	}

	foreach my $mapping ($mappings->@*) {
		@ranges = map { $mapping->find_mapping_for_range($_->@*)->@* } @ranges;
	}

	my $minimum;
	foreach my $range (@ranges) {
		$minimum = min $range->[0], ($minimum // $range->[0]);
	}

	return $minimum;
}

