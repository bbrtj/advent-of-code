package Day3::Search;

use Types::Common -types;
use List::Util qw(max uniq);

use class;

has field 'coords' => (
	isa => ArrayRef[ArrayRef[ScalarRef]],
	default => sub { [] },
);

sub add ($self, $item, $pos_x, $pos_y, $length)
{
	$self->coords->[$pos_y]->@[$pos_x .. $pos_x + $length - 1]
		= (\$item) x $length;
}

sub find_around ($self, $pos_x, $pos_y)
{
	my $from_x = max $pos_x - 1, 0;
	my $from_y = max $pos_y - 1, 0;
	my $coords = $self->coords;

	my @found;
	foreach my $x ($from_x .. $pos_x + 1) {
		foreach my $y ($from_y .. $pos_y + 1) {
			push @found, $coords->[$y][$x] // ();
		}
	}

	return [map { $$_ } uniq @found];
}

