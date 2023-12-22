package Day22::Snapshot;

use List::Util qw(sum0);

use class;

has field 'bricks' => (
	# isa => Tuple [Tuple [Int, Int, PositiveInt], Tuple [Int, Int, PositiveInt]],
	default => sub { [] },
);

has field 'support_structure' => (
	# isa => HashRef[Int],
	default => sub { {} },
);

has field 'support' => (
	clearer => 1,
	lazy => 1,
);

sub add_brick ($self, $x_from, $y_from, $z_from, $x_to, $y_to, $z_to)
{
	push $self->bricks->@*, [[$x_from, $y_from, $z_from], [$x_to, $y_to, $z_to]];
}

sub _build_support ($self)
{
	my sub adjust ($xyz1, $xyz2) {
		state $brick_id = 1;

		my ($x1, $y1) = $xyz1->@[0, 1];
		my ($x2, $y2) = $xyz2->@[0, 1];

		($x1, $x2) = ($x2, $x1)
			if $x1 > $x2;

		($y1, $y2) = ($y2, $y1)
			if $y1 > $y2;

		return [[$x1, $y1], [$x2, $y2], $brick_id++];
	}

	my %support;
	foreach my $brick ($self->bricks->@*) {
		my @coords = sort { $a->[2] <=> $b->[2] } $brick->@*;
		my $to_push = adjust(@coords);

		foreach my $z_coord ($coords[0][2] .. $coords[1][2]) {
			push $support{$z_coord}->@*, $to_push;
		}
	}

	return \%support;
}

sub _fall ($self, $brick, $z, $support)
{
	while (--$z) {
		next unless $support->{$z};

		my $finished = 0;
		foreach my $maybe_support ($support->{$z}->@*) {
			if (
				$brick->[1][0] >= $maybe_support->[0][0] && $brick->[0][0] <= $maybe_support->[1][0]
				&& $brick->[1][1] >= $maybe_support->[0][1] && $brick->[0][1] <= $maybe_support->[1][1]
			) {
				push $self->support_structure->{$brick->[2]}->@*, $maybe_support->[2]
					unless $brick->[2] == $maybe_support->[2];
				$finished = 1;
			}
		}

		last if $finished;
	}

	return $z + 1;
}

sub rearrange ($self)
{
	my $support = $self->support;

	foreach my $z (sort { $a <=> $b } keys $support->%*) {
		my @on_level = $support->{$z}->@*;

		foreach my $i (reverse keys @on_level) {
			my $new_z = $self->_fall($on_level[$i], $z, $support);
			next if $new_z == $z;

			splice $support->{$z}->@*, $i, 1;
			push $support->{$new_z}->@*, $on_level[$i];
		}
	}
}

sub _chain_removals ($self, $id, $structure, $structure_reverse)
{
	my %removed = ($id => 1);
	my @to_remove = ($structure_reverse->{$id} // [])->@*;

	while (my $current = shift @to_remove) {
		next if $removed{$current};

		$structure->{$current} //= [];
		my $remaining = sum0 map {
			$removed{$_} ? 0 : 1
		} $structure->{$current}->@*;

		if ($remaining == 0) {
			$removed{$current} = 1;
			push @to_remove, ($structure_reverse->{$current} // [])->@*;
		}
	}

	return scalar(keys %removed) - 1;
}

sub _check_removals ($self, $ids, $structure)
{
	my @mandatory_support;
	foreach my $id ($ids->@*) {
		my $supported_by = $structure->{$id};
		next if !$supported_by;

		push @mandatory_support, $supported_by->[0]
			if $supported_by->@* == 1;
	}

	return \@mandatory_support;
}

sub optional_support ($self)
{
	my $structure = $self->support_structure;
	my $support = $self->support;
	my %can_be_removed;

	foreach my $z (sort { $a <=> $b } keys $support->%*) {
		my @must_be_supported;
		foreach my $brick ($support->{$z}->@*) {
			my $brick_id = $brick->[2];
			$can_be_removed{$brick_id} = 1;
			push @must_be_supported, $brick_id;
		}

		foreach my $required ($self->_check_removals(\@must_be_supported, $structure)->@*) {
			delete $can_be_removed{$required};
		}
	}

	return scalar keys %can_be_removed;
}

sub chain_reaction ($self)
{
	my $structure = $self->support_structure;
	my $support = $self->support;
	my %structure_reverse;

	foreach my ($id, $supported_by) ($structure->%*) {
		foreach my $id2 ($supported_by->@*) {
			push $structure_reverse{$id2}->@*, $id;
		}
	}

	my $sum = 0;
	my %processed;
	foreach my $z (sort { $a <=> $b } keys $support->%*) {
		foreach my $brick ($support->{$z}->@*) {
			my $brick_id = $brick->[2];

			# guard against higher than 1 heights
			next if $processed{$brick_id};
			$processed{$brick_id} = 1;

			$sum += $self->_chain_removals($brick_id, $structure, \%structure_reverse);
		}
	}

	return $sum;
}

