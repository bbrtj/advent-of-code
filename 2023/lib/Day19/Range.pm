package Day19::Range;

use List::Util qw(product);

use class;

has param 'possible' => (
	default => sub {
		{
			x => [1, 4000],
			m => [1, 4000],
			a => [1, 4000],
			s => [1, 4000],
		}
	},
);

has field 'valid' => (
	writer => 1,
	default => !!1,
);

sub clone ($self)
{
	# clone possible
	my %possible = $self->possible->%*;
	foreach my ($k, $v) (%possible) {
		$possible{$k} = [$v->@*];
	}

	return $self->new(possible => \%possible);
}

sub combinations ($self)
{
	my @diffs;
	foreach my $arr (values $self->possible->%*) {
		push @diffs, $arr->[1] - $arr->[0] + 1;
	}

	return product @diffs;
}

sub set_lower ($self, $what, $value)
{
	my $pos = $self->possible;
	$pos->{$what}[0] = $value;
	$self->set_valid(!!0)
		if $pos->{$what}[0] > $pos->{$what}[1];
}

sub set_upper ($self, $what, $value)
{
	my $pos = $self->possible;
	$pos->{$what}[1] = $value;
	$self->set_valid(!!0)
		if $pos->{$what}[0] > $pos->{$what}[1];
}

