package Day1::Solution;

use Lingua::EN::Numbers qw(num2en);

use class;

with 'Solution';

sub run_first ($self)
{
	my $total = 0;
	foreach my $line ($self->input->@*) {
		my ($first) = $line =~ m{(\d)};
		my ($last) = $line =~ m{.*(\d)};
		$total += "$first$last";
	}

	$self->output($total);
}

sub run_second ($self)
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

	$self->output($total);
}

