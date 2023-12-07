package Day7::Solution;

use List::Util qw(sum);
use builtin qw(indexed);

use class;
no warnings qw(experimental::builtin);

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @data;
	foreach my $line ($self->input->@*) {
		push @data, [split / /, $line];
	}

	return \@data;
}

sub get_set_value ($self, $set)
{
	state @cards = qw(A K Q J T 9 8 7 6 5 4 3 2);
	state %cards_map = map { $cards[$_] => @cards - $_ } keys @cards;
	my @these_cards = split //, $set;

	state $cards_in_set = 5;
	state $card_value_increase = @cards + 1;

	my $cards_value = 0;
	my %card_types;
	foreach my ($index, $card) (indexed @these_cards) {
		$card_types{$card}++;
		my $power = ($cards_in_set - $index - 1);
		$cards_value += $cards_map{$card} * ($card_value_increase ** $power);
	}

	my @type_counts = sort { $b <=> $a } values %card_types;
	my @set_type_values = (
		sub { $type_counts[0] == 5 },
		sub { @type_counts == 2 && $type_counts[0] == 4 },
		sub { @type_counts == 2 && $type_counts[0] == 3 },
		sub { @type_counts == 3 && $type_counts[0] == 3 },
		sub { @type_counts == 3 && $type_counts[0] == 2 },
		sub { @type_counts == 4 },
		sub { 1 },
	);

	my $set_value;
	foreach my ($index, $test) (indexed @set_type_values) {
		if ($test->()) {
			$set_value = $#set_type_values - $index;
			last;
		}
	}

	return [$set_value, $cards_value];
}

sub get_set_value_with_jokers ($self, $set)
{
	state @cards = qw(A K Q T 9 8 7 6 5 4 3 2 J);
	state %cards_map = map { $cards[$_] => @cards - $_ } keys @cards;
	my @these_cards = split //, $set;

	state $cards_in_set = 5;
	state $card_value_increase = @cards + 1;

	my $cards_value = 0;
	my %card_types;
	foreach my ($index, $card) (indexed @these_cards) {
		$card_types{$card}++;
		my $power = ($cards_in_set - $index - 1);
		$cards_value += $cards_map{$card} * ($card_value_increase ** $power);
	}

	my $jokers = (delete $card_types{J}) // 0;
	my @type_counts = sort { $b <=> $a } values %card_types;
	$type_counts[0] += $jokers;
	my @set_type_values = (
		sub { $type_counts[0] == 5 },
		sub { @type_counts == 2 && $type_counts[0] == 4 },
		sub { @type_counts == 2 && $type_counts[0] == 3 },
		sub { @type_counts == 3 && $type_counts[0] == 3 },
		sub { @type_counts == 3 && $type_counts[0] == 2 },
		sub { @type_counts == 4 },
		sub { 1 },
	);

	my $set_value;
	foreach my ($index, $test) (indexed @set_type_values) {
		if ($test->()) {
			$set_value = $#set_type_values - $index;
			last;
		}
	}

	return [$set_value, $cards_value];
}

sub part_1 ($self)
{
	my $input = $self->_parse_input;
	my @valued_sets;

	foreach my $set ($input->@*) {
		my ($cards, $value) = $set->@*;
		push @valued_sets, [$self->get_set_value($cards), $value, $cards];
	}

	my @set_sorted = sort {
		# by set
		my $sorted = $a->[0][0] <=> $b->[0][0];

		if ($sorted == 0) {
			# by $cards
			$a->[0][1] <=> $b->[0][1];
		}
		else {
			$sorted;
		}
	} @valued_sets;

	my $multiplier = 1;
	return sum map { $multiplier++ * $_->[1] } @set_sorted;
}

sub part_2 ($self)
{
	my $input = $self->_parse_input;
	my @valued_sets;

	foreach my $set ($input->@*) {
		my ($cards, $value) = $set->@*;
		push @valued_sets, [$self->get_set_value_with_jokers($cards), $value, $cards];
	}

	my @set_sorted = sort {
		# by set
		my $sorted = $a->[0][0] <=> $b->[0][0];

		if ($sorted == 0) {
			# by $cards
			$a->[0][1] <=> $b->[0][1];
		}
		else {
			$sorted;
		}
	} @valued_sets;

	my $multiplier = 1;
	return sum map { $multiplier++ * $_->[1] } @set_sorted;
}

