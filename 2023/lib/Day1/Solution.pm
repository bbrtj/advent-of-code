package Day1::Solution;

use Lingua::EN::Numbers qw(num2en);

use class;

with 'Solution';

sub part_1 ($self)
{
	my $total = 0;
	foreach my $line ($self->input->@*) {
		my ($first) = $line =~ m{(\d)};
		my ($last) = $line =~ m{.*(\d)};
		$total += "$first$last";
	}

	return $total;
}

sub part_2 ($self)
{
	my %numbers_en = map { num2en($_) => $_ } 1 .. 9;
	my $regex_part = join '|', keys %numbers_en, '\d';

	my $total = 0;
	foreach my $line ($self->input->@*) {
		my ($first) = $line =~ m{($regex_part)};
		my ($last) = $line =~ m{.*($regex_part)};

		$first = $numbers_en{$first} // $first;
		$last = $numbers_en{$last} // $last;

		$total += "$first$last";
	}

	return $total;
}

