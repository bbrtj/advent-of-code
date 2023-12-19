package Day19::Solution;

use List::Util qw(sum0);
use Day19::Range;

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input(!!1))
{
	my $stage = 0;

	my %workflows;
	my @ratings;

	foreach my $line ($input->@*) {
		if (!length $line) {
			$stage++;
			next;
		}

		if ($stage == 0) {
			# workflows
			if ($line =~ m{(\w+) \{ (.+) \}}x) {
				my $label = $1;
				my @instructions = split /,/, $2;
				foreach my $instr (@instructions) {
					my @parts = split /:/, $instr;
					if (@parts == 2) {
						my @condition = split /([<>])/, $parts[0];
						$parts[0] = \@condition;
					}
					else {
						unshift @parts, undef
					}

					$instr = \@parts;
				}

				$workflows{$label} = \@instructions;
			}
		}
		elsif ($stage == 1) {
			# parts
			if ($line =~ m{\{ (.+) \}}x) {
				my @items = split /,/, $1;
				my %data;
				foreach my $item (@items) {
					my @parts = split /=/, $item;
					$data{$parts[0]} = $parts[1];
				}

				push @ratings, \%data;
			}
		}
	}

	return (\%workflows, \@ratings);
}

sub compare ($self, $rating, $instr)
{
	return $instr->[1] unless defined $instr->[0];
	my ($value_label, $comparison, $eq) = $instr->[0]->@*;
	my $ok = $comparison eq '>'
		? $rating->{$value_label} > $eq
		: $comparison eq '<'
			? $rating->{$value_label} < $eq
			: die "unknown operation $comparison"
		;

	return $ok ? $instr->[1] : undef;
}

sub compare_range ($self, $rating, $instr)
{
	if (defined $instr->[0]) {
		my ($value_label, $comparison, $eq) = $instr->[0]->@*;
		my $old_rating = $rating;
		$rating = $rating->clone;
		if ($comparison eq '>') {
			$rating->set_lower($value_label, $eq + 1);
			$old_rating->set_upper($value_label, $eq);
		}
		elsif ($comparison eq '<') {
			$rating->set_upper($value_label, $eq - 1);
			$old_rating->set_lower($value_label, $eq);
		}
		else {
			die "unknown operation $comparison";
		}
	}

	return [$instr->[1], $rating];
}

sub process ($self, $rating, $workflow)
{
	if ($rating isa 'Day19::Range') {
		my @result;

		foreach my $instr ($workflow->@*) {
			push @result, $self->compare_range($rating, $instr);
			# last if !$rating->valid;
		}

		return grep { $_->[1]->valid } @result;
	}
	else {
		foreach my $instr ($workflow->@*) {
			my $new_label = $self->compare($rating, $instr);
			return $new_label if defined $new_label;
		}

		die "no label found?";
	}
}

sub part_1 ($self)
{
	my ($workflows, $ratings) = $self->_parse_input;

	my @bag;
	foreach my $rating ($ratings->@*) {
		push @bag, ['in', $rating];
	}

	while ('not all are rejected or accepted') {
		my $got_unfinished = 0;
		foreach my $item (@bag) {
			if ($item->[0] eq 'A' || $item->[0] eq 'R') {
				next;
			}

			$got_unfinished = 1;
			$item->[0] = $self->process($item->[1], $workflows->{$item->[0]});
		}

		last unless $got_unfinished;
	}

	my $sum = 0;
	foreach my $item (@bag) {
		next if $item->[0] eq 'R';
		$sum += sum0 values $item->[1]->%*;
	}

	return $sum;
}

sub part_2 ($self)
{
	my ($workflows, $ratings) = $self->_parse_input;

	my @bag = (['in', Day19::Range->new]);

	while ('not all are rejected or accepted') {
		my $got_unfinished = 0;
		my @new_items;
		foreach my $item (@bag) {
			if ($item->[0] eq 'A' || $item->[0] eq 'R') {
				push @new_items, $item;
				next;
			}

			$got_unfinished = 1;
			push @new_items, $self->process($item->[1], $workflows->{$item->[0]});
		}

		@bag = @new_items;
		last unless $got_unfinished;
	}

	my $sum = 0;
	foreach my $item (@bag) {
		next if $item->[0] eq 'R';
		$sum += $item->[1]->combinations;
	}

	return $sum;
}

