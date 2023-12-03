package Day3::Search;

use Types::Common -types;
use List::Util qw(max uniq);

use class;

has field 'coords' => (
	isa => ArrayRef[ArrayRef[Int]],
	default => sub { [] },
);

sub add ($self, $item, $pos_x_from, $pos_x_to, $pos_y)
{
	push $self->coords->[$pos_y][$_]->@*, \$item
		for $pos_x_from .. $pos_x_to;
}

sub find_around ($self, $pos_x, $pos_y)
{
	my $from_x = max $pos_x - 1, 0;
	my $from_y = max $pos_y - 1, 0;
	my $to_x = $pos_x + 1;
	my $to_y = $pos_y + 1;

	my @found;
	foreach my $x ($from_x .. $to_x) {
		foreach my $y ($from_y .. $to_y) {
			my $box = $self->coords->[$y][$x];
			next if !$box;

			@found = (@found, $box->@*);
		}
	}

	return [map { $$_ } uniq @found];
}

