package Day24::Trajectories;

use class;

has field 'points' => (
	# isa => ArrayRef [Tuple [ArrayRef, ArrayRef]],
	default => sub { [] },
);

sub add ($self, $pos, $velocity)
{
	push $self->points->@*, [$pos, $velocity];
}

sub count_collisions ($self, $range)
{
	my $points = $self->points;
	my ($range_low, $range_high) = $range->@*;

	my $occured = 0;
	for my $i (0 .. $points->$#*) {
		for my $j ($i + 1 .. $points->$#*) {
			try {
				my ($x1, $y1) = $points->[$i][0]->@*;
				my ($vx1, $vy1) = $points->[$i][1]->@*;

				my ($x2, $y2) = $points->[$j][0]->@*;
				my ($vx2, $vy2) = $points->[$j][1]->@*;

				my $t1 = ($vx2 * ($y2 - $y1) + $vy2 * ($x1 - $x2)) / ($vx2 * $vy1 - $vy2 * $vx1);
				my $t2 = ($x1 - $x2 + $vx1 * $t1) / $vx2;

				next if $t1 < 0 || $t2 < 0;

				my $common_x = $x1 + $vx1 * $t1;
				my $common_y = $y1 + $vy1 * $t1;

				$occured += 1
					if $range_low <= $common_x <= $range_high
					&& $range_low <= $common_y <= $range_high;
			}
			catch ($e) {
				die $e unless $e =~ /division by zero/;
			}
		}
	}

	return $occured;
}

