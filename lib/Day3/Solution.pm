package Day3::Solution;

use Day3::Search;
use List::Util qw(max sum0 product);
use builtin qw(ceil indexed);

use class;
no warnings qw(experimental::builtin);

with 'Solution';

sub _parse_input ($self, $input)
{
	# new reference - do not break input
	$input = [map { [split //, $_] } $input->@*];

	my $search = Day3::Search->new;
	my @symbols;

	my sub save_number ($from_x, $to_x, $y)
	{
		my $number = join '', $input->[$y]->@[$from_x .. $to_x];
		$search->add($number, $from_x, $y, length $number);
	}

	my $number_from = undef;
	foreach my ($pos_y, $items_x) (indexed $input->@*) {
		foreach my ($pos_x, $item) (indexed $items_x->@*) {
			my $has_number = $item =~ /\d/;

			if (!defined $number_from && $has_number) {
				# number start
				$number_from = $pos_x;
			}
			elsif (defined $number_from && !$has_number) {
				# number end
				save_number($number_from, $pos_x - 1, $pos_y);
				$number_from = undef;
			}

			if (!$has_number) {
				next if $item eq '.';
				push @symbols, [$item, $pos_x, $pos_y];
			}
		}

		save_number($number_from, $input->[$pos_y]->$#*, $pos_y)
			if defined $number_from;
	}

	return ($search, \@symbols);
}

sub part_1 ($self)
{
	my ($search, $symbols) = $self->_parse_input($self->input);

	my $sum = 0;
	foreach my $symbol ($symbols->@*) {
		shift $symbol->@*;
		$sum += sum0 $search->find_around($symbol->@*)->@*;
	}

	return $sum;
}

sub part_2 ($self)
{
	my ($search, $symbols) = $self->_parse_input($self->input);

	my $sum = 0;
	foreach my $symbol ($symbols->@*) {
		my $type = shift $symbol->@*;
		next unless $type eq '*';

		my @found = $search->find_around($symbol->@*)->@*;
		next unless @found == 2;

		$sum += product @found;
	}

	return $sum;
}

