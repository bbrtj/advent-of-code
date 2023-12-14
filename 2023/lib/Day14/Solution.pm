package Day14::Solution;

use builtin qw(indexed);
use List::Util qw(sum0);
use Memoize;

use class;

with 'Solution';

sub _flip ($self, $pattern)
{
	my @columns;
	foreach my $row ($pattern->@*) {
		my @characters = split //, $row;
		for my $ind (keys @characters) {
			$columns[$ind] //= '';
			$columns[$ind] .= $characters[$ind];
		}
	}

	$pattern->@* = @columns;
}

sub _parse_input ($self, $input = $self->input)
{
	my @patterns;
	my @last_pattern;
	foreach my $line ($input->@*) {
		if (length $line) {
			$line =~ tr/.O#/012/;
			push @last_pattern, $line;
		}
		else {
			push @patterns, [@last_pattern];
			@last_pattern = ();
		}
	}

	push @patterns, [@last_pattern]
		if @last_pattern;

	return \@patterns;
}

sub tilt_north_and_get_load ($self, $pattern)
{
	$self->_flip($pattern);

	my $load = 0;
	foreach my ($x, $col) (indexed $pattern->@*) {
		my $total_len = length $col;
		my @parts = split /(2+)/, $col;
		my $pos = 0;
		my $movable = !!1;

		foreach my $part (@parts) {
			$load += sum0 $total_len - $pos - ($part =~ tr/1/1/) + 1 .. $total_len - $pos
				if $movable;
			$movable = !$movable;
			$pos += length $part;
		}
	}

	return $load;
}

sub get_load ($self, $pattern)
{
	$self->_flip($pattern);

	my $load = 0;
	foreach my ($x, $col) (indexed $pattern->@*) {
		my $total_len = length $col;
		for (my $i = 0; $i < $total_len; ++$i) {
			$load += $total_len - $i if substr($col, $i, 1) eq 1;
		}
	}

	return $load;
}

sub tilt_cycles ($self, $platform, $total_count)
{
	my sub tilt ($pattern, $mul) {
		foreach my ($x, $col) (indexed $pattern->@*) {
			$col = scalar reverse $col if $mul > 0;

			my @parts = split /(2+)/, $col;
			my $movable = !!1;

			foreach my $part (@parts) {
				if ($movable) {
					my $movable_rocks = ($part =~ tr/1/0/);
					$part = ('1' x $movable_rocks) . ('0' x (length($part) - $movable_rocks));
				}

				$movable = !$movable;
			}

			my $result = join '', @parts;
			$result = scalar reverse $result if $mul > 0;
			$pattern->[$x] = $result;
		}
	}

	my %known;
	foreach my $pattern ($platform->@*) {
		for (my $count = $total_count; $count > 0; --$count) {
			$self->_flip($pattern);
			tilt($pattern, -1);
			$self->_flip($pattern);
			tilt($pattern, -1);
			$self->_flip($pattern);
			tilt($pattern, 1);
			$self->_flip($pattern);
			tilt($pattern, 1);

			my $key = join ',', $pattern->@*;
			if ($known{$key}) {
				my $grand_cycle = $known{$key} - $count;
				my $wanted_count = $known{$key} - ($count - 1) % $grand_cycle;

				$pattern->@* = split /,/, first { $known{$_} == $wanted_count } keys %known;
				last;
			}
			else {
				$known{$key} = $count;
			}
		}

		%known = ();
	}
}

sub part_1 ($self)
{
	my $platform = $self->_parse_input;

	return sum0 map { $self->tilt_north_and_get_load($_) } $platform->@*;
}

sub part_2 ($self)
{
	my $platform = $self->_parse_input;

	$self->tilt_cycles($platform, 1_000_000_000);
	return sum0 map { $self->get_load($_) } $platform->@*;
}

