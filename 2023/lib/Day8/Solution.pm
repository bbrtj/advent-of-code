package Day8::Solution;

use Math::Utils qw(lcm);

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @instruction;
	my %map;

	foreach my $line ($input->@*) {
		if (!@instruction) {
			@instruction = map { $_ eq 'R' } split //, $line;
		}
		elsif ($line =~ m{(\w+) = \((.*)\)}) {
			$map{$1} = [split /,\s*/, $2];
		}
	}

	return (\@instruction, \%map);
}

sub get_number_of_cycles ($self, $instruction, $map, $current, $to_re)
{
	# improves the matching speed by a lot
	my $re_compiled = "$to_re";

	my $steps = 0;
	while ('searching') {
		foreach my $ins ($instruction->@*) {
			return $steps
				if $current =~ $re_compiled;

			$current = $map->{$current}[$ins];
			$steps += 1;
		}
	}
}

sub part_1 ($self)
{
	my ($instruction, $map) = $self->_parse_input;
	return $self->get_number_of_cycles($instruction, $map, 'AAA', qr/ZZZ/);
}

sub part_2 ($self)
{
	my ($instruction, $map) = $self->_parse_input;
	my @all_starting = grep { /A$/ } keys $map->%*;

	my @cycles;
	foreach my $starting (@all_starting) {
		push @cycles, $self->get_number_of_cycles($instruction, $map, $starting, qr/Z$/);
	}

	return lcm(@cycles);
}

