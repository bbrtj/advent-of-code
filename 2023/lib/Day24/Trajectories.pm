package Day24::Trajectories;

use Math::Matrix;

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

sub magic_bullet ($self)
{
	my @points = $self->points->@[0 .. 4];

	my $a = $points[0][0][0];
	my $da = $points[0][1][0];
	my $b = $points[0][0][1];
	my $db = $points[0][1][1];

	my $d = $points[1][0][0];
	my $dd = $points[1][1][0];
	my $e = $points[1][0][1];
	my $de = $points[1][1][1];

	my $g = $points[2][0][0];
	my $dg = $points[2][1][0];
	my $h = $points[2][0][1];
	my $dh = $points[2][1][1];

	my $j = $points[3][0][0];
	my $dj = $points[3][1][0];
	my $k = $points[3][0][1];
	my $dk = $points[3][1][1];

	my $m = $points[4][0][0];
	my $dm = $points[4][1][0];
	my $n = $points[4][0][1];
	my $dn = $points[4][1][1];

	my $matrix = [
		[$db - $de, $e - $b, $dd - $da, $a - $d, $db * $a - $da * $b + $dd * $e - $de * $d],
		[$db - $dh, $h - $b, $dg - $da, $a - $g, $db * $a - $da * $b + $dg * $h - $dh * $g],
		[$db - $dk, $k - $b, $dj - $da, $a - $j, $db * $a - $da * $b + $dj * $k - $dk * $j],
		[$dn - $db, $b - $n, $da - $dm, $m - $a, $da * $b - $db * $a + $dn * $m - $dm * $n],
	];

	my $r = Math::Matrix->new($matrix)->solve;
	if (defined $r) {
		my ($xs, $vxs, $ys, $vys) = ($r->[0][0], $r->[1][0], $r->[2][0], $r->[3][0]);

		my $t1 = int(($points[0][0][0] - $xs) / ($vxs - $points[0][1][0]) + 0.5);
		my $t2 = int(($points[1][0][0] - $xs) / ($vxs - $points[1][1][0]) + 0.5);
		my $z1 = $points[0][0][2] + $t1 * $points[0][1][2];
		my $z2 = $points[1][0][2] + $t2 * $points[1][1][2];

		my $vzs = ($z1 - $z2) / ($t1 - $t2);
		my $zs = $z1 - $t1 * $vzs;

		return $xs + $ys + $zs;
	}

	return 'No solution';
}

