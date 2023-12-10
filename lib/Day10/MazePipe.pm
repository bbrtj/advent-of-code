package Day10::MazePipe;

use Types::Common -types;

use class;

has param 'position' => (
	# isa => Tuple[Int, Int],
);

has param 'type' => (
	# isa => Tuple[Str, Str],
);

has param 'path' => (
	# isa => Tuple[Int, Int],
);

has field 'from' => (
	# isa => InstanceOf['Day10::MazePipe'],
	writer => 1,
	weak_ref => 1,
);

has field 'to' => (
	# isa => InstanceOf['Day10::MazePipe'],
	writer => 1,
	weak_ref => 1,
);

sub _adjust_position($self, $x, $y, $pos_type, $pos_dir = 1)
{
	my $is_x = $pos_type eq 'x';

	return ($x + $is_x * $pos_dir, $y + !$is_x * $pos_dir);
}

sub next_position ($self) {
	my ($x, $y) = $self->position->@*;
	my $pos_type = $self->type;
	my $pos_dir = $self->path;

	for my $ind (0 .. 1) {
		my ($x2, $y2) = $self->_adjust_position($x, $y, $pos_type->[$ind], $pos_dir->[$ind]);

		if ($self->from) {
			my ($x, $y) = $self->from->position->@*;
			next if $x == $x2 && $y == $y2;
		}

		return ($x2, $y2);
	}
}

