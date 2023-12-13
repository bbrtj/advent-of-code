package Day10::MazePipe;

use Types::Common -types;
use builtin qw(weaken);

use class;

has param 'position' => (
	# isa => Tuple[Int, Int],
);

has field 'length' => (
	# isa => Int,
	writer => 1,
);

has field 'from' => (
	# isa => InstanceOf['Day10::MazePipe'],
	writer => 1,
	weak_ref => 1,
);

has field 'to' => (
	# isa => InstanceOf['Day10::MazePipe'],
	writer => 1,
);

sub set_weak_to ($self, $to)
{
	$self->{to} = $to;
	weaken $self->{to};
}

sub next_position ($self, @moves) {
	my ($x, $y) = $self->position->@*;

	foreach my $move (@moves) {
		my $x2 = $x + $move->[0];
		my $y2 = $y + $move->[1];

		if (my $from = $self->from) {
			my ($x, $y) = $from->position->@*;
			next if $x == $x2 && $y == $y2;
		}

		return ($x2, $y2);
	}
}

