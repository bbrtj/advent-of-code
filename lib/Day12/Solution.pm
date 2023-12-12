package Day12::Solution;

use List::Util qw(sum);
use Memoize;
use Util qw(parallel_map);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @spring_rows;

	foreach my $row ($input->@*) {
		my ($springs, $desc) = split / /, $row;
		$desc = [split /,/, $desc];
		$springs =~ tr/.?#/012/;

		push @spring_rows, [$springs, $desc];
	}

	return \@spring_rows;
}

sub get_combinations ($self, $springs, $desc_aref)
{
	# gather basic facts
	my $springs_length = length $springs;
	my $last_occupied = 0;
	if ($springs =~ /(.*)2/) {
		$last_occupied = length $1;
	}

	# create cached group transitions. This will make sure we reuse the same
	# references, which don't change anyway. Memoize likes it
	my %desc_groups;
	my $current_group = $desc_aref;
	while ($current_group->@*) {
		$desc_groups{$current_group} = [$current_group->@[1 .. $current_group->$#*]];
		$current_group = $desc_groups{$current_group};
	}

	my $cached_sub;
	my sub try_fitting_group ($descs, $pos = 0) {
		my $desc = $descs->[0];

		# no elements? We're done, but is this position valid?
		return $pos > $last_occupied
			if !$desc;

		my $current = 0;
		for my $new_pos ($pos .. $springs_length - $desc) {
			# extra glued zero to take end of string into account
			my $group = substr "${springs}0", $new_pos, $desc + 1;

			# are there empty spaces in the group?
			# is the "empty space after this group" occupied? Have to respect it
			if ($group =~ /^[12]+[01]$/) {
				$current += $cached_sub->($desc_groups{$descs}, $new_pos + $desc + 1);
			}

			# is the current first position occupied? Can't go further
			last if $group =~ /^2/;
		}

		return $current;
	}

	# cache the sub
	# plain ash with results would be marginally faster, but not as convenient
	$cached_sub = memoize(\&try_fitting_group);
	return try_fitting_group($desc_aref);
}

sub _unfold_springs ($self, $springs)
{
	foreach my $spring ($springs->@*) {
		$spring->[0] = join '1', ($spring->[0]) x 5;
		$spring->[1] = [map { $spring->[1]->@* } 1 .. 5];
	}
}

sub part_1 ($self)
{
	my $springs = $self->_parse_input();

	return sum parallel_map { $self->get_combinations($_->@*) } $springs->@*;
}

sub part_2 ($self)
{
	my $springs = $self->_parse_input();
	$self->_unfold_springs($springs);

	return sum parallel_map { $self->get_combinations($_->@*) } $springs->@*;
}

