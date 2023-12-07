package Day7::Solution;

use List::Util qw(sum);
use builtin qw(indexed);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @data;
	foreach my $line ($input->@*) {
		my ($cards, $value) = split / /, $line;
		push @data, [[split //, $cards], $value];
	}

	return \@data;
}

sub get_set_value ($self, $set, $use_jokers)
{
	state @cards_normal = qw(A K Q J T 9 8 7 6 5 4 3 2);
	state @cards_jokers = qw(A K Q T 9 8 7 6 5 4 3 2 J);
	state %cards_map_normal = map { $cards_normal[$_] => $#cards_normal - $_ } keys @cards_normal;
	state %cards_map_jokers = map { $cards_jokers[$_] => $#cards_jokers - $_ } keys @cards_jokers;
	state $cards_in_set = 5;

	# work out the basics
	my $cards_map = $use_jokers ? \%cards_map_jokers : \%cards_map_normal;
	my $cards_count = keys $cards_map->%*;
	my %card_types;

	# calculate cards value and count cards for later
	my $cards_value = 0;
	foreach my ($index, $card) (indexed $set->@*) {
		$card_types{$card}++;
		my $power = $cards_in_set - $index - 1;
		$cards_value += $cards_map->{$card} * ($cards_count ** $power);
	}

	# these subs will match a set, their index is a set value
	# first value is number of different card types
	# second value is highest number of same cards
	state @set_type_values = (
		sub {               $_[1] == 5 },
		sub {               $_[1] == 4 },
		sub { $_[0] == 2 && $_[1] == 3 },
		sub { $_[0] == 3 && $_[1] == 3 },
		sub { $_[0] == 3 && $_[1] == 2 },
		sub { $_[0] == 4               },
	);

	# calculate values for the anonymous subs
	my $jokers = $use_jokers ? (delete $card_types{J}) // 0 : 0;
	my @type_counts = sort { $b <=> $a } values %card_types;
	my $total_card_types = @type_counts;
	my $highest_card_count = ($type_counts[0] // 0) + $jokers;

	# find out this set value
	my $set_value = 0;
	foreach my ($index, $test) (indexed @set_type_values) {
		if ($test->($total_card_types, $highest_card_count)) {
			$set_value = @set_type_values - $index;
			last;
		}
	}

	# cards cannot get higher value than $high_value, so multiply set by that
	my $high_value = $cards_count ** $cards_in_set;
	return $set_value * $high_value + $cards_value;
}

sub sort_sets ($self, $input, $use_jokers)
{
	my @valued_sets;

	foreach my $set ($input->@*) {
		my ($cards, $value) = $set->@*;
		push @valued_sets, [$self->get_set_value($cards, $use_jokers), $value, $cards];
	}

	return [
		sort {
			$a->[0] <=> $b->[0]
		} @valued_sets
	];
}

sub part_1 ($self)
{
	my $input = $self->_parse_input;
	my $set_sorted = $self->sort_sets($input, !!0);

	my $multiplier = 1;
	return sum map { $multiplier++ * $_->[1] } $set_sorted->@*;
}

sub part_2 ($self)
{
	my $input = $self->_parse_input;
	my $set_sorted = $self->sort_sets($input, !!1);

	my $multiplier = 1;
	return sum map { $multiplier++ * $_->[1] } $set_sorted->@*;
}

