package Day3::Solution;

use Day3::Search;
use List::Util qw(max sum0 product);
use builtin qw(ceil indexed);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my $search = Day3::Search->new;
	my @symbols;

	foreach my ($pos_y, $line) (indexed $input->@*) {
		my $pos_x = 0;
		my @items = split m{ ( \.+ | \D ) }x, $line;

		my $is_number = !!0;
		foreach my $item (@items) {
			$is_number = !$is_number;

			my $len = length $item;
			next if $len == 0;

			if ($is_number) {
				$search->add($item, $pos_x, $pos_y, $len);
			}
			elsif ($len == 1 && $item ne '.') {
				push @symbols, [$item, $pos_x, $pos_y];
			}

			$pos_x += $len;
		}
	}

	return ($search, \@symbols);
}

sub part_1 ($self)
{
	my ($search, $symbols) = $self->_parse_input;

	my $sum = 0;
	foreach my $symbol ($symbols->@*) {
		$sum += sum0 $search->find_around($symbol->@[1, 2])->@*;
	}

	return $sum;
}

sub part_2 ($self)
{
	my ($search, $symbols) = $self->_parse_input;

	my $sum = 0;
	foreach my $symbol ($symbols->@*) {
		next unless $symbol->[0] eq '*';

		my @found = $search->find_around($symbol->@[1, 2])->@*;
		next unless @found == 2;

		$sum += product @found;
	}

	return $sum;
}

