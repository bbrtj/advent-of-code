package Day13::Solution;

use List::Util qw(sum);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input(!!1))
{
	my @last_pattern;
	my @patterns;

	foreach my $line ($input->@*) {
		if (length $line) {
			push @last_pattern, $line;
		}
		else {
			push @patterns, [[@last_pattern]];
			@last_pattern = ();
		}
	}

	push @patterns, [[@last_pattern]]
		if @last_pattern;

	foreach my $pattern (@patterns) {
		my @columns;
		foreach my $row ($pattern->[0]->@*) {
			my @characters = split //, $row;
			for my $ind (keys @characters) {
				$columns[$ind] //= '';
				$columns[$ind] .= $characters[$ind];
			}
		}

		unshift $pattern->@*, [@columns];
	}

	# returns a list of patterns, each pattern being two versions:
	# - pattern oriented vertically
	# - pattern oriented horizontally
	# (like in the part 1 example)
	return \@patterns;
}

sub find_reflections ($self, $pattern, $fix = !!0)
{
	# special string comparing function, returning the number of mismatching
	# characters
	my sub special_compare ($str1, $str2)
	{
		return 0 if $str1 eq $str2;

		my @chars1 = split //, $str1;
		my @chars2 = split //, $str2;

		my $diff = 0;
		foreach my ($char1, $char2) (mesh \@chars1, \@chars2) {
			$diff += $char1 ne $char2;
			last if $diff > 1;
		}

		return $diff;
	}

	# just try a position will regular string comparison
	my sub try_position ($arr, $ind) {
		my $size = $arr->@*;
		for (my $i = 0; $ind - $i >= 0 && $ind + $i + 1 < $size; ++$i) {
			return !!0 if $arr->[$ind - $i] ne $arr->[$ind + $i + 1];
		}

		return !!1;
	}

	# NOTE: does not actually fix anything. Hope it can't be fixed two times
	# differently!
	my sub try_and_fix_position ($arr, $ind) {
		my $size = $arr->@*;
		my $total_diff = 0;
		for (my $i = 0; $ind - $i >= 0 && $ind + $i + 1 < $size; ++$i) {
			$total_diff += special_compare($arr->[$ind - $i], $arr->[$ind + $i + 1]);
			last if $total_diff > 1;
		}

		return $total_diff == 1;
	}

	# this part is common
	my $try_position = $fix ? \&try_and_fix_position : \&try_position;
	my sub find_reflection ($dimension) {
		my $this_pat = $pattern->[$dimension];

		my $size = $this_pat->@*;
		foreach my $ind (0 .. $size - 2) {
			return $ind + 1 if $try_position->($this_pat, $ind);
		}

		return 0;
	}

	return [find_reflection(0), find_reflection(1)];
}

sub part_1 ($self)
{
	my $patterns = $self->_parse_input;
	return sum
		map { $_->[0] + $_->[1] * 100 }
		map { $self->find_reflections($_) }
		$patterns->@*;
}

sub part_2 ($self)
{
	my $patterns = $self->_parse_input;
	return sum
		map { $_->[0] + $_->[1] * 100 }
		map { $self->find_reflections($_, !!1) }
		$patterns->@*;
}

