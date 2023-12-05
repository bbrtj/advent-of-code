package Day5::AlmanacMap;

use Types::Common -types;

use class;

has param 'from_name' => (
	isa => Str,
);

has param 'to_name' => (
	isa => Str,
);

has field 'mappings' => (
	isa => ArrayRef[Tuple[PositiveInt, PositiveInt, PositiveInt]],
	default => sub { [] },
);

sub add_mapping ($self, $destination, $source, $length)
{
	# NOTE: the order of input is as found in the almanac
	push $self->mappings->@*, [$source, $source + $length, $destination];
}

sub find_mapping ($self, $value)
{
	foreach my $mapping ($self->mappings->@*) {
		my ($from, $to, $result_base) = $mapping->@*;

		if ($from <= $value <= $to) {
			return $result_base + ($value - $from);
		}
	}

	return $value;
}

sub find_mapping_for_range ($self, $range_from, $range_to)
{
	foreach my $mapping ($self->mappings->@*) {
		my ($from, $to, $result_base) = $mapping->@*;

		# is range contained at all?
		# if not, try next mapping
		next unless $range_from <= $to && $range_to >= $from;

		my @resulting_mappings;

		# any below?
		if ($range_from < $from) {
			push @resulting_mappings, $self->find_mapping_for_range($range_from, $from - 1)->@*;
			$range_from = $from;
		}

		# any above?
		if ($range_to > $to) {
			push @resulting_mappings, $self->find_mapping_for_range($to + 1, $range_to)->@*;
			$range_to = $to;
		}

		push @resulting_mappings, [
			$result_base + ($range_from - $from),
			$result_base + ($range_to - $from),
		];

		return \@resulting_mappings;
	}

	return [[$range_from, $range_to]];
}

