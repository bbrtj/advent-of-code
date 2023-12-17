package Day17::Pathfinding;

use List::Util qw(uniq reduce min);
use builtin qw(weaken indexed);
use List::BinarySearch qw(binsearch_pos);

use class;

has field 'size_x' => (
	writer => 1,
	default => 0,
);

has field 'size_y' => (
	writer => 1,
	default => 0,
);

has field 'city' => (
	default => sub { [] },
);

sub _adjust_coord ($self, $coord)
{
	if ($coord->[0] < 0) {
		$coord->[0] += $self->size_x;
	}

	if ($coord->[1] < 0) {
		$coord->[1] += $self->size_y;
	}
}

sub add_line ($self, $line)
{
	push $self->city->@*, $line;

	$self->set_size_y($self->size_y + 1);
	$self->set_size_x(scalar $line->@*);
}

sub prepare_map ($self, $min, $max)
{
	my @map = $self->city->@*;
	my @options;

	my sub applies ($prev, $next, $letter)
	{
		state %mirror = (
			r => 'l',
			l => 'r',
			d => 'u',
			u => 'd',
		);

		state %equal = (
			r => 'pos_x',
			l => 'pos_x',
			d => 'pos_y',
			u => 'pos_y',
		);

		return !!0 unless substr($prev->{dir}, -1) eq $letter;
		if (substr($next->{dir}, -1) eq $letter) {
			return length($prev->{dir}) + 1 == length($next->{dir});
		}
		else {
			return !!0 unless length $prev->{dir} >= $min;
			return !!0 unless length $next->{dir} == 1;
			return substr($next->{dir}, -1) ne $mirror{$letter};
		}
	}

	for (1 .. $max) {
		push @options, 'r' x $_;
		push @options, 'd' x $_;
		push @options, 'l' x $_;
		push @options, 'u' x $_;
	}

	# prepare nodes for pathfinding
	foreach my $y (keys @map) { ### Crunching: [ooo    ]
		my $items_x = $map[$y];
		$map[$y] = [];

		foreach my ($x, $item) (indexed $items_x->@*) {
			$map[$y][$x] = [];

			foreach my $dir (@options) {
				my $node = {
					pos_x => $x,
					pos_y => $y,
					dir => $dir,
					weight => $item,
					connections => [],
					valid => length($dir) > $min,

					total => 'inf',
					visited => !!0,
				};

				if ($x > 0) {
					foreach my $conn ($map[$y][$x - 1]->@*) {
						if (applies($conn, $node, 'r')) {
							push $conn->{connections}->@*, $node;
							weaken $conn->{connections}->[-1];
						}

						if (applies($node, $conn, 'l')) {
							push $node->{connections}->@*, $conn;
							weaken $node->{connections}->[-1];
						}
					}
				}

				if ($y > 0) {
					foreach my $conn ($map[$y - 1][$x]->@*) {
						if (applies($conn, $node, 'd')) {
							push $conn->{connections}->@*, $node;
							weaken $conn->{connections}->[-1];
						}

						if (applies($node, $conn, 'u')) {
							push $node->{connections}->@*, $conn;
							weaken $node->{connections}->[-1];
						}
					}
				}

				push $map[$y][$x]->@*, $node;
			}
		}
	}

	return \@map;
}

sub find_shortest_path ($self, $start, $end, $min, $max)
{
	$self->_adjust_coord($start);
	$self->_adjust_coord($end);
	my ($sx, $sy) = $start->@*;
	my ($ex, $ey) = $end->@*;
	my $map = $self->prepare_map($min, $max);

	my @next = $map->[$sy][$sx]->@*;
	foreach my $node (@next) {
		$node->{total} = 0;
		$node->{visited} = !!1;
	}

	my sub insert ($node) {
		my $i = binsearch_pos { $a <=> $b->{total} } $node->{total}, @next;
		$i //= @next;
		splice @next, $i, 0, $node;
	}

	# do the pathfinding
	while (my $current = shift @next) {
		return $current->{total}
			if $current->{valid} && $current->{pos_x} == $ex && $current->{pos_y} == $ey;

		foreach my $node ($current->{connections}->@*) {
			my $new_total = $current->{total} + $node->{weight};
			$node->{total} = $new_total
				if $node->{total} > $new_total;

			if (!$node->{visited}) {
				insert($node);
				$node->{visited} = !!1;
			}
		}
	}

	return undef;
}

