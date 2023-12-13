package Day11::Solution;

use builtin qw(indexed);
use List::Util qw(sum);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @stars;
	foreach my ($y, $line) (indexed $input->@*) {
		my @parts = split /(\.+)/, $line;
		my $x = 0;

		foreach my $part (@parts) {
			if ($part eq '#') {
				push @stars, [$x, $y];
			}

			$x += length $part;
		}
	}

	return \@stars;
}

sub _adjust_positions ($self, $stars, $ind, $by = 1)
{
	my @sorted = sort { $a->[$ind] <=> $b->[$ind] } $stars->@*;
	my $max = $sorted[-1][$ind];
	my $blanks_so_far = 0;

	foreach my $line_pos (0 .. $max) {
		my $star;
		while (@sorted && $sorted[0][$ind] == $line_pos) {
			$star = shift @sorted;
			$star->[$ind] += $blanks_so_far;
		}

		$blanks_so_far += (!defined $star) * $by;
	}
}

sub _find_all_distances($self, $stars)
{
	my @distances;
	foreach my ($ind, $this_star) (indexed $stars->@*) {
		foreach my $that_star ($stars->@[$ind + 1 .. $stars->$#*]) {
			push @distances, abs($this_star->[0] - $that_star->[0]) + abs($this_star->[1] - $that_star->[1]);
		}
	}

	return \@distances;
}

sub part_1 ($self)
{
	my $stars = $self->_parse_input;
	$self->_adjust_positions($stars, 0);
	$self->_adjust_positions($stars, 1);

	return sum $self->_find_all_distances($stars)->@*;
}

sub part_2 ($self)
{
	my $stars = $self->_parse_input;
	$self->_adjust_positions($stars, 0, 1_000_000 - 1);
	$self->_adjust_positions($stars, 1, 1_000_000 - 1);

	return sum $self->_find_all_distances($stars)->@*;
}

