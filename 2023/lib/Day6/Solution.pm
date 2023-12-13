package Day6::Solution;

use List::Util qw(reduce);
use builtin qw(ceil indexed);

use class;

with 'Solution';

sub _parse_input ($self)
{
	my @races;
	foreach my $line ($self->input->@*) {
		my $numbers_str = (split /:/, $line)[1];
		my @numbers = grep { length } split / +/, $numbers_str;

		foreach my ($ind, $number) (indexed @numbers) {
			push $races[$ind]->@*, $number;
		}
	}

	return \@races;
}

sub _calculate ($self, $races = $self->_parse_input)
{
	my $winning = 1;

	foreach my $race ($races->@*) {
		my ($time, $distance) = $race->@*;

		my $to_beat = ceil sqrt $distance;
		my $winning_ways = (int($time / 2) - $to_beat + 1) * 2;

		# approximate border value by halving
		my $half = $to_beat;
		my $current = $half;
		while ($half > 0) {
			$half = int($half / 2);
			my $result = $current * ($time - $current);
			my $mul = $result <=> $distance;

			$current = $current - $mul * $half;
		}

		# adjust border value to take into account rounding halves
		foreach my $real_current ($current - 2 .. $current + 2) {
			if ($real_current * ($time - $real_current) > $distance) {
				$current = $real_current;
				last;
			}
		}

		$winning_ways += ($to_beat - $current) * 2;
		$winning_ways -= 1
			if $winning_ways && $time % 2 == 0;

		$winning *= $winning_ways;
	}

	return $winning;
}

sub part_1 ($self)
{
	return $self->_calculate;
}

sub part_2 ($self)
{
	my $races = $self->_parse_input;
	my $real_race = reduce {
		$a //= ['', ''];
		my @products = map { $a->[$_] . $b->[$_] } 0 .. 1;
		\@products;
	} $races->@*;

	return $self->_calculate([$real_race]);
}

