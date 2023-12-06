package Day6::Solution;

use List::Util qw(reduce);
use builtin qw(ceil indexed);

use class;
no warnings qw(experimental::builtin);

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
		my $half = int($time / 2);
		my $winning_ways = ($half - $to_beat) * 2;
		for (my $ind = $to_beat; $ind >= 0; --$ind) {
			my $result = $ind * ($time - $ind);
			last unless $result > $distance;
			$winning_ways += 2;
		}

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

