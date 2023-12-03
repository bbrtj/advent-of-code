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

	my $has_number = !!0;
	my $number_from;
	foreach my ($pos_y, $items_x) (indexed $input->@*) {
		foreach my ($pos_x, $item) (indexed $items_x->@*) {
			my $has_number_now = $item =~ /\d/;

			if (!$has_number && $has_number_now) {
				# number start
				$number_from = $pos_x;
				$has_number = !!1;
			}
			elsif ($has_number && !$has_number_now) {
				# number end
				my $number_y = $pos_x == 0 ? $pos_y - 1 : $pos_y;
				my $number_to = $pos_x == 0 ? $input->[$number_y]->$#* : $pos_x - 1;
				my $number = join '', $input->[$number_y]->@[$number_from .. $number_to];
				$search->add($number, $number_from, $number_to, $number_y);

				$has_number = !!0;
			}

			if (!$has_number_now) {
				next if $item eq '.';
				push @symbols, [$item, $pos_x, $pos_y];
			}
		}
	}

	return ($search, \@symbols);
}

sub run_first ($self)
{
	my ($search, $symbols) = $self->_parse_input($self->input);

	my $sum = 0;
	foreach my $symbol ($symbols->@*) {
		shift $symbol->@*;
		$sum += sum0 $search->find_around($symbol->@*)->@*;
	}

	$self->output($sum);
}

sub run_second ($self)
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

	$self->output($sum);
}

