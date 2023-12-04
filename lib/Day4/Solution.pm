package Day4::Solution;

use List::Util qw(sum0);

use class;

with 'Solution';

sub _parse_input ($self, $line)
{
	$line =~ s/Card\s+\d+://;
	my @parts = split /\|/, $line;

	my @winning_numbers = grep { length } split / /, $parts[0];
	my @got_numbers = grep { length } split / /, $parts[1];

	return [\@winning_numbers, \@got_numbers];
}

sub run_first ($self)
{
	my @cards = map { $self->_parse_input($_) } $self->input->@*;

	my $sum = 0;
	foreach my $card (@cards) {
		my ($winning, $got) = $card->@*;
		my $card_worth = 0;

		$got->@* = sort { $b <=> $a } $got->@*;

		foreach my $number_one ($winning->@*) {
			foreach my $number_two ($got->@*) {
				next if $number_two > $number_one;
				last if $number_two < $number_one;

				$card_worth = $card_worth ? $card_worth * 2 : 1;
			}
		}

		$sum += $card_worth;
	}

	$self->output($sum);
}

sub run_second ($self)
{
	my @cards = map { $self->_parse_input($_) } $self->input->@*;

	my @cards_processed;

	foreach my $card_number (keys @cards) {
		my ($winning, $got) = $cards[$card_number]->@*;
		my $card_worth = 0;

		$got->@* = sort { $b <=> $a } $got->@*;

		foreach my $number_one ($winning->@*) {
			foreach my $number_two ($got->@*) {
				next if $number_two > $number_one;
				last if $number_two < $number_one;

				$card_worth += 1;
			}
		}

		my @next_cards = $card_number + 1 .. $card_number + $card_worth;
		$cards_processed[$card_number] = [\@next_cards, 1];
	}

	foreach my $processed (@cards_processed) {
		$cards_processed[$_][1] += $processed->[1]
			for $processed->[0]->@*;
	}

	$self->output(sum0 map { $_->[1] } @cards_processed);
}

