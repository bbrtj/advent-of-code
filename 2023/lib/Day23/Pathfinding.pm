package Day23::Pathfinding;

use List::Util qw(max shuffle);
use builtin qw(weaken indexed);

use class;

has field 'size_x' => (
	writer => 1,
	default => 0,
);

has field 'size_y' => (
	writer => 1,
	default => 0,
);

has field 'map' => (
	default => sub { [] },
);

use constant PATH => '.';
use constant OBSTACLE => '#';
use constant SLOPES => {
	up => '^',
	down => 'v',
	left => '<',
	right => '>',
};

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
	push $self->map->@*, $line;

	$self->set_size_y($self->size_y + 1);
	$self->set_size_x(scalar $line->@*);
}

sub prepare_map ($self, $slopes)
{
	my @map = $self->map->@*;

	# prepare nodes for pathfinding
	foreach my $y (keys @map) {
		my $items_x = $map[$y];
		$map[$y] = [];

		foreach my ($x, $item) (indexed $items_x->@*) {
			if ($item eq OBSTACLE) {
				next;
			}

			my $node = {
				pos_x => $x,
				pos_y => $y,
				item => $item,
				connections => [],
			};

			$map[$y][$x] = $node;

			if ($x > 0 && (my $conn = $map[$y][$x - 1])) {
				if (!$slopes || $conn->{item} eq PATH || $conn->{item} eq SLOPES->{right}) {
					push $conn->{connections}->@*, $node;
					weaken $conn->{connections}->[-1];
				}

				if (!$slopes || $node->{item} eq PATH || $node->{item} eq SLOPES->{left}) {
					push $node->{connections}->@*, $conn;
					weaken $node->{connections}->[-1];
				}
			}

			if ($y > 0 && (my $conn = $map[$y - 1][$x])) {
				if (!$slopes || $conn->{item} eq PATH || $conn->{item} eq SLOPES->{down}) {
					push $conn->{connections}->@*, $node;
					weaken $conn->{connections}->[-1];
				}

				if (!$slopes || $node->{item} eq PATH || $node->{item} eq SLOPES->{up}) {
					push $node->{connections}->@*, $conn;
					weaken $node->{connections}->[-1];
				}
			}
		}
	}

	return \@map;
}

sub find_longest_path ($self, $start, $end)
{
	$self->_adjust_coord($start);
	$self->_adjust_coord($end);
	my ($sx, $sy) = $start->@*;
	my ($ex, $ey) = $end->@*;
	my $map = $self->prepare_map(!!1);

	my @next = ([$map->[$sy][$sx], {$map->[$sy][$sx] => $map->[$sy][$sx]}, 0]);
	my $end_node = $map->[$ey][$ex];

	# do the pathfinding
	my $longest = 0;
	my $found = 0;
	while (my $current_item = pop @next) {
		my ($current, $history, $walked) = $current_item->@*;
		my $last = 0;

		while ($current != $end_node) {
			my ($next_current, @others) = shuffle grep { $_ != $last && !$history->{$_} } $current->{connections}->@*;
			last unless $next_current;

			$last = $current;
			$current = $next_current;
			$walked += 1;

			if (@others) {
				$history->{$last} = $last;
			}

			foreach my $node (@others) {
				push @next, [$node, {$history->%*}, $walked];
			}
		}

		if ($current == $end_node) {
			$longest = max $longest, $walked;
		}
	}

	return $longest;
}

sub build_simple_graph ($self, $map, $sx, $sy, $ex, $ey)
{
	my @next = ([$map->[$sy][$sx], $map->[$sy][$sx]]);
	my $end_node = $map->[$ey][$ex];

	my %connections;
	my %visited;

	while (my $current_item = pop @next) {
		my ($current, $from) = $current_item->@*;
		my $walked = 0;

		while (1) {
			my @others = $current->{connections}->@*;

			$visited{$current} = $current;
			$walked += 1;

			if ($current == $end_node) {
				last;
			}

			if (@others > 2) {
				foreach my $n (grep { !$visited{$_} } @others) {
					unshift @next, [$n, $current];
				}

				last;
			}

			my $next = first { !$visited{$_} } @others;
			if (!$next) {
				my $peek = first {
					$visited{$_} != $current
					&& $from != $_
					&& $_->{connections}->@* > 2
				} @others;
				$current = $peek;
				$walked += 1;

				last;
			}

			$current = $next;
		}

		if ($current) {
			# say "connecting $current->{pos_x}:$current->{pos_y} with $from->{pos_x}:$from->{pos_y} (len $walked)";
			push $connections{$from}->@*, [$current, $walked];
			push $connections{$current}->@*, [$from, $walked];
		}
	}

	return \%connections;
}

sub find_longest_path_no_slopes ($self, $start, $end)
{
	$self->_adjust_coord($start);
	$self->_adjust_coord($end);
	my ($sx, $sy) = $start->@*;
	my ($ex, $ey) = $end->@*;
	my $map = $self->prepare_map(!!0);
	my $connections = $self->build_simple_graph($map, $sx, $sy, $ex, $ey);

	# do the pathfinding
	my @next = ([$map->[$sy][$sx], {$map->[$sy][$sx] => 1}, -1]);
	my $end_node = $map->[$ey][$ex];
	my $longest = 0;

	while (my $current_item = pop @next) {
		my ($current, $history, $walked) = $current_item->@*;
		$history->{$current} = 1;
		if ($current == $end_node) {
			$longest = max $longest, $walked;
			next;
		}

		foreach my $node_item (grep { !$history->{$_->[0]} } $connections->{$current}->@*) {
			push @next, [$node_item->[0], {$history->%*}, $node_item->[1] + $walked];
		}
	}

	return $longest;
}

